--     ______   __    __   __       ______  __    
--    /\  ___\ /\ "-./  \ /\ \     /\  ___\/\ \   
--    \ \ \__ \\ \ \-./\ \\ \ \____\ \  __\\ \ \  
--     \ \_____\\ \_\ \ \_\\ \_____\\ \_\   \ \_\ 
--      \/_____/ \/_/  \/_/ \/_____/ \/_/    \/_/ 
--
--    gm.lenofag.ru © 2023
--
--    feel free to use on your server :)
--    just don't remove this watermark
--    please
--

gmlfi.restart = gmlfi.restart or {is = false, time = 0}

if CLIENT then
    local col = {tx = Color(255, 255, 255), th = Color(200, 200, 200), rd = Color(255, 50, 50), no = Color(0, 0, 0)}
    hook.Add("HUDPaint", "LFI:Restart", function()
        if gmlfi.restart.is and os.time() < gmlfi.restart.time then
            draw.SimpleTextOutlined("RESTART", "LFI:Interface", ScrW() / 2, 20, os.time() % 2 == 1 and col.tx or col.rd, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, col.no)
            draw.SimpleTextOutlined("через " .. gmlfi.FormatTime(gmlfi.restart.time - os.time()), "LFI:Interface.Small", ScrW() / 2, 45, col.th, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, col.no)
        elseif gmlfi.rtv.endtime and CurTime() < gmlfi.rtv.endtime then
            draw.SimpleTextOutlined("ГОЛОСОВАНИЕ", "LFI:Interface", ScrW() / 2, 20, col.tx, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, col.no)
            draw.SimpleTextOutlined("за смену карты", "LFI:Interface.Small", ScrW() / 2, 45, col.th, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, col.no)
            draw.SimpleTextOutlined("!rtv", "LFI:Interface.Small", ScrW() / 2, 65, col.th, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, col.no)
        end
    end)

    net.Receive("LFI:Restart", function()
        gmlfi.restart.is = net.ReadBool()
        if gmlfi.restart.is then
            local time = net.ReadUInt(16)
            gmlfi.restart.time = os.time() + time

            surface.PlaySound("friends/message.wav")
            chat.AddText(Color(255, 255, 255), "Внимание: сервер перезапустится через ", Color(0, 150, 255), time, Color(255, 255, 255), " секунд")
        end
    end)
end

if SERVER then
    util.AddNetworkString("LFI:Restart")

    gmlfi.restart.Schedule = function(time)
        gmlfi.restart.time = os.time() + time
        print("Restart " .. (gmlfi.restart.is and "re" or "") .. "scheduled to " .. os.date("%X", gmlfi.restart.time))
        gmlfi.restart.is = true

        timer.Create("LFI:Restart", time, 1, function()
            print("Server is restarting due to schedule...")
            if LRELAY then LRELAY.SendMessage({embed = {title = "Сервер перезапускается..."}}) end
            if gmnetwork then
                for k, v in ipairs(player.GetHumans()) do gmnetwork.DisconnectClientSilent(v:UserID()) end
                gmnetwork.GMOD_RawServerCommand("exit")
            else RunConsoleCommand("_restart") end -- thanks for blocking exit/quit rubat!!!!!!
        end)

        if LRELAY then LRELAY.SendMessage({embed = {title = "Сервер перезапустится <t:" .. gmlfi.restart.time .. ":R>"}}) end
        net.Start("LFI:Restart") net.WriteBool(true) net.WriteUInt(time, 16) net.Broadcast()
    end

    gmlfi.restart.Stop = function()
        gmlfi.restart.is = false
        timer.Remove("LFI:Restart")

        if LRELAY then LRELAY.SendMessage({embed = {title = "Перезапуск сервера был отменен"}}) end
        net.Start("LFI:Restart") net.WriteBool(false) net.Broadcast()
    end

    local auto = {
        ["03:00"] = true,
        ["12:00"] = true,
    }
    timer.Create("LFI:Restart.Auto", 1, 0, function()
        --print(os.date("%H") == "12" and not gmlfi.restart.is)
        if auto[os.date("%H:%M")] and not gmlfi.restart.is then
            print("Scheduling auto-restart...")
            gmlfi.restart.Schedule(240)
            timer.Remove("LFI:Restart.Auto")
        end
    end)

    hook.Add("PlayerInitialSpawn", "LFI:Restart", function(ply) if gmlfi.restart.is then net.Start("LFI:Restart") net.WriteBool(true) net.WriteUInt(math.Round(timer.TimeLeft("LFI:Restart")), 16) net.Send(ply) end end)
end
