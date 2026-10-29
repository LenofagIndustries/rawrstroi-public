sql.Query("CREATE TABLE IF NOT EXISTS lfadmin_users (sid64 TEXT PRIMARY KEY, name TEXT, usergroup TEXT NOT NULL, expire INT, expireTo TEXT)")
sql.Query("CREATE TABLE IF NOT EXISTS lfadmin_warns (sid64 TEXT NOT NULL, id INT, reason TEXT, giver TEXT)")
sql.Query("CREATE TABLE IF NOT EXISTS lfadmin_access (sid64 TEXT NOT NULL, name TEXT, restrict TINYINT(1))")

LFAdmin.GetDBUser = function(ply)
    local data = sql.QueryTyped("SELECT * FROM lfadmin_users WHERE sid64=" .. SQLStr(LFAdmin.GetSteamID(ply, true)))
    if data and data[1] then data = data[1] return data.usergroup, data.name, data end
end

LFAdmin.Groups.Set = function(ply, group, exp, expto) local iv = IsValid(ply)
    if iv and group == ply:GetUserGroup() then return true end
    local data = LFAdmin.Groups.Stored[group] if not data then return false, LFAdmin.Log(string.format("Groups.Set attempted to set invalid group \"%s\" to %s, see traceback", group, ply)), print(debug.traceback()) end
    if iv then
        ply:SetUserGroup(group)
        ply:SetTeam(data.Team or TEAM_DEFAULT)
        ply:ConCommand("spawnmenu_reload")
    end

    if not iv or not ply:IsBot() then
        local sid = LFAdmin.GetSteamID(ply, true)
        if group == LFAdmin.Config.defaultUsergroup and not exp then sql.Query("DELETE FROM lfadmin_users WHERE sid64=" .. SQLStr(sid)) else
            local ggroup = LFAdmin.GetDBUser(ply) if ggroup == group then return true end
            if not ggroup then sql.Query(string.format("INSERT INTO lfadmin_users VALUES(%s, %s, %s, %s, %s)", SQLStr(sid), SQLStr(iv and ply:Name() or "[offline]"), SQLStr(group), exp or "NULL", exp and SQLStr(expto or "user") or "NULL"))
            else sql.Query(string.format("UPDATE lfadmin_users SET usergroup=%s, expire=%s, expireTo=%s WHERE sid64=%s", SQLStr(group), exp or "NULL", exp and SQLStr(expto or ggroup) or "NULL", SQLStr(sid))) end
            sql.Query(string.format("DELETE FROM lfadmin_warns WHERE sid64=%s", SQLStr(sid)))
            if exp then LFAdmin.LogPlayer(NULL, "writing usergroup of ", ply, " to ", "#" .. group, " (expiring ", os.date("#%X %d.%m.%Y", exp), ", to ", "#" .. (expto or "user"), ")")
            else LFAdmin.LogPlayer(NULL, "writing usergroup of ", ply, " to ", "#" .. group) end
        end
    end
end

local steam = function(ply, t) timer.Simple(0, function() ply:SetTeam(t) end) end
hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
hook.Remove("PlayerInitialSpawn", "LFAdmin.SetGroup")
hook.Add("PlayerAuthed", "LFAdmin.SetGroup", function(ply)
    LFAdmin.Log(string.format("loading %s's group...", tostring(ply)))
    local group, name = LFAdmin.GetDBUser(ply)
    if group then
        local data = LFAdmin.Groups.Stored[group]
        if not data then return ply:SetUserGroup("user"), LFAdmin.Log(string.format("%s is a \"%s\" (invalid group, defaulted to user)", tostring(ply), group)) end
        LFAdmin.Log(string.format("%s is a \"%s\"", tostring(ply), group))
        timer.Simple(1, function() if name ~= ply:Name() then sql.Query(string.format("UPDATE lfadmin_users SET name=%s WHERE sid64=%s", SQLStr(ply:Name()), SQLStr(ply:SteamID64()))) end end)
        ply:SetUserGroup(group)
        steam(ply, data.Team)
    else
        LFAdmin.Log(string.format("%s has no group", tostring(ply)))
        steam(ply, TEAM_DEFAULT)
        if LFAdmin.Config.defaultUsergroup ~= ply:GetUserGroup() then ply:SetUserGroup(LFAdmin.Config.defaultUsergroup) end
    end
end)

hook.Add("OnPhysgunPickup", "LFAdmin:Pickup", function(ply, target)
    if target:IsPlayer() then target:Lock() end
end)

hook.Add("OnPhysgunFreeze", "LFAdmin:Pickup", function(_, _, target, ply)
    if target:IsPlayer() then LFAdmin.Commands[(target.LFAFREEZE and "un" or "") .. "freeze"].callback(ply, {target}) end
end)

hook.Add("PhysgunDrop", "LFAdmin:Pickup", function(ply, target)
    if target:IsPlayer() and not target.LFAFREEZE then target:UnLock() end
end)

timer.Create("LFAdmin.GroupTimed", 30, 0, function()
    for _, data in ipairs(sql.Query("SELECT sid64, expireTo FROM lfadmin_users WHERE expire <= " .. os.time()) or {}) do
        local ply = player.GetBySteamID64(data.sid64)
        LFAdmin.Groups.Set(IsValid(ply) and ply or data.sid64, data.expireTo)
        if IsValid(ply) then LFAdmin.LogPlayer(ply, "Срок действия Вашей группы истек, теперь Вы ", "#" .. data.expireTo) end
        LFAdmin.LogPlayer(NULL, "Срок действия группы ", IsValid(ply) and ply or data.sid64, " истек, группа установлена на ", "#" .. data.expireTo)
    end
end)