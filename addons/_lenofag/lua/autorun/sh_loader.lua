if not gmlfi then return error("CRITICAL: loader says gmlfi is nil!!!") end

gmlfi.loader = gmlfi.loader or {}
gmlfi.loader.dirname = "lenofag"
gmlfi.loader.loadedalready = gmlfi.loader.loadedalready or {}

if SERVER then util.AddNetworkString("LFI:Loader.Reload") end

local states = {server = true, client = true, shared = true}
gmlfi.loader.Include = function(filename, dir)
    local folders = string.Explode("/", dir)
    local state, name = folders[#folders - 1], ""
    if not state or state == "" then return end

    if not states[state] then state = "shared" name = state
    else name = folders[#folders - 2] end

    if gmlfi.loader.loadedalready[dir .. filename] then print(string.format("sh_loader.lua: [%s] %s loaded before, ignoring", name, filename)) return end
    gmlfi.loader.loadedalready[dir .. filename] = state

    if state == "server" then
        include(dir .. filename) print(string.format("sh_loader.lua: [%s] loading %s in SERVER state", name, filename))
    end

    if state == "shared" then
        if SERVER then AddCSLuaFile(dir .. filename) end
        include(dir .. filename) print(string.format("sh_loader.lua: [%s] loading %s in SHARED", name, filename))
    end

    if state == "client" then
        if SERVER then AddCSLuaFile(dir .. filename) end
        if CLIENT then include(dir .. filename) end
        print(string.format("sh_loader.lua: [%s] loading %s in CLIENT state", name, filename))
    end
end

gmlfi.loader.IncludeDir = function(dir)
    dir = dir .. "/"

    local files, dirs = file.Find(dir .. "*", "LUA")

    for _, filename in ipairs(files) do
        if string.GetExtensionFromFilename(filename) == "lua" then gmlfi.loader.Include(filename, dir) end
    end

    for _, dirname in ipairs(dirs) do
        gmlfi.loader.IncludeDir(dir .. dirname)
    end
end

gmlfi.loader.Load = function(dirname)
    if dirname and not file.Exists(dirname, "LUA") then return print(string.format("sh_loader.lua: \"%s\" does not exists, skipped", dirname)) end
    print(string.format("sh_loader.lua: loading from \"%s\"...", dirname or gmlfi.loader.dirname))
    gmlfi.loader.IncludeDir(dirname or gmlfi.loader.dirname)
    print("sh_loader.lua: done loading " .. (dirname or gmlfi.loader.dirname))
end

if SERVER then
    concommand.Add("gmlfi_loader_reload", function(ply)
        if ply and IsValid(ply) and ply:IsPlayer() then return end
        gmlfi.loader.Load()
        net.Start("LFI:Loader.Reload") net.Broadcast()
    end)
end

if CLIENT then
    net.Receive("LFI:Loader.Reload", function()
        timer.Simple(2, function()
            print("sh_loader.lua: received reload request, reloading...")
            gmlfi.loader.Load()
            gmlfi.loader.Load("lfadmin")
        end)
    end)
end

gmlfi.loader.Load()
gmlfi.loader.Load("lfadmin")