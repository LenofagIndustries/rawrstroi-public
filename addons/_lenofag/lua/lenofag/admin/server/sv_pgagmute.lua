if not gmlfi then return print("sv_pgagmute says gmlfi is nil...") end

sql.Query("CREATE TABLE IF NOT EXISTS gmlfi_PGagMute (sid64 TEXT, type TEXT, reason TEXT, giver TEXT, time INT)")

gmlfi.pgm = {}

gmlfi.pgm.PGag = function(ply, giver, reason)
    local sid = IsValid(ply) and ply:SteamID64() or ply
    if sql.Query(string.format("SELECT sid64 FROM gmlfi_PGagMute WHERE sid64 = %s AND type = %s", sql.SQLStr(sid), sql.SQLStr("pgag"))) then return false, string.format("%s is already PGagged!", sid) end
    if IsValid(ply) then ply:SetNWBool("LFI:PGag", true) end
    return sql.Query(string.format("INSERT INTO gmlfi_PGagMute VALUES(%s, %s, %s, %s, %s)", sql.SQLStr(sid), sql.SQLStr("pgag"), SQLStr(reason or "(no reason given)"), SQLStr(IsValid(giver) and giver:SteamID64() or "[Console]"), os.time())) ~= false
end

gmlfi.pgm.PMute = function(ply, giver, reason)
    local sid = IsValid(ply) and ply:SteamID64() or ply
    if sql.Query(string.format("SELECT sid64 FROM gmlfi_PGagMute WHERE sid64 = %s AND type = %s", sql.SQLStr(sid), sql.SQLStr("pmute"))) then return false, string.format("%s is already PMuted!", sid) end
    if IsValid(ply) then ply:SetNWBool("LFI:PMute", true) end
    return sql.Query(string.format("INSERT INTO gmlfi_PGagMute VALUES(%s, %s, %s, %s, %s)", sql.SQLStr(sid), sql.SQLStr("pmute"), SQLStr(reason or "(no reason given)"), SQLStr(IsValid(giver) and giver:SteamID64() or "[Console]"), os.time())) ~= false
end

gmlfi.pgm.UnPGag = function(ply)
    local sid = IsValid(ply) and ply:SteamID64() or ply
    if IsValid(ply) then ply:SetNWBool("LFI:PGag", false) end
    return sql.Query(string.format("DELETE FROM gmlfi_PGagMute WHERE sid64 = %s AND type = %s", sql.SQLStr(sid), sql.SQLStr("pgag"))) ~= false
end

gmlfi.pgm.UnPMute = function(ply)
    if IsValid(ply) then ply:SetNWBool("LFI:PMute", false) end
    return sql.Query(string.format("DELETE FROM gmlfi_PGagMute WHERE sid64 = %s AND type = %s", sql.SQLStr(IsValid(ply) and ply:SteamID64() or ply), sql.SQLStr("pmute"))) ~= false
end

gmlfi.pgm.HasPGag = function(ply)
    return sql.QueryRow(string.format("SELECT reason, giver, time FROM gmlfi_PGagMute WHERE sid64 = %s AND type = %s", sql.SQLStr(IsValid(ply) and ply:SteamID64() or ply), sql.SQLStr("pgag"))) or false
end

gmlfi.pgm.HasPMute = function(ply)
    return sql.QueryRow(string.format("SELECT reason, giver, time FROM gmlfi_PGagMute WHERE sid64 = %s AND type = %s", sql.SQLStr(IsValid(ply) and ply:SteamID64() or ply), sql.SQLStr("pmute"))) or false
end

hook.Add("PlayerInitialSpawn", "LFI:PGagMute.Load", function(ply)
    ply:SetNWBool("LFI:PGag", not not gmlfi.pgm.HasPGag(ply))
    ply:SetNWBool("LFI:PMute", not not gmlfi.pgm.HasPMute(ply))
end)

hook.Add("PlayerCanHearPlayersVoice", "LFI:PGagMute", function(_, ply)
    if ply:GetNWBool("LFI:PGag", false) then return false end
end)

hook.Add("PlayerSay", "LFI:PMute", function(ply)
    if ply:GetNWBool("LFI:PMute", false) then return false end
end)
