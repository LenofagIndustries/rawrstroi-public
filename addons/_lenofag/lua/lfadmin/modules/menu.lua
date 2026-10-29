LFAdmin.Command({"motd", "rules"}, "u", {}, nil, function()
    local sw, sh = ScrW(), ScrH()
    local ww = function(w) return w / 1920 * sw end
    local hh = function(h) return h / 1080 * sh end

    local frame = vgui.Create("LFI:Frame")
    frame:SetSize(ww(951), hh(578))
    frame:Center()
    frame:MakePopup()
    frame:SetText("Правила сервера")

    local html = vgui.Create("DHTML", frame)
    html:SetPos(ww(20), hh(71))
    html:SetSize(ww(911), hh(487))
    html:OpenURL("https://" .. gmlfi.rulesURL)
    html:SetAllowLua(false)
end)

if CLIENT then
    hook.Add("InitPostEntity", "LFAdmin:MOTD.ThatNoOneReads", function()
        timer.Simple(5, function() LFAdmin.Commands["motd"].client() end)
    end)
end

LFAdmin.Command({"addons", "content"}, "u", {}, function(ply)
    LFAdmin.LogPlayer(ply, "Контент сервера доступен по ссылке: ", "#" .. gmlfi.serverContent)
end, function() gui.OpenURL("https://" .. gmlfi.serverContent) end)

LFAdmin.Command("discord", "u", {}, function(ply)
    LFAdmin.LogPlayer(ply, "Ссылка на наш Discord сервер: ", "#" .. gmlfi.discordDirect)
end, function() gui.OpenURL("https://" .. gmlfi.discordDirect) end)

LFAdmin.CommandDescription("motd", "Открывает правила сервера")
LFAdmin.CommandDescription("addons", "Открывает контент сервера")
LFAdmin.CommandDescription("discord", "Открывает Discord сервер... сервера")

