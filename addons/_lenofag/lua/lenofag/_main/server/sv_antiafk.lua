if not gmlfi then return print("sv_antiafk says gmlfi is nil...") end

gmlfi.antiafk = {}

gmlfi.antiafk.Time = 300 -- in seconds

gmlfi.antiafk.Get = function(ply) if gmlfi.IsHuman(ply) then return ply:GetNWBool("LFI:AAFK", false) or not not ply.LFIAAFKS else return false end end
gmlfi.antiafk.Set = function(ply, state) if gmlfi.IsHuman(ply) then ply:SetNWBool("LFI:AAFK", state) ply.LFIAAFKS = state end end

gmlfi.antiafk.Announce = function(ply, state)
    ply.LFIAAFKTOTAL = ply.LFIAAFKTOTAL or 0
    print(string.format("%s [%s] %s AFK", ply:Name(), ply:SteamID(), state and "returned from" or "is now"))
    if state then --doesn't solve when the player disconnects or server restarts i think
        ply.LFIAAFKTOTAL = ply.LFIAAFKTOTAL + (CurTime() - ply.LFIAAFKL)
    else
        ply.LFIAAFKTOTAL = ply.LFIAAFKTOTAL + (CurTime() - ply.LFIAAFKL - gmlfi.antiafk.Time)
    end
    
    ply:SetNWInt("LFI:AAFK.Total",ply.LFIAAFKTOTAL)
    net.Start("LFI:AAFK")
    net.WriteEntity(ply)
    net.WriteBool(state or false)
    net.Broadcast()
end

gmlfi.antiafk.Check = function(ply)
    if not gmlfi.IsHuman(ply) then return end
    if gmlfi.antiafk.Get(ply) then return end
    if ply.LFIAAFKL and ply.LFIAAFKL + gmlfi.antiafk.Time < CurTime() then
        ply:SetNWInt("LFI:AAFK.Last", ply.LFIAAFKL)
        gmlfi.antiafk.Set(ply, true)
        if player.GetCount() >= game.MaxPlayers() then ply:Kick("Kicked for AFK")
        else gmlfi.antiafk.Announce(ply, false) end
    end
end

gmlfi.antiafk.Update = function(ply)
    if not gmlfi.IsHuman(ply) then return end
    if gmlfi.antiafk.Get(ply) then gmlfi.antiafk.Set(ply, false) gmlfi.antiafk.Announce(ply, true) end
    ply.LFIAAFKL = CurTime()
end

hook.Add("Move", "LFI:AAFK", function(ply, cmd)
    if cmd:GetButtons() > 0 then gmlfi.antiafk.Update(ply) else gmlfi.antiafk.Check(ply) end
end)

hook.Add("VehicleMove", "LFI:AAFK", function(ply, _, cmd)
    if cmd:GetButtons() > 0 then gmlfi.antiafk.Update(ply) else gmlfi.antiafk.Check(ply) end
end)
