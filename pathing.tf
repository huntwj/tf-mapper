;;
;; tf-mapper/pathing.tf
;;
;; Map functions supporting path-finding between multiple rooms.
;;
/loaded __tf_mapper_pathing__

;
; Find a path toward a room and take the first step.
;
; Currently, only a roomId is accepted.
;
; /step <room>
;
;/def step = \
;    /let _target=%{1}%;\
;    /if (_target == util_getVar("map.currentRoom.id") \
;        /echo You're already there!%;\
;        /return%;\
;    /endif%;\
;    /let _step=$[map_step(map_path(_target))]%;\
;    /echo Stepping toward %{_target} : %_step%;\
;    /echo /send -h %_step

;
; Find a path toward a room and spam the entire path.
;
; Current, only a roomId is accepted.
;
; /go <room>
;
;/def go = \
;    /let _target=%{1}%;\
;    /if (_target == util_getVar("map.currentRoom.id") \
;        /echo You're already there!%;\
;        /return%;\
;    /endif%;\
;    /let pathInfo=$(/pathTo %{_target})%;\
;    /if (regmatch("^(\d+) (\d+) (\d+) (.+)$", pathInfo)) \
;        /map_execute_path %{P4}%;\
;    /else \
;        /echo Could not find path to %{_target}.%;\
;    /endif

;
; Given a path, spam each component immediately.
;
/def map_executePath = \
    /let _bit=%;\
    /let _rest=%{*}%;\
    /while (_rest !~ "") \
        /let _semiIdx=%;\
        /test _semiIdx := strstr(_rest,";")%;\
        /if ( _semiIdx == -1) \
            /test _bit := _rest%;\
            /test _rest := ""%;\
        /else \
            /test _bit := substr(_rest, 0, _semiIdx)%;\
            /test _rest := substr(_rest, _semiIdx + 1)%;\
        /endif%;\
        /if (_bit !~ "") \
            /send -h %_bit%;\
        /endif%;\
    /done

;
; Run the pathing algorithm and return just the path component.
;
/def map_path = \
    /let _pathInfo=$(/map_findPath %{*})%;\
    /if (regmatch("^(\d+) (\d+) (\d+) (.+)$", _pathInfo)) \
        /result {P4}%;\
    /else \
        /result 0%;\
    /endif

;
; Execute the Lua pathing algorithm.
;
/def map_findPath = \
    /if ({#} > 1) \
        /let _fromId=%{1}%;\
        /let _toOptions=%{-1}%;\
    /elseif ({#} == 1) \
        /let _fromId=$[util_getVar("map.currentRoom.id")]%;\
        /if (_fromId =~ "") \
            /echo -aCyellow Cannot execute path algorithm. We don't know where we are.%;\
            /result -1%;\
        /endif%;\
        /let _toOptions=%{*}%;\
    /endif%;\
    /let _pathScriptLoc=%{TF_NPM_MODULES_ROOT}/tf-mapper/lua/map_path.lua%;\
    /let _r=$(/quote -S -decho !lua %{_pathScriptLoc} %{_fromId} %{_toOptions})%;\
    /result _r

;/def map_step = \
;    /let idx=%;\
;    /let path=%{1}%;\
;    /test idx := 0%;\
;    /if (strlen(path) == 0) \
;        /echo No path?%;\
;        /return%;\
;    /else \
;        /let dir=%;\
;        /test dir := strchr(path, "newsud")%;\
;        /if (dir != -1) \
;            /return substr(path, dir, 1)%;\
;        /endif%;\
;    /endif

/def map_createPath = \
    /let _pathName=%{1}%;\
    /let _pathVar=$[map_pathVarName(_pathName)]%;\
    /let _pathProgressVar=$[map_pathProgressVarName(_pathName)]%;\
    /let _oldPath=$[map_getPath(_pathName)]%;\
    /let _newPath=%{-1}%;\
    /if (_oldPath !~ _newPath) \
        /test util_setVar(_pathVar, _newPath)%;\
        /test util_setVar(_pathProgressVar, _newPath)%;\
    /else \
        /echo Path %{1} unchanged.%;\
    /endif

/def map_stepPath = \
    /let _pathName=%{1}%;\
    /let _path=$[map_getPath(_pathName)]%;\
    /let _pathProgress=$[map_getPathProgress(_pathName)]%;\
;    /echo Stepping through %{_pathName} : %{_path}%;\
;    /echo Progress is <%{_pathProgress}>%;\
    /let _currentId=$[util_getVar("map.currentRoom.id")]%;\
    /if (_currentId =~ "") \
        /echo -aCyellow Cannot execute step algorithm. We don't know where we are.%;\
        /result -1%;\
    /endif%;\
    /let _next=$(/car %{_pathProgress})%;\
    /if (_next =~ _currentId) \
        /test _next := map_shiftPathProgress(_pathName)%;\
    /endif%;\
    /let _path=$[map_path(_next)]%;\
    /let _firstMove=$[map_firstMoveOfPath(_path)]%;\
    /if (_firstMove !~ "0") \
        /test map_executePath(_firstMove)%;\
    /else \
        /echo -aCred Error calculating first move in path.%;\
    /endif

/def map_nextPath = \
    /let _pathName=%{1}%;\
    /let _path=$[map_getPath(_pathName)]%;\
    /let _pathProgress=$[map_getPathProgress(_pathName)]%;\
;    /echo Stepping through %{_pathName} : %{_path}%;\
;    /echo Progress is <%{_pathProgress}>%;\
    /let _currentId=$[util_getVar("map.currentRoom.id")]%;\
    /if (_currentId =~ "") \
        /echo -aCyellow Cannot execute step algorithm. We don't know where we are.%;\
        /result -1%;\
    /endif%;\
    /let _next=$(/car %{_pathProgress})%;\
    /if (_next =~ _currentId) \
        /test _next := map_shiftPathProgress(_pathName, 0)%;\
    /endif%;\
    /let _path=$[map_path(_next)]%;\
;    /let _firstMove=$[map_firstMoveOfPath(_path)]%;\
    /result _path
;    /if (_path !~ "0") \
;        /test map_executePath(_path)%;\
;    /else \
;        /echo -aCred Error calculating first move in path.%;\
;    /endif

/def map_path_goNext = \
    /let _pathName=%{1}%;\
    /let _path=$[map_nextPath(_pathName)]%;\
    /test map_executePath(_path)

/def map_pathVarName = \
    /let _path=%{1}%;\
    /let _varName=map.path.$[textencode(_path)]%;\
    /result _varName

/def map_pathProgressVarName = \
    /let _path=%{1}%;\
    /let _varName=map.path.progress.$[textencode(_path)]%;\
    /result _varName

/def map_getPath = \
    /let _pathName=%{1}%;\
    /let _pathVar=$[map_pathVarName(_pathName)]%;\
    /result util_getVar(_pathVar)

/def map_resetPath = \
    /let _pathName=%{1}%;\
    /let _progressName=$[map_pathProgressVarName(_pathName)]%;\
    /let _path=$[map_getPath(_pathName)]%;\
    /test util_setVar(_progressName, _path)

/def map_pushPath = \
    /let _pathName=%{1}%;\
    /let _roomId=%{2}%;\
    /let _varName=$[map_pathProgressVarName(_pathName)]%;\
    /let _pathProgress=$[map_getPathProgress(_pathName)]%;\
    /let _first=$(/car %{_pathProgress})%;\
    /if (_first !~ _roomId) \
        /test util_setVar(_varName, strcat(_roomId, " ", _pathProgress))%;\
        /map_getPathProgress %{_varName}%;\
    /endif

/def map_getPathProgress = \
    /let _pathName=%{1}%;\
    /let _pathProgressVar=$[map_pathProgressVarName(_pathName)]%;\
    /result util_getVar(_pathProgressVar)

/def map_shiftPathProgress = \
    /let _pathName=%{1}%;\
    /let _circular=1%;\
    /if ({#} & {2}) \
        /test _circular := {2}%;\
    /endif%;\
    /let _pathProgress=$[map_getPathProgress(_pathName)]%;\
    /if (_pathProgress =~ "") \
        /test _pathProgress := map_getPath(_pathName)%;\
    /endif%;\
    /let _rest=$(/cdr %{_pathProgress})%;\
    /if (_rest =~ "") \
        /if (_circular) \
            /let _rest=$[map_getPath(_pathName)]%;\
        /else \
            /echo End of path. Please select a new one.%;\
        /endif%;\
    /endif%;\
    /test util_setVar(map_pathProgressVarName(_pathName), _rest)%;\
    /let _pathProgress=$[map_getPathProgress(_pathName)]%;\
    /let _next=$(/car %{_rest})%;\
    /result _next

/def map_firstMoveOfPath = \
    /let _path=%{*}%;\
    /let _moveRegexp=$["^(\d+)?([newsud])"]%;\
    /let _next=%;\
    /while (!regmatch(_moveRegexp, _path) & strlen(_path) > 0) \
        /let _nextSemi=$[strstr(_path, ";", 1)]%;\
        /if (_nextSemi == -1) \
            /test _next := strcat(_next, _path)%;\
            /test _path := ""%;\
        /else \
            /test _next := strcat(_next, substr(_path, 0, _nextSemi + 1))%;\
            /test _path := substr(_path, _nextSemi + 1)%;\
        /endif%;\
    /done%;\
    /if (strlen(_path) > 0) \
        /test _next := strcat(_next,{P2})%;\
    /endif%;\
    /result _next

/alias go /map_go %{*}
/def map_go = \
    /let _mapPath=$(/map_path %{*})%;\
    /return map_executePath(_mapPath)

/alias mark /map_markRoom %{*}
/def map_markRoom = \
    /let _current=$[util_getVar("map.currentRoom.id")]%;\
    /let _marked=$[util_getVar("map.markRoom.id")]%;\
    /if (_current =~ "" | strstr(_current, " ") != -1) \
        /echo -aCyellow Cannot mark current room. I'm not sure where we are.%;\
    /elseif (_current !~ _marked) \
        /test util_setVar("map.markRoom.id", _current)%;\
        /echo -aCyellow Marking current room (%{_current}).%;\
    /endif

/alias gmark /map_goToMarkedRoom %{*}
/def map_goToMarkedRoom = \
    /let _mark=$[util_getVar("map.markRoom.id")]%;\
    /if (_mark =~ "") \
        /echo -aCyellow No room marked. Cancelling.%;\
    /else \
        /if ({#} > 0) \
            /map_go %{1} %{_mark}%;\
        /else \
            /map_go %{_mark}%;\
        /endif%;\
    /endif

