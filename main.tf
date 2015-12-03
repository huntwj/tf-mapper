;;
;; tf-mapper/main.tf
;;
/loaded __tf_mapper_main__

/require tf-mapper/pathing.tf
/require tf-sqlite/main.tf

;
; This should be called by a mud-specific map helper that captures room
; details to pass into the mapper.
;
/def mapper_roomCaptured = \
    /let _name=%{1}%;\
    /let _desc=%{2}%;\
    /let _roomId=$[mapper_findRoomByName(_name)]%;\
    /echo Room ID: %{_roomId}

;
; Attempt to find a room by looking up its name.
;
/def mapper_findRoomByName = \
    /let _roomName=%{*}%;\
    /let _sql=%;\
    /test _sql := strcat("SELECT [ObjId] FROM [ObjectTbl] WHERE [Name] = '", sqlite_escapeSql(_roomName), "'")%;\
    /return sqlite_rawQuery(mapper_mapFile, _sql)

