if not gmlfi then return print("sv_reputation says gmlfi is nil...") end

print("sv_reputation loaded...")

sql.Query("CREATE TABLE IF NOT EXISTS gmlfi_Reputation (sid64 TEXT PRIMARY KEY, rep INTEGER);")
local sqls = sql.SQLStr

util.AddNetworkString("LFI:Reputation")
util.AddNetworkString("LFI:Reputation.CD")

gmlfi.reputation = gmlfi.reputation or {}

gmlfi.reputation.GetReputation = function(ply)
    if not IsValid(ply) then return end
    local data = sql.QueryRow(string.format("SELECT * FROM gmlfi_Reputation WHERE sid64 = %s;", sqls(ply:SteamID64())))
    if not data then
        sql.Query(string.format("INSERT INTO gmlfi_Reputation VALUES(%s, %s);", sqls(ply:SteamID64()), 0))
        return 0
    else return data.rep end
end

gmlfi.reputation.SetReputation = function(ply, val)
    if not IsValid(ply) then return end
    val = (type(val) == "string" and tonumber(val)) or val or 0

    local data = sql.QueryRow(string.format("SELECT * FROM gmlfi_Reputation WHERE sid64 = %s;", sqls(ply:SteamID64())))
    if not data then sql.Query(string.format("INSERT INTO gmlfi_Reputation VALUES(%s, %s);", sqls(ply:SteamID64()), val))
    else sql.Query(string.format("UPDATE gmlfi_Reputation SET rep = %s WHERE sid64 = %s;", val, sqls(ply:SteamID64()))) end

    ply:SetNWInt("LFI:Reputation", val)
end

gmlfi.reputation.AddReputation = function(ply, val)
    if not ply or not IsValid(ply) or val == 0 then return end
    val = (type(val) == "string" and tonumber(val)) or val or 0

    local data = sql.QueryRow(string.format("SELECT * FROM gmlfi_Reputation WHERE sid64 = %s;", sqls(ply:SteamID64())))
    gmlfi.reputation.SetReputation(ply, data and data.rep + val or val)
end

gmlfi.reputation.SendCDNotify = function(ply)
    if not gmlfi.reputation.AddRepCooldown[ply:SteamID64()] then return false end
    net.Start("LFI:Reputation.CD")
    net.WriteString("" .. gmlfi.reputation.AddRepCooldown[ply:SteamID64()])
    net.Send(ply)
end

gmlfi.reputation.SendNotify = function(ply, who, up, me)
    net.Start("LFI:Reputation")
    net.WriteEntity(who)
    net.WriteBool(up)
    net.WriteBool(me or false)
    net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "LFI:Reputation", function(ply)
    if not ply:IsValid() or ply == 0 then return end
    
    local data = sql.QueryRow(string.format("SELECT * FROM gmlfi_Reputation WHERE sid64 = %s;", sqls(ply:SteamID64())))
    if not data then
        sql.Query(string.format("INSERT INTO gmlfi_Reputation VALUES(%s, %s);", sqls(ply:SteamID64()), 0))
        ply:SetNWInt("LFI:Reputation", 0)
    else ply:SetNWInt("LFI:Reputation", data.rep) end
end)

timer.Create("LFI:Reputation.ClearCD", 1, 0, function()
    for id, time in pairs(gmlfi.reputation.AddRepCooldown) do
        if os.time() >= time then gmlfi.reputation.AddRepCooldown[id] = nil end
    end
end)

gmlfi.reputation.AddRepCooldown = gmlfi.reputation.AddRepCooldown or {}
net.Receive("LFI:Reputation", function(_, ply)
    if not IsValid(ply) then return end
    if gmlfi.reputation.AddRepCooldown[ply:SteamID64()] and not ply:IsRamzi() then
        if os.time() >= gmlfi.reputation.AddRepCooldown[ply:SteamID64()] then gmlfi.reputation.AddRepCooldown[ply:SteamID64()] = nil else return gmlfi.reputation.SendCDNotify(ply) end
    end

    local target, up = net.ReadEntity(), net.ReadBool()
    
    if not IsValid(target) or not target:IsPlayer() or target:IsBot() or target == ply then return end
    gmlfi.reputation.AddRepCooldown[ply:SteamID64()] = os.time() + (3 * 600)
    gmlfi.reputation.AddReputation(target, up and 1 or -1)

    gmlfi.reputation.SendNotify(target, ply, up, false)
    gmlfi.reputation.SendNotify(ply, target, up, true)

    print(string.format("%s gave %s reputation to %s", ply:Name(), up and "positive" or "negative", target:Name()))
end)

concommand.Add("gmlfi_rep_clearcd", function() gmlfi.reputation.AddRepCooldown = {} end)