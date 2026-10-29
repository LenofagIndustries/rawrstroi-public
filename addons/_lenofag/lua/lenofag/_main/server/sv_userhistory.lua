sql.Query("CREATE TABLE IF NOT EXISTS gmlfi_UserHistory (sid64 TEXT PRIMARY KEY, name TEXT, lastip TEXT, lastjoin INT, firstip TEXT, firstjoin INT);")

local stripPort = function(s) return string.gsub(s, ":%d%d?%d?%d?%d?", "") end

gameevent.Listen("player_connect")
hook.Add("player_connect", "LFI:UserHistory", function(data)
    if data.bot == 1 then return end

    local sid, name, ip, time = util.SteamIDTo64(data.networkid), data.name, data.address, os.time()
    local data = sql.QueryRow(string.format("SELECT * FROM gmlfi_UserHistory WHERE sid64 = %s;", sql.SQLStr(sid)))
    if data then
        print(string.format("%s last joined %s%s%s", name, os.date("%d %B %Y, %X", data.lastjoin), stripPort(data.lastip) ~= stripPort(ip) and ", last IP: " .. data.lastip or "", name ~= data.name and ", last name: \"" .. data.name .."\"" or ""))
        sql.Query(string.format(
            "UPDATE gmlfi_UserHistory SET name = %s, lastip = %s, lastjoin = %s WHERE sid64 = %s;",
            sql.SQLStr(name),
            sql.SQLStr(ip),
            time,
            sql.SQLStr(sid)
        ))
    else
        print(string.format("New user %s, inserting data...", name))
        sql.Query(string.format(
            "INSERT INTO gmlfi_UserHistory VALUES(%s, %s, %s, %s, %s, %s)",
            sql.SQLStr(sid),
            sql.SQLStr(name),
            sql.SQLStr(ip),
            time,
            sql.SQLStr(ip),
            time
        ))
    end
end)

concommand.Add("gmlfi_users_search", function(ply, _, args)
    if IsValid(ply) and ply:IsPlayer() then return end
    if not args[1] or string.Trim(args[1]) == "" then return print("Invalid SteamID64!") end
    
    if string.sub(args[1], 1, 5) == "STEAM" then args[1] = util.SteamIDTo64(args[1]) end
    local data = sql.Query(string.format("SELECT * FROM gmlfi_UserHistory WHERE sid64 = %s OR name LIKE %s;", sql.SQLStr(args[1]), sql.SQLStr(args[1])))
    if not data then return print("Nothing found on " .. args[1]) end
    
    for k, v in ipairs(data) do
        print(string.format("%s\nSteamID: %s / %s\nLast IP: %s\nFirst IP: %s\nLast join: %s", v.name or "[unknown]", v.sid64, util.SteamIDFrom64(v.sid64), v.lastip or "[unknown]", v.firstip or "[unknown]", v.lastjoin and os.date("%d %B %Y, %X", v.lastjoin) or "[unknown]"))
    end
end)

-- sessions

sql.Query("CREATE TABLE IF NOT EXISTS gmlfi_Sessions (SteamID TEXT NOT NULL, IP TEXT NOT NULL, Name TEXT NOT NULL, `Start` INT NOT NULL, `End` INT)")
sql.Query("CREATE TABLE IF NOT EXISTS gmlfi_ServerSessions (Map TEXT NOT NULL, PlayerMax INT DEFAULT 0, PlayerAvg INT DEFAULT 0, `Start` INT PRIMARY KEY, `End` INT)")

local sstart = math.floor(os.time() - CurTime())
sql.QueryTyped("INSERT INTO gmlfi_ServerSessions (Map, `Start`) VALUES (?, ?) ON CONFLICT DO NOTHING", game.GetMap(), sstart)

gmlfi.PlayerAverageTable = gmlfi.PlayerAverageTable or {0, 0, 0}
timer.Create("LFI:UpdateServerSession", 1, 0, function()
    timer.Adjust("LFI:UpdateServerSession", 60)
    local t = gmlfi.PlayerAverageTable
    local num = player.GetCount() + player.GetCountConnecting()
    t[1], t[2], t[3] = t[1] + num, t[2] + 1, t[3] > num and t[3] or num

    sql.QueryTyped("UPDATE gmlfi_ServerSessions SET PlayerMax = ?, PlayerAvg = ? WHERE `Start` = ?", t[3], (t[1] + num) / t[2], sstart)
end)

hook.Add("InitPostEntity", "LFI:Sessions", function()
    sql.Query("UPDATE gmlfi_Sessions SET `End` = " .. os.time() .. " WHERE `End` IS NULL")
    sql.Query("UPDATE gmlfi_ServerSessions SET `End` = " .. sstart .. " WHERE `End` IS NULL")
end)

hook.Add("PlayerAuthed", "LFI:Sessions", function(ply)
    ply.LFSessionStart = os.time()
    sql.Query(string.format("INSERT INTO gmlfi_Sessions (SteamID, IP, Name, `Start`) VALUES (%s, %s, %s, %s)", SQLStr(ply:SteamID64()), SQLStr(string.Explode(":", ply:IPAddress())[1]), SQLStr(ply:Name()), ply.LFSessionStart))
end)

local finish = function(ply)
    if ply.LFSessionStart then sql.Query(string.format("UPDATE gmlfi_Sessions SET `End` = %s WHERE SteamID = %s AND `Start` = %s", os.time(), ply:SteamID64(), ply.LFSessionStart)) end
end

hook.Add("PlayerDisconnected", "LFI:Sessions", finish)
hook.Add("ShutDown", "LFI:Sessions", function()
    for k, v in ipairs(player.GetHumans()) do finish(v) end
    sql.QueryTyped("UPDATE gmlfi_ServerSessions SET `End` = ? WHERE `Start` = ?", os.time(), sstart)
end)