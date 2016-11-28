;;
;; tf-mapper/main.tf
;;
/loaded __tf_mapper_main__

/require tf-sqlite/main.tf

/require tf-mapper/pathing.tf

;
; This should be called by a mud-specific map helper that captures room
; details to pass into the mapper.
;
/def map_roomCaptured = \
    /let _name=%{1}%;\
    /let _desc=%{2}%;\
    /let _roomId=$[map_findRoomByName(_name)]%;\
    /if (strstr(_roomId, " ") != -1) \
        /test _roomId := map_findRoomByDesc(_desc, _roomId)%;\
    /endif%;\
    /util_setVar map.currentRoom.id %{_roomId}%;\
    /quote -S -decho !/Users/wilh/Desktop/SendMapEvent %_roomId%;\
    /echo Room ID: %{_roomId}

;
; Attempt to find a room by looking up its name.
;
/def map_findRoomByName = \
    /let _roomName=%{*}%;\
    /let _sql=%;\
    /test _sql := strcat("SELECT [ObjID] FROM [ObjectTbl] WHERE [Name] = '", sqlite_escapeSql(_roomName), "'")%;\
    /return sqlite_rawQuery(map_mapFile, _sql)

/def map_findRoomByDesc = \
    /let _descClause=$[map_getDescClause({1})]%;\
    /let _sql=%;\
    /test _sql := "SELECT [ObjID] FROM [ObjectTbl] WHERE "%;\
    /if ({#} == 2) \
        /let _roomList=$[replace(" ", ", ", {2})]%;\
        /test _sql := strcat(_sql, "[ObjID] IN (", _roomList, ") AND ")%;\
    /endif%;\
    /test _sql := strcat(_sql, _descClause)%;\
;    /echo _sql : '%{_sql}'%;\
    /return sqlite_rawQuery(map_mapFile, _sql)

/def map_getDescClause = \
    /let _desc=$[replace("'", "''", {*})]%;\
    /let _end=$[strstr(_desc, char(10))]%;\
    /if (_end == -1) \
        /return _desc%;\
    /endif%;\
    /let _start=%;\
    /test _start := 0%;\
    /let _likeClause=$[strcat("[Desc] LIKE '", substr(_desc, _start, _end), "%%'")]%;\
    /test _start := _end + 1%;\
    /test _end := strstr(_desc, char(10), _start)%;\
    /while (_end != -1) \
        /let _likeBit=%;\
        /let _substr=$[substr(_desc, _start, _end - _start)]%;\
        /if (strstr(_substr, '"') == -1) \
            /test _likeBit := strcat("[Desc] LIKE '%%", _substr, "%%'")%;\
            /test _likeClause := strcat(_likeClause, " AND ", _likeBit)%;\
        /endif%;\
        /test _start := _end + 1%;\
        /test _end := strstr(_desc, char(10), _start)%;\
    /done%;\
    /return _likeClause

/def map_locationKnown = \
    /let _currentId=$[util_getVar("map.currentRoom.id")]%;\
    /result (_currentId !~ "" & strstr(_currentId, " ") == -1)

/def map_rawQuery = \
    /result sqlite_rawQuery(map_mapFile, {*})

/alias me /map_exits %{*}
/def map_exits = \
    /if (!map_locationKnown()) \
        /echo -aCyellow Cannot show exits when I don't know where we are.%;\
        /return%;\
    /endif%;\
    /let _sql=$[strcat("SELECT ExitID, DirName, ToID, Param FROM ExitTbl JOIN DirTbl ON DirType = DirTbl.DirID-1 WHERE FromID = '",sqlite_escapeSql(util_getVar("map.currentRoom.id")),"';")]%;\
    /let _r=$[map_rawQuery(_sql)]%;\
    /map_dumpExitList %{1} %{_r}

/def map_dumpExitList = \
    /let _verbose=0%;\
    /if ({1} =~ "v") \
        /let _verbose=1%;\
        /shift%;\
    /endif%;\
    /while ({#} > 0) \
        /let _exit=%{1}%;\
        /if (regmatch("^(\d+)\|(\w+)\|(\d+)\|(.*)$", _exit)) \
            /let _exitId=$[pad({P1}, -5)]%;\
            /let _dir=$[pad({P2},-5)]%;\
            /let _roomId=%{P3}%;\
            /let _doorName=%{P4}%;\
            /let _roomName=$[map_findRoomNameById(_roomId)]%;\
            /let _line=%{_dir} : %{_roomName} (%{_roomId})%;\
            /if (_verbose) \
                /let _line=%{_exitId} : %{_line}%;\
            /endif%;\
            /if (_doorName !~ "") \
                /let _line=%{_line} <%{_doorName}>%;\
            /endif%;\
            /echo %{_line}%;\
        /else \
            /echo '%{_exit}' didn't match?%;\
        /endif%;\
        /shift%;\
    /done

/def map_findRoomNameById = \
    /let _id=$[sqlite_escapeSql({*})]%;\
    /let _sql=SELECT NAME FROM [ObjectTbl] WHERE [ObjID] = %{_id}%;\
    /result map_rawQuery(_sql)

/alias zone /map_zone %{*}
/def map_zone = \
    /let _room=$[util_getVar("map.currentRoom.id")]%;\
    /if ({#}) \
        /test _room := {1}%;\
    /endif%;\
    /let _sql=SELECT ZoneTbl.Name FROM ObjectTbl JOIN ZoneTbl ON ObjectTbl.ZoneID = ZoneTbl.ZoneID WHERE ObjectTbl.ObjID = %{_room}%;\
    /result map_rawQuery(_sql)

