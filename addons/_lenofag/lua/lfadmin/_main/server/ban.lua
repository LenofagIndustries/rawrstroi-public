sql.Query("CREATE TABLE IF NOT EXISTS lfadmin_bans (sid64 TEXT NOT NULL, admin TEXT, reason TEXT, duration INT NOT NULL, time INT)")

LFAdmin.BanCache = {}
LFAdmin.Ban = function(ply, who, reason, duration)
    local is = ply and IsValid(ply) and ply:IsPlayer()
    if is and ply:IsBot() then return end
    if not is then ply = LFAdmin.GetSteamID(ply, true) end
    local sid = is and ply:SteamID64() or ply
    local old = LFAdmin.GetBan(sid)
    if old then
        sql.Query(string.format("DELETE FROM lfadmin_bans WHERE sid64 = %s AND time = %s", SQLStr(sid), old.time))
    end

    reason = reason or "Not specified"
    sql.Query(string.format("INSERT INTO lfadmin_bans VALUES(%s, %s, %s, %s, %s)", SQLStr(sid), SQLStr(not IsValid(who) and "[Console]" or who:SteamID64()), SQLStr(reason), duration ~= 0 and os.time() + math.abs(duration) or 0, os.time()))
    LFAdmin.LogPlayer(NULL, "writing ban of ", is and ply or ("#" .. ply), " by ", who or NULL, " ", duration == 0 and "(permanent)" or ("#for " .. gmlfi.FormatTime(duration)), ": ", "#" .. reason)
    local str = string.format(LFAdmin.Config.banmessage, not IsValid(who) and "[Console]" or string.format("%s [%s]", who:Name(), who:SteamID()), reason, duration ~= 0 and LFAdmin.FormatTime(duration) or "[перманентный бан]")
    if is then LFAdmin.UnJail(ply) ply:Kick(str) else game.KickID(LFAdmin.GetSteamID(ply), str) end
    LFAdmin.BanCache[sid] = nil
    LFAdmin.BanCache[sid] = LFAdmin.GetBan(sid)
end

LFAdmin.Unban = function(sid64)
    if not LFAdmin.GetBan(sid64) then return false end
    sql.Query("DELETE FROM lfadmin_bans WHERE sid64=" .. SQLStr(sid64))
    LFAdmin.BanCache[sid64] = nil
end

local admins = {}
local cacheAdmin = function(admin)
    if admins[admin] then return admins[admin] end
    local _ = player.GetBySteamID64(admin) if _ then admins[admin] = string.format("%s [%s]", _:Name(), _:SteamID()) return admins[admin] end
    local data = sql.QueryRow("SELECT name FROM lfadmin_users WHERE sid64=" .. SQLStr(admin))
    if data then admins[admin] = string.format("%s [%s]", data.name, util.SteamIDFrom64(admin)) return admins[admin] else return "[Unknown]" end
end

LFAdmin.GetBan = function(sid)
    sid = LFAdmin.GetSteamID(sid, true)
    local cache = LFAdmin.BanCache[sid]
    if cache then
        if cache.duration and cache.duration ~= 0 and cache.duration < os.time() then LFAdmin.BanCache[sid] = nil return false end
        return cache
    end
    local data = sql.Query("SELECT admin, reason, duration, time FROM lfadmin_bans WHERE sid64 = " .. SQLStr(sid) .. " AND (duration = 0 OR duration >= " .. os.time() .. ") ORDER BY time DESC")
    if data then
        local d = data[1]
        LFAdmin.BanCache[sid] = d
        d.adminsid = d.admin
        d.admin = d.admin == "[Console]" and "[Console]" or cacheAdmin(d.admin)
        d.duration = tonumber(d.duration) or 0
        d.time = tonumber(d.time) or 0
        return d
    end
    return false
end

local etrd = {}
hook.Add("CheckPassword", "LFAdmin.Bans", function(sid64, ip, _, _, name)
    local ban = LFAdmin.GetBan(sid64) if not ban then
        local sid = util.SteamIDFrom64(sid64)
        if etrd[sid64] and etrd[sid64] > CurTime() then return false, "Вы заблокированы системой ETR (Eblan Trouble Register)\nПодробнее: https://sellingvika.party/etr" end
        http.Fetch("https://sellingvika.party/etr/v3/status/" .. sid64, function(body, _, _, c)
            if c and (util.JSONToTable(body) or {}).status == true then
                game.KickID(sid, "Вы заблокированы системой ETR (Eblan Trouble Register)\nПодробнее: https://sellingvika.party/etr")
                etrd[sid64] = CurTime() + 3600
            end
        end, nil, {["X-API-Key"] = "[...]"})
    return end --if ban.duration and ban.duration ~= 0 and ban.duration < os.time() then LFAdmin.Unban(sid64) return end
    LFAdmin.LogPlayer(NULL, "#" .. name, " (", "#" .. LFAdmin.GetSteamID(sid64), ") is banned, connect attempt refused")
    return false, string.format(LFAdmin.Config.banmessage, ban.admin, ban.reason, ban.duration and ban.duration ~= 0 and LFAdmin.FormatTime(ban.duration - os.time()) or "[перманентный бан]")
end)

timer.Create("LFAdmin:ETR.Check", 300, 0, function()
    for k, v in ipairs(player.GetHumans()) do
        local sid64 = v:SteamID64()
        http.Fetch("https://sellingvika.party/etr/v3/status/" .. sid64, function(body, _, _, c)
            if c and (util.JSONToTable(body) or {}).status == true then
                v:Kick("Вы заблокированы системой ETR (Eblan Trouble Register)\nПодробнее: https://sellingvika.party/etr")
                etrd[sid64] = CurTime() + 3600
            end
        end, nil, {["X-API-Key"] = "[...]"})
    end
end)