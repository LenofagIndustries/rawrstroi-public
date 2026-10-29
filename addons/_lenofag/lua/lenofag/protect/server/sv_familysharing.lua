hook.Add("PlayerAuthed", "LFI:FamilySharing", function(ply)
    local owner = ply:OwnerSteamID64()
    if not owner or owner == "0" or owner == ply:SteamID64() then return end

    local s32 = util.SteamIDFrom64(owner)
    if (ULib and ULib.bans[s32]) or (LFAdmin and LFAdmin.GetBan(s32)) then
        print(string.format("%s's game owner (%s) is banned on server, kicking player...", ply:Name(), owner))
        -- if LFAdmin then LFAdmin.LogPlayer(false, "Внимание: ", ply, " обходит бан, настоящий аккаунт: ", "#" .. s32) end
        return ply:Kick("Your game's owner is banned on this server, please use another account or contact us: " .. (gmlfi and gmlfi.discord or "https://gm.lenofag.ru/discord"))
    end

    ply:SetNWString("LFI:FamilySharing", owner)
    print(string.format("%s's [%s] game is family shared, owner: %s", ply:Name(), ply:SteamID(), owner))
end)
