-- local NTAG = "lenofag.connect:"

-- -- pasted from my LTeamDeathmatch

-- if SERVER then
--     util.AddNetworkString(NTAG .. "Connect")

--     gameevent.Listen("player_connect")
--     hook.Add("player_connect", NTAG .. "Connect", function(data)
--         net.Start(NTAG .. "Connect")
--         net.WriteString(util.TableToJSON({type = "connect", name = data.name, steamid = data.networkid, bot = data.bot == 1}))
--         net.Broadcast()
--         print(string.format("%s connecting to server [%s]", data.name, data.networkid))
--     end)

--     hook.Add("PlayerInitialSpawn", NTAG .. "Connect", function(ply)
--         timer.Simple(.1, function()
--             if not IsValid(ply) then return end
--             net.Start(NTAG .. "Connect")
--             net.WriteString(util.TableToJSON({type = "spawned", name = ply:Name(), team = ply:Team(), steamid = ply:SteamID()}))
--             net.Broadcast()
--             print(string.format("%s spawned [%s]", ply:Name(), ply:SteamID()))
--         end)
--     end)

--     gameevent.Listen("player_disconnect")
--     hook.Add("player_disconnect", NTAG .. "Connect", function(data)
--         if player.GetBySteamID(data.networkid) then return end
--         net.Start(NTAG .. "Connect")
--         net.WriteString(util.TableToJSON({type = "disconnect", name = data.name, steamid = data.networkid, bot = data.bot == 1}))
--         net.Broadcast()
--         print(string.format("%s disconnected [%s] (%s)", data.name, data.networkid, data.reason or "Unknown reason"))
--     end)

--     hook.Add("PlayerDisconnected", NTAG .. "Connect", function(ply)
--         net.Start(NTAG .. "Connect")
--         net.WriteString(util.TableToJSON({type = "disconnected", name = ply:Name(), team = ply:Team(), steamid = ply:SteamID()}))
--         net.Broadcast()
--         print(string.format("%s disconnected [%s]", ply:Name(), ply:SteamID()))
--     end)
-- end

-- if CLIENT then
--     local function connectSound() surface.PlaySound("friends/friend_join.wav") end
--     local function disconnectSound() surface.PlaySound("friends/friend_online.wav") end

--     net.Receive(NTAG .. "Connect", function()
--         if not not net.hack then while 1 + 1 == 3 do print("hack very da chto scripthooker povelsa da a eto ne zapustitsa hahahaha") end end

--         local data = net.ReadString()
--         if data then data = util.JSONToTable(data) else return end
--         --timer.Simple(1, function()
--             if data.type == "connect" then chat.AddText(Color(0, 150, 255), data.name, Color(255, 255, 255), " подключается к серверу") connectSound() end
--             if data.type == "spawned" then chat.AddText(team.GetColor(data.team) or Color(0, 150, 255), data.name, Color(255, 255, 255), " подключился к серверу") connectSound() end
--             if data.type == "disconnect" then chat.AddText(Color(0, 150, 255), data.name, Color(255, 255, 255), " отключился от сервера") disconnectSound() end
--             if data.type == "disconnected" then chat.AddText(team.GetColor(data.team) or Color(0, 150, 255), data.name, Color(255, 255, 255), " отключился от сервера") disconnectSound() end
--         --end)
--     end)

--     hook.Add("ChatText", NTAG .. "RemoveDefault", function(_, _, _, type)
--         if type == "joinleave" then return true end
--     end)
-- end

