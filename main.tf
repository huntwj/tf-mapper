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
/def mapper_roomCaptured = \
    /let _name=%{1}%;\
    /let _desc=%{2}%;\
    /let _roomId=$[mapper_findRoomByName(_name)]%;\
    /if (strstr(_roomId, " ") != -1) \
        /test _roomId := mapper_findRoomByDesc(_desc, _roomId)%;\
    /endif%;\
    /quote -S -decho !/Users/wilh/Desktop/SendMapEvent %_roomId%;\
    /echo Room ID: %{_roomId}

;
; Attempt to find a room by looking up its name.
;
/def mapper_findRoomByName = \
    /let _roomName=%{*}%;\
    /let _sql=%;\
    /test _sql := strcat("SELECT [ObjID] FROM [ObjectTbl] WHERE [Name] = '", sqlite_escapeSql(_roomName), "'")%;\
    /return sqlite_rawQuery(mapper_mapFile, _sql)

/def mapper_findRoomByDesc = \
    /let _descClause=$[mapper_getDescClause({1})]%;\
    /let _sql=%;\
    /test _sql := "SELECT [ObjID] FROM [ObjectTbl] WHERE "%;\
    /if ({#} == 2) \
        /let _roomList=$[replace(" ", ", ", {2})]%;\
        /test _sql := strcat(_sql, "[ObjID] IN (", _roomList, ") AND ")%;\
    /endif%;\
    /test _sql := strcat(_sql, _descClause)%;\
    /return sqlite_rawQuery(mapper_mapFile, _sql)

/def mapper_getDescClause = \
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
        /test _likeBit := strcat("[Desc] LIKE '%%", substr(_desc, _start, _end - _start), "%%'")%;\
        /test _likeClause := strcat(_likeClause, " AND ", _likeBit)%;\
        /test _start := _end + 1%;\
        /test _end := strstr(_desc, char(10), _start)%;\
    /done%;\
    /return _likeClause

