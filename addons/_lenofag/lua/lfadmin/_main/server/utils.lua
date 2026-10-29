util.AddNetworkString("LFAdmin.Log")

local types = {
    Entity = "Entity",
    Player = "Entity",
    number = {"Int", 32},
    string = "String",
}

LFAdmin.LogPlayer = function(ply, message, ...)
    local ib = type(ply) == "boolean"
    LFAdmin.ADMIN_ONLY = LFAdmin.ADMIN_ONLY or not ib or not ply
    if not ib and isentity(ply) and LFAdmin.IsConsole(ply) then
        LFAdmin.TO_CONSOLE = ply == Entity(0)
        LFAdmin.LogFormat(message, ...)
        LFAdmin.ADMIN_ONLY, LFAdmin.CHAT_PREFIX, LFAdmin.TO_CONSOLE = nil, nil, nil
    return end
    if ib then
        for k, v in ipairs({message, ...}) do
            if type(v) == "Player" and v:GetNWBool("LFI:Hide") then 
                LFAdmin.CHAT_PREFIX = "Hidden" 
                ply = v 
                ib = nil 
            end
        end
    end
    net.Start("LFAdmin.Log")
    net.WriteUInt(CurTime(), 32)
    net.WriteBool(LFAdmin.CHAT_PREFIX ~= nil)
    if LFAdmin.CHAT_PREFIX ~= nil then net.WriteString(LFAdmin.CHAT_PREFIX) end
    net.WriteBool(LFAdmin.ADMIN_ONLY)
    if not ... and type(message) == "string" then net.WriteBool(false) net.WriteString(message) else
        net.WriteBool(true) local a = {message, ...}
        local ty = {} for k, v in ipairs(a) do ty[k] = type(v) == "table" and #v > 0 and "#" .. #v or (type(v)) end net.WriteString(table.concat(ty, ","))
        for k, v in ipairs(a) do
            if type(v) == "table" and #v > 0 then
                for k, v in ipairs(v) do net.WriteEntity(v) end
            else
                local tt = types[type(v)]
                net["Write" .. (tt and (type(tt) == "table" and tt[1] or tt) or "String")](tt and v or tostring(v), type(tt) == "table" and tt[2])
            end
        end
    end
    if ib then net[ply and "Broadcast" or "Send"](not ply and LFAdmin.GetStaff()) LFAdmin.LogFormat(message, ...) else net.Send(ply) end
    LFAdmin.ADMIN_ONLY, LFAdmin.CHAT_PREFIX = nil, nil
end

LFAdmin.LogPlayerPrefixed = function(ply, prefix, message, ...)
    LFAdmin.CHAT_PREFIX = prefix
    LFAdmin.LogPlayer(ply, message, ...)
end

LFAdmin.LOG_ENABLED = true ------------------------------------------------------------------------

local queue = {}
LFAdmin.SendToLogs = function(text)
    if not LFAdmin.LOG_ENABLED then return end
    queue[#queue + 1] = text
end

local fail = function() timer.Adjust("LFAdmin.SendToLogs", 60) end
timer.Create("LFAdmin.SendToLogs", 1, 0, function()
    if next(queue) ~= nil then
        HTTP({
            method = "post", type = "application/json; charset=utf-8",
            url = "https://a.rawr.party/dswebhook",
            body = util.TableToJSON({
                url = "[...]",
                content = {
                    content = table.concat(queue, "\n"),
                    allowed_mentions = {parse = {}},
                }
            }),
            success = function(code, body) if code ~= 200 then print("Warning: LFAdmin failed to send logs (" .. code .. "):") print(body) fail() else timer.Adjust("LFAdmin.SendToLogs", 1) end end,
            failed = function(err) print("Warning: LFAdmin failed to send logs (HTTP error): " .. err) fail() end,
        })
        queue = {}
    end
end)

LFAdmin._SteamIDTimed = LFAdmin._SteamIDTimed or {}

LFAdmin.GetSteamIDTimedVar = function(sid, var)
    sid = LFAdmin.GetSteamID(sid)
    return LFAdmin._SteamIDTimed[sid] and LFAdmin._SteamIDTimed[sid][var]
end

LFAdmin.SetSteamIDTimedVar = function(sid, var, time)
    sid = LFAdmin.GetSteamID(sid)
    local vv = LFAdmin._SteamIDTimed[sid] or {}
    LFAdmin._SteamIDTimed[sid] = vv
    if time then
        local inf = time == true
        vv[var] = inf and true or (CurTime() + time)
        if not inf then
            timer.Create("LFAdmin:SteamIDTimed:" .. sid .. var, time, 1, function()
                vv[var] = nil
            end)
        end
    else
        vv[var] = nil
        timer.Remove("LFAdmin:SteamIDTimed:" .. sid .. var)
    end
end
