;;
;; tf-mapper/main.tf
;;
/loaded __tf_mapper_main__

/require tf-sqlite/main.tf

/require tf-mapper/pathing.tf

/set map_editMode 0

/def map_edit = \
    /test map_editMode := !map_editMode%;\
    /let _status=$[map_editMode ? "On" : "Off"]%;\
    /if (map_editMode) \
        look%;\
    /endif%;\
    /echo Map Edit Mode: %{_status}

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
    /if (_roomId =~ "")\
        /let _prevRoom=$[getVar("map.currentRoom.id")]%;\
        /let _lastDir=$(/car $[getVar("map.moveQueue")])%;\
        /let _bestGuess=%;\
        /test _bestGuess := map_guessRoomFrom(_prevRoom, _lastDir)%;\
        /echo -aCyellow *** Could not find matching room. /map_updateRoom? ***%;\
        /if (_bestGuess !~ "") \
            /echo Best guess room ID: %{_bestGuess} <%{_lastDir} from $[map_getRoomName(_prevRoom)] (%{_prevRoom})>%;\
            /setVar map.currentRoom.guess %{_bestGuess}%;\
            /util_setVar map.currentRoom.id %{_bestGuess}%;\
            /if (isSet("var_user_map_46_sendmapevent")) \
                /let _commandName=%;\
                /test _commandName := getVar("map.sendmapevent")%;\
                /quote -S -decho !%{_commandName} %{_bestGuess}%;\
            /endif%;\
        /endif%;\
    /else \
        /util_setVar map.currentRoom.id %{_roomId}%;\
        /if (isSet("var_user_map_46_sendmapevent")) \
            /let _commandName=%;\
            /test _commandName := getVar("map.sendmapevent")%;\
            /quote -S -decho !%{_commandName} %{_roomId}%;\
        /endif%;\
        /echo Room ID: %{_roomId}%;\
    /endif

/def map_checkGuess = \
    /let _guess=$[getVar("map.currentRoom.guess")]%;\
    /map_dumpRoomInfo %{_guess}

/def map_dumpRoomInfo = \
    /let _roomId=%{1}%;\
    /let _name=$[map_getRoomName(_roomId)]%;\
    /let _desc=$[map_getRoomDescription(_roomId)]%;\
    /echo Current Guess:%;\
    /test echo("-----")%;\
    /echo %{_name} (%{_roomId})%;\
    /test map_dumpRoomDescription(_desc)%;\
    /test echo("-----")

/def map_getRoomName = \
    /let _roomId=%{1}%;\
    /let _sql=$[strcat("SELECT [Name] FROM [ObjectTbl] WHERE [ObjID] = '", sqlite_escapeSql(_roomId), "'")]%;\
    /let _r=$[sqlite_rawQuery(map_mapFile, _sql)]%;\
    /result _r

/def map_getRoomDescription = \
    /let _roomId=%{1}%;\
    /let _sql=$[strcat("SELECT [Desc] FROM [ObjectTbl] WHERE [ObjID] = '", sqlite_escapeSql(_roomId), "'")]%;\
    /let _r=$[sqlite_rawQuery(map_mapFile, _sql)]%;\
    /result _r

/def map_dumpRoomDescription = \
    /let _desc=%{1}%;\
    /let _i=0%;\
    /let _line=0%;\
    /while (_i < strlen(_desc) & _line < 10) \
        /let _cr=$[strchr(_desc, strcat(char(10),char(13)), _i)]%;\
        /if (_cr == -1) \
            /let _remaining=$[substr(_desc, _i)]%;\
            /if (_remaining !~ "")\
                /echo %{_remaining}%;\
            /endif%;\
            /break%;\
        /else \
            /echo $[substr(_desc, _i, _cr-_i)]%;\
            /test _i := _cr + 1%;\
        /endif%;\
        /test _line := _line + 1%;\
    /done%;\
    /if (_line >= 10)\
        /echo ...%;\
    /endif

/alias mapu /map_updateRoom
/def map_updateRoom = \
;    /if (!map_editMode) \
;        /echo Cannot update room. Not in map edit mode.%;\
;        /return%;\
;    /endif%;\
    /let _roomId=%{1}%;\
    /if (_roomId =~ "" & getVar("map.currentRoom.guess") !~ "") \
        /test _roomId := getVar("map.currentRoom.guess")%;\
    /endif%;\
    /if (_roomId =~ "") \
        /echo Cannot update room with no id. <$[getVar("map.currentRoom.guess")]>%;\
        /return%;\
    /else \
        /echo Updating room %{_roomId}%;\
    /endif%;\
    /let _name=$[util_getVar("map.currentRoom.name")]%;\
