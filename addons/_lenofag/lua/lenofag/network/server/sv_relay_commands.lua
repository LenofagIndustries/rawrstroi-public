--if not LRELAY then return end

local runLua = function(code, author)
    LRELAY.Log(string.format("%s#%s (%s) ran serverside Lua: %s", author.username, author.discriminator, author.id, code))
    local e = RunString(code, "LFI:LRELAYS:Commands", false)
    if e then print(e) end
end

hook.Add("LRelayS:Message.Console", "LFI:LRELAYS:Commands", function(message, author)
    if string.sub(message, 1, 2) == "./" then runLua(string.sub(message, 3), author) return true end
    if string.sub(message, 1, 8) == "lua_run " then runLua(string.sub(message, 9), author) return true end
    if string.sub(message, 1, 1) == "!" then
        local args = string.Explode(" ", string.sub(message, 2))
        LRELAY.Log(string.format("%s#%s (%s) used lf %s", author.username, author.discriminator, author.id, table.concat(args, " ")))
        RunConsoleCommand("lf", unpack(args))
    return true end
    if string.sub(message, 1, 1) == ";" then return true end -- just commenting or smth
end)
