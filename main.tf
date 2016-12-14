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
    /if (isSet("var_user_map_46_sendmapevent")) \
        /let _commandName=%;\
        /test _commandName := getVar("map.sendmapevent")%;\
        /quote -S -decho !%_commandName %_roomId%;\
    /endif%;\
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


/util_addListener entered_room map_handleEnteredRoom
/def map_handleEnteredRoom = \
    /let _roomId=$[getVar("map.currentRoom.id")]%;\
    /setVar map.moveQueue $(/cdr $[getVar("map.moveQueue")])%;\
    /let _moveQueue=$[getVar("map.moveQueue")]%;\
    /let _len=$(/length $[getVar("map.moveQueue")])%;\
    /let _targetRoomId=$[getVar("map.path.target.roomId")]%;\
    /if (_roomId == _targetRoomId)\
        /setVar map.path.target.roomId%;\
        /event_fire map_path_complete %{_roomId}%;\
    /elseif (_len == 0 & _targetRoomId !~ "") \
        /echo Move queue not empty with target room.%;\
        /if (getVar("map.path.retryCount")) \
            /test setVar("map.path.retryCount", getVar("map.path.retryCount")-1)%;\
            /map_go%;\
        /else \
            /echo Path target not reached, but retry count used up.%;\
            /beep%;\
        /endif%;\
;    /else \
;        /echo Move queue empty or no target room.%;\
    /endif%;\
;Repeating this line because it may have changed.
    /let _targetRoomId=$[getVar("map.path.target.roomId")]%;\
    /if (_targetRoomId) \
        /if (strlen(getVar("map.path.completeHandler")) > 0) \
            /test _targetRoomId := strcat(_targetRoomId, " -> ", getVar("map.path.completeHandler"))%;\
        /endif%;\
        /echo Target Room: <%{_targetRoomId}>%;\
    /endif%;\
    /test 1

; This is a hook so that the built in speed walking can play nice
; with the rest of the mapping stuffs.
/def _map_hook = \
    /map_queueMoveCmd %{*}

/def -mregexp -ip{maxpri} -h"send ^(no(r(t(h)?)?)?|we(s(t)?)?|ea(s(t)?)?|so(u(t(h)?)?)?|up|do(w(n)?)?|l(o(o(k)?)?)?)$" map_detectMovement = \
    /map_queueMoveCmd $[substr({P0}, 0,1)]%;\
    /send %{*}

/def map_queueMoveCmd = \
    /test setVar("map.moveQueue", strcat(getVar("map.moveQueue"), " ", {1}))%;\
;    /echo Move queue is now <$[getVar("map.moveQueue")]>%;\
    /test 1

/util_addListener combat_detected map_clearMoveQueue
/def map_clearMoveQueue = \
    /test setVar("map.moveQueue", "")

/def -mregexp -t"^Alas, you cannot go that way\.\.\.$" map_cannotGoThatWay = \
    /map_queue_pop

/def -mregexp -t"^(.*) seems to be closed\.$" map_closed_door = \
    /map_queue_pop

/def map_queue_pop = \
    /let _val=$(/car $[getVar("map.moveQueue")])%;\
    /setVar map.moveQueue $(/cdr $[getVar("map.moveQueue")])%;\
    /result _val

