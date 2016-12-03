--
-- Get the database stuff up and running...
--
local dbDriver = require "luasql.sqlite3"
local dbEnv = assert(dbDriver.sqlite3())
local dbConn = assert(dbEnv:connect("/Users/wilh/tf/wotmud/map.dbm"))

local rooms = {}

function lookupRoomById(roomId)
    print("Looking up roomId: " .. roomId)
    local cur = assert(dbConn:execute("SELECT * FROM ObjectTbl WHERE ObjID = " .. roomId))
    local row = cur:fetch({}, "a")
    print("Got row")
    local room = nil
    if row then
        print("it was not nil")
        room = {
            id = row.ObjID,
            name = row.Name,
            x = row.X,
            y = row.Y,
            z = row.Z,
            color = row.Color,
            cost = row.Cost,
        }
    end
    cur:close()
    return room
end

function roomForId(roomId)
    roomId = tostring(roomId)
    if not rooms[roomId] then
        room = lookupRoomById(roomId)
        print "room returned"
        if not room then
            print "but it was nil?"
        end
        rooms[roomId] = room
    end
    return rooms[roomId]
end

function findNeighbors(room)
    roomId = room.id
    local cur = assert(dbConn:execute("SELECT R.ObjID, R.Name, R.X, R.Y, R.Z FROM ObjectTbl R JOIN ExitTbl ON ExitTbl.ToID = R.ObjID WHERE ExitTbl.FromID = " .. roomId))
    local row = cur:fetch({}, "a")
    while row do
        print("Row: {")
        for k, v in pairs(row) do
            print("  " .. k .. ": " .. v)
        end
        row = cur:fetch(row, "a")
    end
end

function drawRoom1(room)
    io.write("+-+")
end

function findNearbyRooms(currentRoomId)

end

function createLogicalMap(width, height)

end

function drawMap(roomId, width, height)
    local zoom = 3 -- Each room/link will take 3 vertical spaces.
    local logicalMap = createLogicalMap(width / ((zoom-1)*2)+1, height / 3)

    room = lookupRoomById(roomId)
    if room then
      print("room: {");
      for k,v in pairs(room) do
          print("  " .. k .. ": " .. v)
      end
      print("}")

      findNeighbors(room)
  else
      print "Nil room?"
  end
end

local currentRoomId = arg[1]
if not currentRoomId then
    print "Please specify a current or central room ID."
end

local width = arg[2]
if not width then
    width = 80
end

local height = arg[3]
if not height then
    height = width / 2
end

drawMap(currentRoomId, width, height)

--
-- Clean up
--
dbConn:close()
dbEnv:close()