if SERVER then
    local NTAG = "lenofag.connect:"
    hook.Remove("player_connect", NTAG .. "Connect")
    hook.Remove("PlayerInitialSpawn", NTAG .. "Connect")
    hook.Remove("player_disconnect", NTAG .. "Connect")
    hook.Remove("PlayerDisconnected", NTAG .. "Connect")

    util.AddNetworkString("LFI:Connect")
    local updatecount = function() timer.Simple(0, function() gmlfi.nw.Set("player.GetCountTotal", player.GetCount() + player.GetCountConnecting()) end) end

    gameevent.Listen("player_connect")
    hook.Add("player_connect", "LFI:Connect", function(data)
        net.Start("LFI:Connect")
        net.WriteString("connect")
        local tc = LFAdmin.GetDBUser(data.networkid) and LFAdmin.Groups.Stored[LFAdmin.GetDBUser(data.networkid)].Team or LFAdmin.Groups.Stored.user.Team --fuck my big chungus life
        net.WriteColor(team.GetColor(tc)) --Color(50, 150, 255)
        net.WriteString(data.name)
        net.WriteBool(data.bot == 1)
        net.Broadcast()
        print(data.bot == 1 and string.format("%s added as a bot", data.name) or string.format("%s connecting [%s, userid: %s]", data.name, data.networkid, data.userid))
        updatecount()
    end)

    local q = {}
    hook.Add("PlayerInitialSpawn", "LFI:Connect", function(ply)
        if ply:IsBot() then return end
        timer.Simple(1, function()
            if not IsValid(ply) then return end
            net.Start("LFI:Connect")
            net.WriteString("spawn")
            net.WriteEntity(ply)
            net.Broadcast()
            print(string.format("[%s] %s connected [%s]", ply:GetUserGroup(), ply:Name(), ply:SteamID()))
            q[ply] = true
            updatecount()
        end)
    end)

    hook.Add("StartCommand", "LFI:Connect", function(ply, ucmd)
        if q[ply] and not ucmd:IsForced() then
            q[ply] = nil
            net.Start("LFI:Connect")
            net.WriteString("finish")
            net.WriteEntity(ply)
            net.Broadcast()
            local pgag, pmute = gmlfi.pgm.HasPGag(ply), gmlfi.pgm.HasPMute(ply)
            if pgag then
                local a = not pgag.giver or pgag.giver == "[Console]" or LFAdmin.GetPlayer(pgag.giver)
                LFAdmin.LogPlayer(ply, "У Вас перманентный гаг ", "#" .. os.date("%d.%m.%Y %H:%M:%S", pgag.time))
                LFAdmin.LogPlayer(ply, "- \"", "#" .. (pgag.reason or "(причина неизвестна)"), "\"")
                LFAdmin.LogPlayer(ply, "- От ", LFAdmin.GetSteamID(pgag.giver) or pgag.giver == "[Console]" and NULL or ("#" .. (pgag.giver or NULL)))
            end
            if pmute then
                local a = not pmute.giver or pmute.giver == "[Console]" or LFAdmin.GetPlayer(pmute.giver)
                LFAdmin.LogPlayer(ply, "У Вас перманентный мут ", "#" .. os.date("%d.%m.%Y %H:%M:%S", pmute.time))
                LFAdmin.LogPlayer(ply, "- \"", "#" .. (pmute.reason or "(причина неизвестна)"), "\"")
                LFAdmin.LogPlayer(ply, "- От ", LFAdmin.GetSteamID(pmute.giver) or pmute.giver == "[Console]" and NULL or ("#" .. (pmute.giver or NULL)))
            end --viktor poprosil ochen srochno ;w; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            print(string.format("[%s] %s finished loading [%s]", ply:GetUserGroup(), ply:Name(), ply:SteamID()))
        end
    end)

    local reasons = {
        ["Disconnect by user."] = "ok",

        -- https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/public/const.h#L21-L28
        -- handy
        ["Invalid STEAM UserID Ticket\n"] = "steam",
        ["This Steam account is being used in another location\n"] = "steam",
        ["Client not connected to Steam\n"] = "steam",
        ["Client left game (Steam auth ticket has been canceled)\n"] = "steam",
        ["VAC banned from secure server\n"] = "vac", -- one of the three

        --["%s timed out"] = "crash",
        
        ["This Steam account does not own this game.\n Please login to the correct Steam account"] = "nogame", -- lol
        ["Map is missing"] = "nomap",
        --["Connection closing"] = "cancel",

        -- custom reasons
        ["Kicked for AFK"] = "afk",
    }

    gameevent.Listen("player_disconnect")
    hook.Add("player_disconnect", "LFI:Connect", function(data)
        local ply = Player(data.userid) local val = IsValid(ply)
        --if val and ply:GetNWBool("LFI:Hide") then return end
        net.Start("LFI:Connect")
        net.WriteString("disconnect")
        net.WriteString(val and ply:Name() or data.name)
        net.WriteString((string.sub(data.reason, -9) == "timed out" and "crash") or (data.Reason == "Disconnect by user." and not val and "cancel") or reasons[data.reason] or "ok")
        if val then net.WriteUInt(ply:Team(), 12) q[ply] = nil end
        net.Broadcast()
        print(string.format("%s disconnected [%s]", val and ply:Name() or data.name, data.networkid))
        updatecount()
    end)

    local states = {
        [SIGNONSTATE_NONE] = "SIGNONSTATE_NONE",
        [SIGNONSTATE_CHALLENGE] = "SIGNONSTATE_CHALLENGE",
        [SIGNONSTATE_CONNECTED] = "SIGNONSTATE_CONNECTED",
        [SIGNONSTATE_NEW] = "SIGNONSTATE_NEW",
        [SIGNONSTATE_PRESPAWN] = "SIGNONSTATE_PRESPAWN",
        [SIGNONSTATE_SPAWN] = "SIGNONSTATE_SPAWN",
        [SIGNONSTATE_FULL] = "SIGNONSTATE_FULL",
        [SIGNONSTATE_CHANGELEVEL] = "SIGNONSTATE_CHANGELEVEL"
    }
    hook.Add("ClientSignOnStateChanged", "LFI:Connect", function(uid, old, new)
        print(string.format("[ClientSignOnStateChanged] %s: %s -> %s", uid, states[old] or "UNKNOWN", states[new] or "UNKNOWN"))
    end)

    gameevent.Listen("server_cvar")
    hook.Add("server_cvar", "LFI:Logs", function(data)
        print(string.format("\"%s\" changed value to \"%s\"", data.cvarname, data.cvarvalue))
    end)