;    /let _name=$[redisGet("currentRoom:name")]%;\
;    /let _desc=$[map_getDescWithRedis()]%;\
    /let _desc=$[util_getVar("map.currentRoom.description")]%;\
    /let _rdesc=$[replace(char(10), '\\n', _desc)]%;\
    /let _sql=%;\
    /test _sql := strcat("UPDATE [ObjectTbl] SET [Name] = '", sqlite_escapeSql(_name), "' WHERE [ObjID] = ", _roomId)%;\
;    /echo Update name: %{_sql}%;\
    /let _update=%;\
    /test _update := sqlite_rawQuery(map_mapFile, _sql)%;\
    /test _sql := strcat("UPDATE [ObjectTbl] SET [Desc] = '", sqlite_escapeSql(_rdesc), "' WHERE [ObjID] = ", _roomId)%;\
;    /echo Update: %{_update}%;\
;    /echo Update description: %{_sql}%;\
    /test _update := sqlite_rawQuery(map_mapFile, _sql)%;\
;    /echo Update: %{_update}%;\
;    /echo Updated Room:%;\
;    /map_dumpRoomInfo %{_roomId}%;\
    /test 1

/def map_roomCapturedWithRedis = \
    /let _name=%;\
    /let _desc=%;\
    /test _name := redisGet("currentRoom:name")%;\
    /test _desc := map_getDescWithRedis()%;\
;    /echo Name: %{_name}%;\
;    /echo Description:%;\
;    /echo %{_desc}%;\
    /test 0

/def map_getDescWithRedis = \
    /let _desc=%;\
    /let _lines=$[redisLLen("currentRoom:description")]%;\
    /for i 1 %{_lines} \
        /test _desc := strcat(_desc, redisLIndex("currentRoom:description", i-1), char(10))%;\
;    /echo Desc from redis:%;\
;    /echo %{_desc}%;\
    /result _desc

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

/alias mo /map_open %{*}
/def map_open = \
    /let _sql=$[strcat("SELECT Param FROM ExitTbl JOIN DirTbl ON DirType = DirTbl.DirID-1 WHERE FromID = '", sqlite_escapeSql(util_getVar("map.currentRoom.id")), "' AND Param <> ''")]%;\
    /if ({#}) \
        /let _dir=%{1}%;\
        /test _sql := strcat(_sql, " AND DirName LIKE '", sqlite_escapeSql(_dir), "%%'")%;\
    /endif%;\
    /test _sql := strcat(_sql, " LIMIT 1")%;\
;    /echo Query: %{_sql}%;\
    /let _r=$[map_rawQuery(_sql)]%;\
;    /echo Result: %{_r}%;\
    /if (_r =~ '') \
        /if ({#}) \
            open %{*}%;\
        /else \
            /echo Could not find any matching doors.%;\
        /endif%;\
    /else \
        open %{_r}%;\
    /endif

/def map_guessRoomFrom = \
    /let _roomId=%{1}%;\
    /let _lastDir=%{2}%;\
    /let _sql=$[strcat("SELECT [ToID] FROM ExitTbl JOIN DirTbl ON DirType = DirTbl.DirID-1 WHERE FromID = '", sqlite_escapeSql(_roomId), "' AND DirName LIKE '", _lastDir, "%';")]%;\
;    /echo SQL: %{_sql}%;\
    /let _r=$[map_rawQuery(_sql)]%;\
;    /echo Result: %{_r}%;\
    /result _r

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
    /else \
        /map_path_repathIfNecessary%;\
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

/def map_path_repathIfNecessary = \
    /let _len=$(/length $[getVar("map.moveQueue")])%;\
    /let _targetRoomId=$[getVar("map.path.target.roomId")]%;\
    /if (_len == 0 & _targetRoomId !~ "") \
        /echo Move queue not empty with target room.%;\
        /if (getVar("map.path.retryCount")) \
            /test setVar("map.path.retryCount", getVar("map.path.retryCount")-1)%;\
            /map_go%;\
        /else \
            /echo Path target not reached, but retry count used up.%;\
            /beep%;\
        /endif%;\
    /endif


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

/util_addListener combat_detected map_queue_clear
/def map_queue_clear = \
    /test setVar("map.moveQueue", "")

/def -mregexp -t"^Your mount is too exhausted\.$" map_mountExhausted = \
    /map_queue_pop

/def -mregexp -t"^Alas, you cannot go that way\.\.\.$" map_cannotGoThatWay = \
    /map_queue_pop

/def -mregexp -t"^You need a boat to go there\.$" map_youNeedABoatToGoThere = \
    /map_queue_pop

/def -mregexp -t"^You can't ride in there\.$" map_cannotRideInThere = \
    /map_queue_pop

/def -mregexp -t"^(.*) seems to be closed\.$" map_closed_door = \
    /map_queue_pop%;\
    /map_path_repathIfNecessary

/def map_queue_pop = \
    /let _val=$(/car $[getVar("map.moveQueue")])%;\
    /setVar map.moveQueue $(/cdr $[getVar("map.moveQueue")])%;\
    /result _val

