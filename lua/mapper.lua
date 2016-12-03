--
-- General Mapper Functions
--

local cmd = arg[1]
if not cmd then
    io.stderr:write("Please specify a command.\n")
    os.exit(1)
end

function command_map()
    print("command_map")
    for line in io.lines() do
        print("you send: " .. line)
    end
-- 
--     local bufSize = 2^13
--     input = io.read(bufSize)
--     while input do
--         print("you sent: " .. input)
--         input = io.read(bufSize)
--     end
    print("end of input received")
end

function command_path()
    print("command_path")
end

if cmd == "map" then
    command_map()
elseif cmd == "path" then
    command_path()
else
    io.stderr:write("Unknown command '" .. cmd .. "'.\n")
    os.exit(2)
end