LFAdmin.Command("menu", "u", {}, nil, function()
    local sw, sh = ScrW(), ScrH()
    local ww = function(w) return w / 1920 * sw end
    local hh = function(h) return h / 1080 * sh end
    local wh, bl, gr = Color(255, 255, 255), Color(0, 0, 0), Color(100, 100, 100)
    local bs, bh, bi, bn = Color(74, 74, 74), Color(50, 50, 50), Color(31, 31, 31), Color(45, 45, 45)
    local ml, cbd = Color(50, 50, 50, 100), Color(50, 50, 50, 200)
    local th, tc = Color(60, 0, 180), Color(105, 0, 255)
    local cbb, cbh, cbs = Color(20, 20, 20, 200), Color(60, 60, 60), Color(75, 75, 75)

    local FONT_ARG, FONT_TIME = gmlfi.vgui.Font(".LFA.Menu", 14, 700), gmlfi.vgui.Font(".LFA.Menu.Time", 12, 700)
    local webmats = gmlfi.vgui.webmats

    local me = LocalPlayer()
    local args args = {
        string = function(parent)
            local p = vgui.Create("DPanel", parent)
            p.Paint = function(self, w, h)
                surface.SetDrawColor(bi)
                surface.DrawRect(0, 0, w, h)
            end

            local inp = vgui.Create("DTextEntry", p)
            inp:Dock(FILL)
            inp:DockMargin(ww(4), 0, 0, 0)
            inp:SetPlaceholderText("Введите строку...")
            inp:SetTextColor(wh)
            inp:SetFont(FONT_ARG)
            inp.Paint = function(self, w, h)
                if self:GetValue() ~= "" then self:DrawTextEntryText(wh, th, tc)
                elseif self:GetPlaceholderText() and self:GetPlaceholderText() ~= "" then
                    local old = self:GetText()
                    self:SetText(self:GetPlaceholderText())
                    self:DrawTextEntryText(gr, th, tc)
                    self:SetText(old)
                end
            end

            return p, function() return inp:GetValue() end
        end,
        number = function(parent)
            local p = vgui.Create("DPanel", parent)
            p.Paint = function(self, w, h)
                surface.SetDrawColor(bi)
                surface.DrawRect(0, 0, w, h)
            end

            local inp = vgui.Create("DNumberWang", p)
            inp:Dock(FILL)
            inp:DockMargin(ww(4), 0, 0, 0)
            inp:SetPlaceholderText("Введите число...")
            inp:SetMinMax(0, 100000)
            inp:HideWang()
            inp:SetTextColor(wh)
            inp:SetFont(FONT_ARG)
            inp:SetText("")
            inp.Paint = function(self, w, h)
                if self:GetText() ~= "" then self:DrawTextEntryText(wh, th, tc)
                elseif self:GetPlaceholderText() and self:GetPlaceholderText() ~= "" then
                    local old = self:GetText()
                    self:SetText(self:GetPlaceholderText())
                    self:DrawTextEntryText(gr, th, tc)
                    self:SetText(old)
                end
            end

            return p, function() return inp:GetValue() end
        end,
        player = function(parent, command)
            local box = vgui.Create("DComboBox", parent)
            box:SetValue("Выберите игрока...")
            box:SetTextColor(wh)
            box:SetFont(FONT_ARG)
            for k, v in ipairs(player.GetAll()) do if command.SkipAccessCheck or me:CanTarget(v) then box:AddChoice(string.format("%s (%s, %s)", v:Name(), v:GetUserGroup(), v:SteamID()), v:SteamID()) end end
            local d
            box.OnSelect = function(self, _, _, data) d = data end
            box.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, self:IsDown() and tc or bi)
            end

            return box, function() return d end
        end,
        steamid = function(parent, command)
            local p = vgui.Create("DPanel", parent)
            p.Paint = function(self, w, h)
                surface.SetDrawColor(bi)
                surface.DrawRect(0, 0, w, h)
            end

            local inp = vgui.Create("DTextEntry", p)
            inp:Dock(FILL)
            inp:DockMargin(ww(4), 0, 0, 0)
            inp:SetPlaceholderText("Выберите игрока или SteamID...")
            inp:SetTextColor(wh)
            inp:SetFont(FONT_ARG)
            inp.Paint = function(self, w, h)
                if self:GetValue() ~= "" then self:DrawTextEntryText(wh, th, tc)
                elseif self:GetPlaceholderText() and self:GetPlaceholderText() ~= "" then
                    local old = self:GetText()
                    self:SetText(self:GetPlaceholderText())
                    self:DrawTextEntryText(gr, th, tc)
                    self:SetText(old)
                end
            end

            local box = vgui.Create("DComboBox", inp)
            box:Dock(RIGHT)
            box:DockMargin(0, ww(4), ww(4), ww(4))
            box:SetWide(ww(14))
            box:SetValue("")
            box.DropButton.Paint = function() end
            for k, v in ipairs(player.GetAll()) do if command.SkipAccessCheck or me:CanTarget(v) then box:AddChoice(string.format("%s (%s, %s)", v:Name(), v:GetUserGroup(), v:SteamID()), v:SteamID()) end end
            local d
            box.OnSelect = function(self, _, _, data) inp:SetValue(data) inp:SetText(data) self:SetValue("") end
            box.Paint = function(self, w, h)
                surface.SetDrawColor(self:IsDown() and cbs or self:IsHovered() and bs or bh)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(webmats.navigate_manual)
                surface.DrawTexturedRect(0, 0, w, h)
            end

            return p, function() return inp:GetValue() end
        end,
        time = function(parent)
            local p = vgui.Create("DPanel", parent)
            p:DockPadding(ww(4), ww(4), ww(4), ww(4))
            p.Paint = function(self, w, h)
                surface.SetDrawColor(bi)
                surface.DrawRect(0, 0, w, h)
            end

            local t = {}
            for k, v in ipairs({{"w", "нед"}, {"d", "дн"}, {"h", "ч"}, {"mi", "м"}, {"s", "с"}}) do
                local a = vgui.Create("DPanel", p)
                a:Dock(LEFT)
                a:SetWidth(ww(51))
                a.Paint = function(self, w, h) draw.SimpleText(v[2], FONT_TIME, ww(27), h / 2, gr, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end

                local inp = vgui.Create("DNumberWang", a)
                inp:Dock(FILL)
                inp:DockMargin(0, 0, ww(27), 0)
                inp:SetPlaceholderText("00")
                inp:SetMinMax(0, 100000)
                inp:HideWang()
                inp:SetText("")
                inp.Paint = function(self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, bh)
                    if self:GetText() ~= "" then draw.SimpleText(self:GetValue(), FONT_ARG, w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    elseif self:GetPlaceholderText() and self:GetPlaceholderText() ~= "" then
                        draw.SimpleText(self:GetPlaceholderText(), FONT_ARG, w / 2, h / 2, gr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
                inp.InpK = v[1]
                t[k] = inp
            end

            return p, function()
                local a = {}
                for k, v in ipairs(t) do if v:GetValue() ~= 0 then a[#a + 1] = v:GetValue() .. v.InpK end end
                return table.concat(a, "")
            end
        end
    }
    args.players = args.player

    local frame = vgui.Create("LFI:Frame")
    frame:SetSize(ww(945), hh(515))
    frame:Center()
    frame:MakePopup()
    frame:SetText("Меню")

    local list = vgui.Create("LFI:Panel", frame)
    list:SetPos(ww(20), hh(71))
    list:SetSize(ww(646), hh(391))
    list:DockPadding(ww(4), hh(4), ww(4), hh(4))

    local update, things = nil, {}
    local fill = function(str) -- me uwu
        local cats = {}
        local found = {}
        for name, command in pairs(LFAdmin.Commands) do
            if command.SkipHelp or not LFAdmin.CanAccess(LocalPlayer(), name) or found[command.name] or not string.find(string.lower(name), string.lower(str)) then continue end -- aliases
            found[command.name] = true
            local cfun = command.callback or command.client
            local cname = cfun and string.GetFileFromFilename(debug.getinfo(cfun).short_src) or "other" local oc = cats[cname]
            cats[cname] = oc or {} oc = cats[cname]
            oc[#oc + 1] = name
            table.sort(oc, function(a, b) return a < b end)
        end

        local i = 0
        for cat, kittens in pairs(cats) do -- meow family
            i = i + 1
            local label = vgui.Create("DLabel", list)
            label:Dock(TOP)
            label:DockMargin(4, 4, 4, 0)
            label:SetText("")
            label:SetTextColor(wh)
            label:SetZPos(i)
            label.PaintOver = function(self, w, h)
                draw.SimpleText(cat, "LFI:VGUI.ButtonTitle", 0, 0, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2)
                draw.RoundedBox(0, 0, h - 1, w, 1, wh)
            end
            things[#things + 1] = label

            for k, name in ipairs(kittens) do i = i + 1
                local command = LFAdmin.Commands[name]
                local item = vgui.Create("LFI:ButtonDesc", list)
                item:Dock(TOP)
                item:DockMargin(ww(4), hh(4), ww(4), 0)
                item:SetZPos(i)

                item:SetTitleText(name)
                item:SetDescriptionText((command.description and (utf8.len(command.description) > 100 and utf8.sub(command.description, 1, 99) .. "…" or command.description) or "Описание отсутствует") .. ".")
                item:SetHoverHighlight(true)
                if command.access and command.access ~= "u" then
                    item.PaintOver = function(_, w)
                        draw.SimpleText(command.access, "LFI:VGUI.ButtonTitle", w - ww(8), hh(13), gr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    end
                end

                item.DoClick = function()
                    update(command, name)
                end
                things[#things + 1] = item
            end
        end
    end

    fill("")

    local p = vgui.Create("DPanel", frame)
    p:SetPos(ww(20), hh(467))
    p:SetSize(ww(646), hh(28))
    p.Paint = function(self, w, h)
        surface.SetDrawColor(cbd)
        surface.DrawRect(0, 0, w, h)
    end

    local inp = vgui.Create("DTextEntry", p)
    inp:Dock(FILL)
    inp:DockMargin(ww(4), 0, 0, 0)
    inp:SetPlaceholderText("Введите название команды...")
    inp:SetTextColor(wh)
    inp:SetFont(FONT_ARG)
    inp.Paint = function(self, w, h)
        if self:GetValue() ~= "" then self:DrawTextEntryText(wh, th, tc)
        elseif self:GetPlaceholderText() and self:GetPlaceholderText() ~= "" then
            local old = self:GetText()
            self:SetText(self:GetPlaceholderText())
            self:DrawTextEntryText(gr, th, tc)
            self:SetText(old)
        end
    end
    inp.OnEnter = function()
        for k, v in ipairs(things) do if IsValid(v) then v:Remove() end end
        fill(inp:GetValue())
    end

    local largs = vgui.Create("LFI:Panel", frame)
    largs:SetPos(ww(670), hh(71))
    largs:SetSize(ww(255), hh(424))
    largs:DockPadding(ww(4), hh(4), ww(4), hh(4))

    update = function(command, name)
        largs:Clear()

        local ca = {}
        local argn = command.argn
        for k, v in ipairs(command.args or {}) do
            if argn and argn[k] then
                local label = vgui.Create("DLabel", largs)
                label:Dock(TOP)
                label:DockMargin(hh(4), hh(4), hh(4), 0)
                label:SetText("")
                label:SetTextColor(wh)
                label.PaintOver = function(self, w, h)
                    draw.SimpleText(argn[k], "LFI:VGUI.ButtonTitle", 0, 0, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2)
                    draw.RoundedBox(0, 0, h - 1, w, 1, wh)
                end
            end

            local p, cb = (args[string.sub(v, -1) == "?" and string.sub(v, 1, -2) or v] or args.string)(largs, command)
            p:Dock(TOP)
            p:DockMargin(ww(4), hh(4), ww(4), 0)
            p:SetTall(hh(22))
            ca[k] = cb or false
        end

        local call = vgui.Create("DButton", largs)
        call:SetPos(ww(4), hh(397))
        call:SetSize(ww(245), hh(22))
        call:SetText("")
        call.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsDown() and cbs or self:IsHovered() and cbh or cbb)
            draw.SimpleText("Выполнить \"" .. name .. "\"", "LFI:VGUI.ButtonTitle", w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        call.DoClick = function()
            local c = {}
            for k, v in ipairs(ca) do c[k] = tostring(v() or "") end
            PrintTable(c)
            RunConsoleCommand("lf", name, unpack(c))
        end

        largs:InvalidateLayout()
    end
end)

LFAdmin.Command("donate", "u", {}, function(ply) gmlfi.donate.Menu(ply) end)
