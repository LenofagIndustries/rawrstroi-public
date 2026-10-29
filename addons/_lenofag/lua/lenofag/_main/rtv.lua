--     ______   __    __   __       ______  __    
--    /\  ___\ /\ "-./  \ /\ \     /\  ___\/\ \   
--    \ \ \__ \\ \ \-./\ \\ \ \____\ \  __\\ \ \  
--     \ \_____\\ \_\ \ \_\\ \_____\\ \_\   \ \_\ 
--      \/_____/ \/_/  \/_/ \/_____/ \/_/    \/_/ 
--
--    gm.lenofag.ru © 2026
--
--    feel free to use on your server :)
--    just don't remove this watermark
--    please
--

gmlfi.rtv = gmlfi.rtv or {}
gmlfi.rtv.maps = {}
gmlfi.rtv.timer = 300

local current = game.GetMap()
if SERVER then
    util.AddNetworkString("LFI:RTV")

    gmlfi.rtv.votes = {}
    gmlfi.rtv.started = false
    
    local exclude = {
        ["gm_construct"] = true,
        ["gm_flatgrass"] = true,
        ["gm_infmap"] = true,
        ["gm_infmap_metrostroi"] = true, -- boring straight rail
        ["gm_simplemetro_map"] = true, -- weird
        ["gm_metro_kalinin_v2"] = true, -- broken content idk
        ["gm_zamoscvorescya_line_do_orehovo"] = true, -- per vote 10/6/2026 19:34
        ["gm_dnipro"] = true, -- per vote 10/6/2026 19:34
        ["gm_metro_prizmaaline_v4"] = true, -- per vote 10/6/2026 19:34
    }
    
    do
        local files = file.Find("maps/*.bsp", "GAME")
        for _, map in ipairs(files) do map = string.StripExtension(map) if not exclude[map] then gmlfi.rtv.maps[#gmlfi.rtv.maps + 1] = map end end
    end

    gmlfi.rtv.Start = function()
        if gmlfi.rtv.started then return false end
        gmlfi.rtv.started = true

        net.Start("LFI:RTV")
        net.WriteString("start")
        net.WriteString(util.TableToJSON(gmlfi.rtv.maps))
        net.Broadcast()

        gmlfi.rtv.votes = {}
        for k, v in ipairs(gmlfi.rtv.maps) do gmlfi.rtv.votes[v] = 0 end
        for k, ply in ipairs(player.GetHumans()) do ply.LFIRTV = nil end

        timer.Create("LFI:RTV", gmlfi.rtv.timer, 1, gmlfi.rtv.Finish)
    end

    gmlfi.rtv.Finish = function()
        if not gmlfi.rtv.started then return false end
        gmlfi.rtv.started = false

        local highm, high = "", 0
        for k, v in pairs(gmlfi.rtv.votes) do if high < v then high = v highm = k end end

        local none = high == 0
        net.Start("LFI:RTV")
        net.WriteString("end")
        if not none then net.WriteString(highm) end
        net.Broadcast()

        if none then print("Nothing was chosen during map vote")
        else
            if current == highm then
                print("Map was not changed during map vote")
                for k, v in ipairs(gmlfi.rtv.maps) do if v == current then table.remove(gmlfi.rtv.maps, k) break end end
            else
                print(string.format("%s won in map vote! Changing map in 5 seconds", highm))
                timer.Simple(5, function() game.ConsoleCommand("changelevel " .. highm .. "\n") end)

                local vv = ""
                for k, v in pairs(gmlfi.rtv.votes) do
                    if v > 0 then
                        print(string.format("%s - %s votes", k, v))
                        vv = string.format("%s`%s` - **%s** голосов\n", vv, k, v)
                    end
                end
                if LRELAY then LRELAY.SendMessage({embed = {title = "В голосовании за карту выиграла `" .. highm .."`", description = vv}}) end
            end
        end
    end

    gmlfi.rtv.Stop = function()
        if not gmlfi.rtv.started then return false end
        gmlfi.rtv.started = false
        gmlfi.rtv.votes = {}

        net.Start("LFI:RTV")
        net.WriteString("stop")
        net.Broadcast()

        for k, ply in ipairs(player.GetHumans()) do ply.LFIRTV = nil end

        timer.Remove("LFI:RTV")
    end

    gmlfi.rtv.Update = function(ply, map, notify)
        net.Start("LFI:RTV")
        net.WriteString("votes")
        net.WriteEntity(ply)
        net.WriteBool(not not notify)
        net.WriteString(map)
        net.WriteUInt(gmlfi.rtv.votes[map], 7)
        net.Broadcast()
    end

    gmlfi.rtv.Open = function(ply) net.Start("LFI:RTV") net.WriteString("open") net.Send(ply) end

    net.Receive("LFI:RTV", function(_, ply)
        if not gmlfi.rtv.started then return end

        local map = net.ReadString()
        if not map or map == "" or ply.LFIRTV == map then return end
        if gmlfi.rtv.votes[map] then
            if ply.LFIRTV then gmlfi.rtv.votes[ply.LFIRTV] = gmlfi.rtv.votes[ply.LFIRTV] - 1 gmlfi.rtv.Update(ply, ply.LFIRTV) end
            gmlfi.rtv.votes[map] = gmlfi.rtv.votes[map] + 1
            ply.LFIRTV = map

            print(string.format("%s [%s] voted for %s", ply:Name(), ply:SteamID(), map))
            gmlfi.rtv.Update(ply, map, true)

            if gmlfi.rtv.votes[map] == player.GetCount() then timer.Remove("LFI:RTV") gmlfi.rtv.Finish() end
        end
    end)

    local maps = {
        "gm_metro_chapaevskaya_line_redux",
        "gm_metro_kalinin_v3",
        "gm_metro_kaluzhskaya_line6",
        "gm_metro_mosldl_v1",
        "gm_metro_mpl_v1",
        "gm_metro_nekrasovskaya_line_v6",
        "gm_metro_nsk_line_2_v6",
        "gm_metro_pink_line_metromart_v2",
        "gm_metro_sunnytown_v2",
        "gm_mus_neoorange_d",
        "gm_mustox_neocrimson_line_a"
    }
    do
        local t = {}
        for k, v in ipairs(gmlfi.rtv.maps) do t[v] = k end
        ::fix::
        for _, v in ipairs(maps) do if not t[v] then table.remove(maps, t[v]) t[v] = nil goto fix end end
    end
    local cur = file.Read("start_map_old.txt", "DATA")
    for _, v in RandomPairs(maps) do if cur ~= v and current ~= v then file.Write("start_map.txt", v) break end end
end

if CLIENT then
    local blur = Material("pp/blurscreen")
    local DrawBlur = function(panel, w, h)
        local x, y = panel:LocalToScreen(0, 0)
    
        local oc = DisableClipping(true)
        surface.SetMaterial(blur)
        surface.SetDrawColor(255, 255, 255, 255)
    
        for i = 0.33, 1, 0.33 do
            blur:SetFloat("$blur", 5 * i)
            blur:Recompute()
    
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(-x, -y, w or ScrW(), h or ScrH())
        end
    
        surface.SetDrawColor(10, 10, 10, 250)
        surface.DrawRect(-x, -y, w or ScrW(), h or ScrH())
        DisableClipping(oc)
    end

    local sw, sh = ScrW(), ScrH()
    local hh = function(h) return h / 1080 * sh end
    local ww = hh
    
    surface.CreateFont("LFI:RTV.Title", {
        font = "Roboto",
        size = ww(96),
        weight = 800,
        extended = true
    })

    surface.CreateFont("LFI:RTV.SubTitle", {
        font = "Roboto",
        size = ww(48),
        weight = 800,
        extended = true
    })

    surface.CreateFont("LFI:RTV.Time", {
        font = "Roboto",
        size = ww(64),
        weight = 800,
        extended = true
    })

    surface.CreateFont("LFI:RTV.SubTime", {
        font = "Roboto",
        size = ww(32),
        weight = 800,
        extended = true
    })
    
    surface.CreateFont("LFI:RTV", {
        font = "Roboto",
        size = ww(16),
        weight = 800,
        extended = true
    })

    surface.CreateFont("LFI:RTV.Votes", {
        font = "Roboto",
        size = ww(128),
        weight = 800,
        extended = true
    })

    local wh = Color(255, 255, 255)
    local gradient = Material("gui/gradient_up")
    local col_sel, col_lose, col_win, col_draw = Color(255, 255, 255, 127), Color(166, 255, 0), Color(0, 255, 150), Color(0, 238, 255)

    timer.Simple(0, function() gmlfi.vgui.DownloadMaterial("check_circle", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/image_2026-07-21_20-47-04.png") end)
    
    local selected = ""
    gmlfi.rtv.winner = ""
    gmlfi.rtv.endtime = 0
    gmlfi.rtv.panels = gmlfi.rtv.panels or {}
    gmlfi.rtv.Create = function()
        if IsValid(gmlfi.rtv.panels.frame) then gmlfi.rtv.panels.frame:Remove() end
        gmlfi.rtv.panels.frame = vgui.Create("DFrame")
        gmlfi.rtv.panels.frame:SetSize(sw, sh)
        gmlfi.rtv.panels.frame:MakePopup()
        gmlfi.rtv.panels.frame:SetKeyboardInputEnabled(false)
        gmlfi.rtv.panels.frame:SetTitle("")
        gmlfi.rtv.panels.frame:ShowCloseButton(false)
        gmlfi.rtv.panels.frame.Paint = function(self, w, h)
            DrawBlur(self)
            draw.SimpleText("ГОЛОСОВАНИЕ", "LFI:RTV.Title", ww(100), hh(80), wh)
            draw.SimpleText("за смену карты", "LFI:RTV.SubTitle", ww(100), hh(180), wh)

            local still = gmlfi.rtv.endtime ~= 0
            draw.SimpleText(still and gmlfi.FormatTimeMinutes(gmlfi.rtv.endtime - CurTime()) or "Завершено", "LFI:RTV.Time", w - ww(100), hh(80), wh, TEXT_ALIGN_RIGHT)
            if still then draw.SimpleText("до конца голосования", "LFI:RTV.SubTime", w - ww(100), hh(155), wh, TEXT_ALIGN_RIGHT) end
        end

        local close = vgui.Create("DButton", gmlfi.rtv.panels.frame)
        close:SetPos(sw - ww(427), hh(220))
        close:SetSize(ww(327), hh(48))
        close:SetText("")
        close.Paint = function(_, w, h)
            surface.SetDrawColor(25, 25, 25)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("Скрыть", "LFI:RTV.SubTime", w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        close.DoClick = function()
            gmlfi.rtv.panels.frame:Close()
        end

        local scwoll = vgui.Create("DScrollPanel", gmlfi.rtv.panels.frame)
        scwoll:SetPos(ww(100), hh(308))
        scwoll:SetSize(ww(1720), hh(672))
        scwoll.Paint = function() end
        scwoll.PaintOver = function(_, w, h)
            surface.SetDrawColor(0, 0, 0)
            surface.SetMaterial(gradient)
            surface.DrawTexturedRect(0, h - hh(188), w, hh(188))
        end
        local vbar = scwoll:GetVBar()
        vbar:SetWide(1)
        vbar:SetHideButtons(true)

        local layout = vgui.Create("DGrid", scwoll)
        layout:SetSize(scwoll:GetSize())
        layout:SetCols(8)
        layout:SetColWide(ww(217))
        layout:SetRowHeight(ww(242))

        local webmats = gmlfi.vgui.webmats
        -- local colfg, colsel = Color(0, 0, 0, 200), Color(0, 255, 0)
        local thumbs = {}
        for map, votes in pairs(gmlfi.rtv.maps) do
            if not thumbs[map] then local mat = Material(string.format("maps/thumb/%s.png", map)) thumbs[map] = mat:IsError() and Material("maps/thumb/noicon.png") or mat end
            local item = vgui.Create("DButton")
            item:SetSize(ww(200), hh(225))
            item:SetText("")
            item:SetTooltip(map)
            layout:AddItem(item)
            item.Paint = function(self, w, h)
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(thumbs[map])
                surface.DrawTexturedRect(0, 0, w, h - hh(25))

                surface.SetDrawColor(0, 0, 0, 191)
                surface.DrawRect(0, 0, w, h - hh(25))

                votes = gmlfi.rtv.maps[map]
                local ic = map == current
                if votes ~= 0 then draw.SimpleText(votes, "LFI:RTV.Votes", w / 2, (h - hh(25)) / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
                draw.SimpleText(ic and "Оставить текущую" or map, "LFI:RTV", w / 2, h - hh(20), ic and col_draw or wh, TEXT_ALIGN_CENTER)

                local sel = selected == map
                local col = gmlfi.rtv.winner == map and (ic and col_draw or sel and col_win or col_lose) or sel and col_sel
                if col then
                    surface.SetDrawColor(col)
                    surface.SetMaterial(webmats.check_circle)
                    surface.DrawTexturedRect(w - ww(53), hh(5), ww(48), hh(48))
                end
            end
            item.DoClick = function()
                selected = map
                net.Start("LFI:RTV")
                net.WriteString(map)
                net.SendToServer()
            end
            local x = item:GetWide() - ww(21)
            item.Think = function()
                if not item.VoterList and item:IsHovered() then
                    local p = vgui.Create("EditablePanel", item)
                    p:Dock(FILL)
                    p:DockMargin(0, 0, 0, hh(25))
                    p:SetMouseInputEnabled(false)
                    item.VoterList = p
                    local l = {}
                    p.Paint = function(_, w, h)
                        surface.SetDrawColor(0, 0, 0, 127)
                        surface.DrawRect(0, 0, w, h)
                        for k, v in ipairs(l) do
                            draw.SimpleText(v, "LFI:RTV", x - ww(5), hh(5) + (k - 1) * hh(21), wh, TEXT_ALIGN_RIGHT)
                        end
                    end
                    local last --= votes
                    p.Think = function()
                        if votes ~= last then
                            last = votes
                            p:Clear()
                            l = {}
                            for k, v in ipairs(player.GetHumans()) do
                                if v.LFIRTV == map then
                                    i = #l + 1
                                    l[i] = v:Name()
                                    local pfp = vgui.Create("AvatarImage", p)
                                    pfp:SetPos(x, hh(5) + (i - 1) * hh(21))
                                    pfp:SetSize(ww(16), hh(16))
                                    pfp:SetPlayer(v, 32)
                                end
                            end
                        end
                    end
                elseif item.VoterList and not item:IsHovered() then
                    item.VoterList:Remove()
                    item.VoterList = nil
                end
            end
        
            -- local image = vgui.Create("DImage", item)
            -- image:Dock(FILL)
            -- image:SetMaterial(thumbs[map])
            -- image.PaintOver = function(self, w, h)
            --     draw.RoundedBox(0, 0, 0, w, h, colfg)
            --     draw.SimpleText(votes, "LFI:RTV.Title", w / 2, h / 2, selected == map and colsel or wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- end

            -- local label = vgui.Create("DPanel", item)
            -- label:Dock(BOTTOM)
            -- label.Paint = function(self, w, h) draw.SimpleText(map, "LFI:RTV", w / 2, h / 2, gmlfi.rtv.winner == map and colsel or wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        end
    end

    local events = {
        ["start"] = function()
            selected = ""
            gmlfi.rtv.maps = {}
            gmlfi.rtv.endtime = CurTime() + gmlfi.rtv.timer
            gmlfi.rtv.winner = ""

            for _, v in ipairs(util.JSONToTable(net.ReadString())) do gmlfi.rtv.maps[v] = 0 end
            -- gmlfi.rtv.Create()
            for k, v in ipairs(player.GetHumans()) do v.LFIRTV = nil end
        end,
        ["stop"] = function()
            gmlfi.rtv.maps = {}
            gmlfi.rtv.endtime = 0
            gmlfi.rtv.winner = ""
            if IsValid(gmlfi.rtv.panels.frame) then gmlfi.rtv.panels.frame:Remove() end
        end,
        ["end"] = function()
            gmlfi.rtv.winner = net.ReadString()
            gmlfi.rtv.endtime = 0

            if gmlfi.rtv.winner == "" then chat.AddText("По итогам голосования ничего не было выбрано")
            elseif gmlfi.rtv.winner == current then chat.AddText("По итогам голосования карта была оставлена")
            elseif gmlfi.rtv.winner ~= "" then chat.AddText("По итогам голосования выиграла карта ", Color(50, 150, 255), gmlfi.rtv.winner) end

            surface.PlaySound("garrysmod/save_load4.wav")
            --if IsValid(gmlfi.rtv.panels.frame) then gmlfi.rtv.panels.frame:Remove() end
        end,
        ["votes"] = function()
            local ply, notify = net.ReadEntity(), net.ReadBool()
            local map, votes = net.ReadString(), net.ReadUInt(7)
            if gmlfi.rtv.maps[map] then gmlfi.rtv.maps[map] = votes end
            if IsValid(ply) then
                if notify and IsValid(ply) and (not ply.LFIRTVLAST or ply.LFIRTVLAST <= CurTime()) then ply.LFIRTVLAST = CurTime() + 3 chat.AddText(team.GetColor(ply:Team()), ply:Name(), Color(255, 255, 255), " проголосовал за карту ", Color(50, 150, 255), map, Color(100, 100, 100), string.format(" [%s/%s]", votes, player.GetCount())) end
                ply.LFIRTV = map
            end
        end,
        ["open"] = function() gmlfi.rtv.Create() end
    }

    net.Receive("LFI:RTV", function()
        local event = net.ReadString()
        if events[event] then events[event]() end
    end)
end
