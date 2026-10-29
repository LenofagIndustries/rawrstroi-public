local PlayerConnects, PlayerConnectBanned, PlayerMaxConnects = {}, {}, 10
timer.Create("LFI:ConnectSpam", 1, 0, function()
    for sid, _ in pairs(PlayerConnects) do
        PlayerConnects[sid] = 0
    end
end)

local reklama = {
    "exechack.cc"
}

hook.Add("CheckPassword", "LFI:ConnectSpam", function(sid, _a, _b, _c, name)
    for k, v in ipairs(reklama) do
        if string.find(string.lower(name), v) then print("reklama vonyuchaya", v, sid, _a, _b, _c, name) PlayerConnectBanned[sid] = math.huge return false, "А не пошел ка ты нахуй отсюда!!!" end
    end
    
    if PlayerConnectBanned[sid] then
        if os.time() >= PlayerConnectBanned[sid] then
            print(string.format("Unbanned %s (%s) from anti connect spam", name, util.SteamIDFrom64(sid)))
            PlayerConnectBanned[sid] = nil
        else return false, os.date("You are banned for connect spamming (%X)", PlayerConnectBanned[sid]) end
    end

    PlayerConnects[sid] = PlayerConnects[sid] and PlayerConnects[sid] + 1 or 1

    if PlayerConnects[sid] >= PlayerMaxConnects then
        PlayerConnects[sid] = nil
        print(string.format("Banned %s (%s) for connect spamming", name, util.SteamIDFrom64(sid)))
        PlayerConnectBanned[sid] = os.time() + 1800
        return false, os.date("You are banned for connect spamming (%X)", os.time() + (30 * 6000))
    end
end)

concommand.Add("gmlfi_cspam_unban", function(ply, _, _, arg)
    if ply and ply:IsPlayer() then return end 
    if not PlayerConnectBanned[arg] then return print(arg, "is not banned!") end
    PlayerConnectBanned[arg] = nil print(arg, "was unbanned from anti connect spam")
end)

concommand.Add("gmlfi_cspam_unbanid", function(ply, _, _, arg)
    if ply and ply:IsPlayer() then return end arg = util.SteamIDTo64(arg)
    if not PlayerConnectBanned[arg] then return print(arg, "is not banned!") end
    PlayerConnectBanned[arg] = nil print(arg, "was unbanned from anti connect spam")
end)