-- Find a path between two rooms. They are given on the command line
--
-- lua map_path.lua <mapDbFile> <fromId> <toId>
--

local data = {}
function dataForNode(nodeId)
    nodeId = tostring(nodeId)
    if data[nodeId] == nil then
        data[nodeId] = {
            distance = math.huge,
            previous = nil
        }
    end
    return data[nodeId]
end

function dumpTable(name, t)
    print("Dumping " .. name .. " {")
    for i,j in pairs(t) do
        print("  " .. i .. " : " .. tostring(j))
    end
    print("}")
end

function dumpData(d)
    print("Data: {")
    print(d)
    for i,j in pairs(d) do
        print("  " .. i .. " : {")
        for k,l in pairs(j) do
            print("    " .. k .. " : " .. l)
        end
        print("  }")
    end
    print("}")
end

function Dijkstra(start, finish)
    start = tostring(start)
    finish = tostring(finish)

    --print("Pathing from " .. start .. " to " .. finish)
    local open = {}
    local closed = {}
    local iteration = 1
--    local maxIterations = 500

    open[tostring(start)] = true
    dataForNode(start).distance = 0

    while true do
        local best = nil
        for node in pairs(open) do
            if not best or dataForNode(node).distance < data[best].distance then
                best = node
            end
        end

        if (best ~= nil) then
--            print("best is now : " .. best)
        else
--            print("best is nil?!")
        end

        -- We have a solution!
        if tostring(best) == tostring(finish) then break end

        -- Perhaps there was no connection?
        if not best then 
--            dumpTable("open", open)
--            dumpTable("closed", closed)
--            dumpData(data)
            return 
        end

        for _, neighbor in ipairs(nodeNeighbors(best)) do
            -- print("_: " .. _)
--            print("Checking neighbor: " .. neighbor.roomId .. " via exit " .. neighbor.exitId)
            -- Ignore elements already in the closed set.
            if not closed[neighbor.roomId] then
                local newdist = dataForNode(best).distance + neighbor.cost --distanceFrom(best,neighbor)
                if newdist < dataForNode(neighbor.roomId).distance then
                    dataForNode(neighbor.roomId).viaLink = neighbor.exitId
                    dataForNode(neighbor.roomId).previous = best
                    dataForNode(neighbor.roomId).distance = newdist
                    dataForNode(neighbor.roomId).dirName = neighbor.dirName
                    dataForNode(neighbor.roomId).doorName = neighbor.doorName
                    dataForNode(neighbor.roomId).doorCmd = neighbor.doorCmd
                end
                open[tostring(neighbor.roomId)] = true
            end
        end

        closed[best] = true
        open[best] = nil

--        if iteration >= maxIterations then return end
        iteration = iteration + 1
    end

    -- Ok, so if we're here, we should have a path.

--    dumpData(data)

    local path = {}
    local at = finish
    while at ~= start do
        table.insert(path, 1, dataForNode(at))
        at = dataForNode(at).previous
    end

    return path
end


-- Get the database stuff up and running...
--
local dbDriver = require "luasql.sqlite3"
local dbEnv = assert(dbDriver.sqlite3())
-- local dbConn = assert(dbEnv:connect("/Users/wilh/tf-npm/data/map.sqlite"))
local dbConn = assert(dbEnv:connect(arg[1]))

function nodeNeighbors(nodeId)
--    print ("Finding new nodeNeighbors for " .. nodeId)
    local neighbors = {}
    local cur = assert(dbConn:execute("SELECT ExitID, ToID, DirName, ExitTbl.Name, ExitTbl.Param, Cost FROM ExitTbl JOIN DirTbl ON (DirType+1) = DirID JOIN ObjectTbl ON ObjID = ToID WHERE FromID = " .. nodeId))
    local row = cur:fetch({}, "a")
    while row do
--        print(" -> " .. row.ToID)
--        dumpTable("row", row)
        local rowCost = math.max(1,row.Cost)
        if (row.Param and row.Param ~= "") then
            rowCost = rowCost * 10
            -- print("doorName is '" .. row.Param .. "'. Making more expensive.")
        end
        table.insert(neighbors, {
            exitId = tostring(row.ExitID),
            roomId = tostring(row.ToID),
            dirName = tostring(row.DirName),
            doorCmd = tostring(row.Name),
            doorName = tostring(row.Param),
            cost = rowCost
        })
        row = cur:fetch(row, "a")
    end
    cur:close()
    return neighbors
end

function distanceFrom(fromId, toId)
    return 1
end

local dirMap = {
    north = "n",
    south = "s",
    east  = "e",
    west  = "w",
    up    = "u",
    down  = "d"
}

function addEdgeCommands(edge, cmds)
-- dumpTable("Edge", edge)
    if edge.doorCmd == "call" then
        table.insert(cmds, ";" .. "call" .. ";")
    elseif edge.doorName and edge.doorName ~= "" then
        table.insert(cmds, ";" .. "open" .. " " .. edge.doorName .. ";")
    end
    local dir = dirMap[edge.dirName]
    if not dir then
        dir = edge.dirName
    end
    table.insert(cmds, dir)
end

function path2Commands(path)
    local cmds = {}
    local edgeCount = 0
    for _, edge in pairs(path) do
        addEdgeCommands(edge, cmds)
        edgeCount = edgeCount + 1
    end
    local dupCount = 0
    local lastCmd = nil
    local totalCmd = ""
    for _, cmd in pairs(cmds) do
        if cmd == lastCmd then
            dupCount = dupCount + 1
        else
            if lastCmd then
                if dupCount > 1 then
                    totalCmd = totalCmd .. dupCount
                end
                totalCmd = totalCmd .. lastCmd
            end
            lastCmd = cmd
            dupCount = 1
        end
    end
    if dupCount > 1 then
        totalCmd = totalCmd .. dupCount
    end
    totalCmd = totalCmd .. lastCmd
    return {
        cmd = totalCmd,
        count = edgeCount
    }
end

function processPathFrom(start, finish)

    local path = Dijkstra(start, finish)

    if path then
    --[[    for i,j in pairs(path) do
            print(i .. " : {")
            for k,l in pairs(j) do
                print("  " .. k .. " : " .. l)
         end
            print "}"
     end
    ]]
        local commands = path2Commands(path)
        print(commands.count .. " " .. start .. " " .. finish .. " " .. commands.cmd)
    else
        print("No Path Found.")
    end
end

local finishIdx = 3

while arg[finishIdx] do
    processPathFrom(arg[2], arg[finishIdx])
    finishIdx = finishIdx + 1
end

-- Clean up
dbConn:close()
dbEnv:close()