end

if CLIENT then
    local reasons = {
        ok = "вышел с сервера",
        steam = "потерял соединение с серверами Steam",
        vac = "имеет VAC-бан",
        crash = "вылетел с сервера",
        nogame = "не имеет игры",
        nomap = "не имеет карты",
        cancel = "отменил подключение",
        afk = "кикнут за AFK",
    }

    local play = function(s)
        local me = LocalPlayer()
        if IsValid(me) then me:EmitSound(s, 75, 100, .25) end
    end

    local t = {
        connect = function()
            chat.AddText(gmlfi.ChatTag("Подключения", "connect"), " ", net.ReadColor(), net.ReadString(), Color(255, 255, 255), net.ReadBool() and " был добавлен на сервер" or " подключается к серверу")
            play("friends/friend_join.wav")
        end,
        spawn = function()
            local ply = net.ReadEntity() if not IsValid(ply) then return end
            chat.AddText(gmlfi.ChatTag("Подключения", "connect"), " ", team.GetColor(ply:Team()), ply:Name(), Color(255, 255, 255), " подключился к серверу")
            chat.PlaySound()
        end,
        finish = function()
            local ply = net.ReadEntity() if not IsValid(ply) then return end
            chat.AddText(gmlfi.ChatTag("Подключения", "connect"), " ", team.GetColor(ply:Team()), ply:Name(), Color(255, 255, 255), " завершил загрузку")
            
            chat.PlaySound()
        end,
        disconnect = function()
            local name, reason, tm = net.ReadString(), net.ReadString(), net.ReadUInt(12)
            chat.AddText(gmlfi.ChatTag("Подключения", "connect-d"), " ", tm > 0 and team.GetColor(tm) or Color(50, 150, 255), name, Color(255, 255, 255), " " .. reasons[reason])
            play("friends/friend_online.wav")
        end
    }
    net.Receive("LFI:Connect", function()
        local ty = net.ReadString()
        if t[ty] then t[ty]() end
    end)
end
