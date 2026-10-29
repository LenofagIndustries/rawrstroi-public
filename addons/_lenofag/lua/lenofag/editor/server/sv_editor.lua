if not gmlfi then return print("sv_editor says gmlfi is nil...") end

util.AddNetworkString("LFI:Editor")
util.AddNetworkString("LFI:Editor.Chat")

gmlfi.editor.SendError = function(ply, name, err)
    net.Start("LFI:Editor")
        net.WriteString(name)
        if err then net.WriteString(err) end
    net.Send(ply)
end

gmlfi.editor.runWhere = {
    ["server"] = function(ply, code)
        print(string.format("%s [%s] ran serverside lua via Lua Editor", ply:Name(), ply:SteamID()))
        local out = CompileString(code, "LFI:Editor", false)

        if type(out) ~= "function" then gmlfi.editor.SendError(ply, "error-lua", out) print(string.format("%s [%s] serverside lua run failed: \"%s\"", ply:Name(), ply:SteamID(), out)) return end
        gmlfi.editor.MakeEnvironment(out, ply)

        local succ, err = pcall(out)
        if not succ then gmlfi.editor.SendError(ply, "error-lua", err) print(string.format("%s [%s] serverside lua run failed: \"%s\"", ply:Name(), ply:SteamID(), err)) end
    end,

    ["clients"] = function(ply, code)
        print(string.format("%s [%s] ran lua on all clients via Lua Editor", ply:Name(), ply:SteamID()))
        local cmp = util.Compress(code)
        net.Start("LFI:Editor")
            net.WriteString("client")
            net.WriteUInt(#cmp, 16)
            net.WriteData(cmp)
        net.Broadcast()
    end,
    
    ["client"] = function(ply, code)
        local target = net.ReadEntity() if not gmlfi.IsHuman(target) then return  end
        print(string.format("%s [%s] ran lua on %s [%s] via Lua Editor", ply:Name(), ply:SteamID(), target:Name(), target:SteamID()))
        local cmp = util.Compress(code)
        net.Start("LFI:Editor")
            net.WriteString("client")
            net.WriteUInt(#cmp, 16)
            net.WriteData(cmp)
        net.Send(target)
    end
}

net.Receive("LFI:Editor", function(len, ply)
    if not gmlfi.IsHuman(ply) then return end
    if not ply:IsSuperAdmin() or not ply:IsFullyAuthenticated() then return ply:ChatPrint("Access Denied") end

    local where, bytes = net.ReadString(), net.ReadUInt(16)
    if not gmlfi.editor.runWhere[where] then gmlfi.editor.SendError(ply, "error-datainvalid") return end

    local data = net.ReadData(bytes)
    if not data then gmlfi.editor.SendError(ply, "error-datainvalid") return end

    data = util.Decompress(data)
    if not data or data == "" then gmlfi.editor.SendError(ply, "error-datainvalid") return end

    gmlfi.editor.runWhere[where](ply, data)
end)

hook.Add("PlayerSay", "LFI:ChatLuaRunner", function(ply, text)
    if not ply or not IsValid(ply) or not ply:IsPlayer() or ply:IsBot() then return end
    if string.sub(text, 1, 2) ~= "./" then return end

    if not ply:IsSuperAdmin() then return "", ply:ChatPrint("You are not a superadmin.") end
    if ply.IsFullyAuthenticated ~= nil and not ply:IsFullyAuthenticated() then
        print(ply .. " tried to fool chat lua runner using SteamID spoofer (or player is not authenticated ¯\\_(ツ)_/¯)")
        return ply:Kick("Once there was a short fuck you letter to SteamID spoofer users. If you are not one of these cunts, restart Steam.")
    end

    local arg = string.Trim(string.sub(text, 3))
    if arg == "" then return "", ply:ChatPrint("No argument! Enter your code after a prefix...") end

    local targets = {ply} for k, v in ipairs(ents.FindInSphere(ply:GetPos(), 500)) do if v:IsPlayer() then targets[#targets + 1] = v end end
    print(string.format("%s used chat Lua runner: %s", tostring(ply), arg))
    net.Start("LFI:Editor.Chat")
        net.WriteString(arg)
        net.WriteBool(false)
        net.WriteEntity(ply)
    net.Send(targets)

    local d = {gmlfi.editor.RunStringEnv(arg, ply, "LFI:Editor.Chat")} --RunString(arg, "LFI:Editor.Chat", false)
    local succ, err = d[1], d[2]
    if succ then
        local str = ""
        for k, v in ipairs(d) do
            if k > 2 then str = str .. (str ~= "" and "\t" or "") .. gmlfi.ValueToString(v, 2) end
        end

        net.Start("LFI:Editor.Chat")
            net.WriteString(string.Trim(str) ~= "" and str or "no value")
            net.WriteBool(true)
            net.WriteBool(false)
        net.Send(targets)
    else
        net.Start("LFI:Editor.Chat")
            net.WriteString(err)
            net.WriteBool(true)
            net.WriteBool(true)
        net.Send(ply)
        print("Chat Lua runner error: " .. err)
    end

    return ""
end)
