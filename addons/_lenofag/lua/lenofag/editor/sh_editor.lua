if not gmlfi then return print("sh_editor says gmlfi is nil...") end

gmlfi.editor = gmlfi.editor or {}

gmlfi.editor.MakeEnvironment = function(fn, ply)
    local trace = ply:GetEyeTrace()
    local env = {me = ply, trace = trace, here = ply:GetPos(), there = trace.HitPos, this = trace.Entity, wep = ply:GetActiveWeapon()}
    for k, v in ipairs(player.GetAll()) do
        local n = string.gsub(v:Name(), " ", "")
        if not env[n] and not _G[n] and n ~= "_G" then env[n], env[string.lower(n)] = v, v end
    end
    return debug.setfenv(fn, setmetatable(env, {__index = _G}))
end

gmlfi.editor.RunStringEnv = function(code, ply, name)
    if not code then return false, "(code) expected string, got " .. type(code) end
    local out = CompileString("return " .. code, name or "LFI:Editor", false)
    if type(out) ~= "function" then out = CompileString(code, name or "LFI:Editor", false) end
    if type(out) ~= "function" then return false, out, print(string.format("%s [%s] serverside lua run failed: \"%s\"", ply:Name(), ply:SteamID(), out)) end
    gmlfi.editor.MakeEnvironment(out, ply)

    local d = {pcall(out)}
    if not d[1] then return false, d[2], print(string.format("%s [%s] serverside lua run failed: \"%s\"", ply:Name(), ply:SteamID(), d[2])) end
    return true, unpack(d)
end
