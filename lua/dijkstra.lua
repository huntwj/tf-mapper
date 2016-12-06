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

function Dijkstra(nodeNeighbors, start, finish)
    start = tostring(start)
    finish = tostring(finish)

    print("Pathing from " .. start .. " to " .. finish)
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
           print("best is now : " .. best)
        else
           print("best is nil?!")
        end

        -- We have a solution!
        if tostring(best) == tostring(finish) then break end

        -- Perhaps there was no connection?
        if not best then
           dumpTable("open", open)
           dumpTable("closed", closed)
           dumpData(data)
            return
        end

        for _, neighbor in ipairs(nodeNeighbors(best)) do
            print("_: " .. _)
           print("Checking neighbor: " .. neighbor.roomId .. " via exit " .. neighbor.exitId)
            -- Ignore elements already in the closed set.
            if not closed[neighbor.roomId] then
                local newdist = dataForNode(best).distance + neighbor.cost --distanceFrom(best,neighbor)
                print("newdist: " .. newdist)
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

   -- dumpData(data)

    local path = {}
    local at = finish
    while at ~= start do
        table.insert(path, 1, dataForNode(at))
        at = dataForNode(at).previous
    end

    return path
end

return Dijkstra
