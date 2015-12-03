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
;    /if (_target == util_getVar("mapper.currentRoom.id") \
;        /echo You're already there!%;\
;        /return%;\
;    /endif%;\
;    /let _step=$[mapper_step(mapper_path(_target))]%;\
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
;    /if (_target == util_getVar("mapper.currentRoom.id") \
;        /echo You're already there!%;\
;        /return%;\
;    /endif%;\
;    /let pathInfo=$(/pathTo %{_target})%;\
;    /if (regmatch("^(\d+) (\d+) (\d+) (.+)$", pathInfo)) \
;        /mapper_execute_path %{P4}%;\
;    /else \
;        /echo Could not find path to %{_target}.%;\
;    /endif

;
; Given a path, spam each component immediately.
;
;/def mapper_execute_path = \
;    /let _bit=%;\
;    /let _rest=%{*}%;\
;    /while (_rest !~ "") \
;        /let _semiIdx=%;\
;        /test _semiIdx := strstr(_rest,";")%;\
;        /if ( _semiIdx == -1) \
;            /test _bit := _rest%;\
;            /test _rest := ""%;\
;        /else \
;            /test _bit := substr(_rest, 0, _semiIdx)%;\
;            /test _rest := substr(_rest, _semiIdx + 1)%;\
;        /endif%;\
;        /if (_bit !~ "") \
;            /echo /send -h %_bit%;\
;        /endif%;\
;    /done

;
; Run the pathing algorithm and return just the path component.
;
;/def mapper_path = \
;    /let _pathInfo=$(/mapper_findPath %1)%;\
;    /if (regmatch("^(\d+) (\d+) (\d+) (.+)$", _pathInfo)) \
;        /return {P4}%;\
;    /else \
;        /return 0%;\
;    /endif

;
; Execute the Lua pathing algorithm.
;
/def mapper_findPath = \
    /if ({#} > 1) \
        /let _fromId=%{1}%;\
        /let _toOptions=%{-1}%;\
    /elseif ({#} == 1) \
        /if (!mapper_isCurrentRoomKnown()) \
            /echo Cannot execute path algorithm. We don't know where we are.%;\
            /return%;\
        /endif%;\
        /let _fromId=%{mapper_currentRoomId}$;\
        /let _toOptions=%{1}%;\
    /endif%;\
    /let _pathScriptLoc=%{TF_NPM_MODULES_ROOT}/tf-mapper/lua/map_path.lua%;\
    /let _r=$(/quote -S -decho !lua %{_pathScriptLoc} %{_fromId} %{_toOptions})%;\
    /result _r

;/def mapper_step = \
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

