if not gmlfi then return print("editor says gmlfi is nil...") end

-- wow lua editor
-- by lenofag.ru

-- credits:
-- Metastruct - https://github.com/Metastruct/lua_editor
-- Zvbhrf - cuz he is a cool furry guy (https://yamirka.net/)
-- Lenofag-2000 - literally me xd (https://lenofag.ru/)

local RunString = RunString

gmlfi.editor.availableThemes = {
    "ambiance", "chaos", "chrome", "clouds", "clouds_midnight",
    "cobalt", "crimson_editor", "dawn", "dreamweaver",
    "eclipse", "github", "idle_fingers", "iplastic",
    "katzenmilch", "kr_theme", "kuroir", "merbivore",
    "merbivore_soft", "mono_industrial", "monokai",
    "pastel_on_dark", "solarized_dark", "solarized_light",
    "sqlserver", "terminal", "textmate", "tomorrow",
    "tomorrow_night", "tomorrow_night_blue", "tomorrow_night_bright",
    "tomorrow_night_eighties", "twilight", "vibrant_ink", "xcode"
}

gmlfi.editor.settings = {
    configfile = "editor.json",
    tabsfile = "editor_tabs.json",
    colors = {
        bg = Color(20, 20, 20, 250),
        tabsbg = Color(40, 40, 40, 200),
        tabbg = Color(50, 50, 50, 200),
        tabbgactive = Color(100, 50, 50, 200),
    },
    theme = "merbivore",
    fontsize = 15
}

gmlfi.editor.codeDefault = "-- Welcome to Lua Editor!\n-- This editor uses https://github.com/Metastruct/lua_editor\n-- Thanks Metastruct!"
gmlfi.editor.code = gmlfi.editor.code or ""
gmlfi.editor.panels = gmlfi.editor.panels or {}

gmlfi.editor.IsSelectedPanelValid = function() return gmlfi.editor.selected and IsValid(gmlfi.editor.selected) end
gmlfi.editor.SetSelectedTabName = function(name) if gmlfi.editor.IsSelectedPanelValid() then gmlfi.editor.selected:SetText(name or "[name = " .. type(name) .. "!]") end end

gmlfi.editor.LoadSettings = function()
    local content = gmlfi.file.Read(gmlfi.editor.settings.configfile)
    if not content then print(string.format("Saving default settings to %s...", gmlfi.editor.settings.configfile)) return gmlfi.editor.SaveSettings() end

    content = util.JSONToTable(content)
    if not content then return print("Failed to load settings: JSON parse returned nil!") end

    if not content.colors or not table.GetKeys(gmlfi.editor.settings.colors) == table.GetKeys(content.colors) then return print("Failed to load settings: colors are invalid!") end
    if not content.theme or not table.HasValue(gmlfi.editor.availableThemes, content.theme) then return print("Failed to load settings: theme is invalid or does not exist!") end
    if not content.fontsize or content.fontsize <= 0 then return print("Failed to load settings: font size is invalid!") end

    content.fontsize = math.Clamp(content.fontsize, 8, 48)
    content.configfile = gmlfi.editor.settings.configfile
    content.tabsfile = gmlfi.editor.settings.tabsfile
    gmlfi.editor.settings = content
    gmlfi.editor.UpdateEditorSettings()
    gmlfi.editor.SaveSettings()
    print(string.format("Editor settings loaded from %s", gmlfi.editor.settings.configfile))
end
gmlfi.editor.SaveSettings = function() gmlfi.file.Write(gmlfi.editor.settings.configfile, util.TableToJSON(gmlfi.editor.settings, true)) end

gmlfi.editor.LoadTabs = function()
    local content = gmlfi.file.Read(gmlfi.editor.settings.tabsfile) if not content then print(string.format("Saving empty editor tabs to %s...", gmlfi.editor.settings.tabsfile)) gmlfi.editor.SaveTabs(true) return end
    local tabs = util.JSONToTable(content) if not tabs then return print(string.format("Failed to load tabs: JSON parse returned nil!")) end
    print(string.format("Editor tabs (%s total) loaded from %s", #tabs, gmlfi.editor.settings.tabsfile))
    return tabs
end
gmlfi.editor.SaveTabs = function(nonotify)
    local tabs = {}
    local function append(v) tabs[#tabs + 1] = {code = v.code or "", name = v:GetText() or "Tab #" .. k, selected = v == gmlfi.editor.selected, main = v._main or false} end

    if IsValid(gmlfi.editor.panels.mainsheet) then append(gmlfi.editor.panels.mainsheet) end
    for k, v in ipairs(gmlfi.editor.panels.tabs) do
        if not IsValid(v) then continue end
        append(v)
    end
    gmlfi.file.Write(gmlfi.editor.settings.tabsfile, util.TableToJSON(tabs))
    if not nonotify then print(string.format("Editor tabs (%s total) saved to %s", #tabs, gmlfi.editor.settings.tabsfile)) end
end

gmlfi.editor.UpdateTheme = function() gmlfi.editor.panels.html:QueueJavascript(string.format("editor.setTheme('ace/theme/%s')", gmlfi.editor.settings.theme)) end
gmlfi.editor.UpdateFontSize = function() gmlfi.editor.panels.html:QueueJavascript(string.format("SetFontSize(%s)", gmlfi.editor.settings.fontsize)) end
gmlfi.editor.UpdateEditorSettings = function()
    gmlfi.editor.panels.html:QueueJavascript(string.format("editor.setTheme('ace/theme/%s'); editor.getSession().setUseSoftTabs(true); SetFontSize(%s)", gmlfi.editor.settings.theme, gmlfi.editor.settings.fontsize))
end

gmlfi.editor.SetCode = function(code)
    if gmlfi.editor.IsSelectedPanelValid() then gmlfi.editor.selected.code = code end
    gmlfi.editor.code = code
    gmlfi.editor.panels.html:QueueJavascript("SetContent('" .. string.JavascriptSafe(gmlfi.editor.code or gmlfi.editor.codeDefault) .. "'); GotoLine(1);")
end

gmlfi.editor.panels.CreateSettingsPanel = function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Lua Editor - Settings")
    frame:SetSize(ScrW() / 5, ScrH() / 6)
    frame:MakePopup()
    frame:Center()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, gmlfi.editor.settings.colors.bg)
    end

    local panel = vgui.Create("DScrollPanel", frame)
    panel:Dock(FILL)
    panel.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, gmlfi.editor.settings.colors.tabsbg, true, true, false, false)
    end

    local combo = vgui.Create("DComboBox", panel)
    combo:Dock(TOP)
    combo:SetValue("Theme - " .. gmlfi.editor.settings.theme)
    
    combo.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, (self:IsDown() or gmlfi.editor.selected == self) and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg)
    end

    for k, v in ipairs(gmlfi.editor.availableThemes) do
        combo:AddChoice(v)
    end

    combo.OnSelect = function(_, _, val)
        combo:SetValue("Theme - " .. val)
        gmlfi.editor.settings.theme = val
        gmlfi.editor.UpdateTheme()
    end

    local fontslider = vgui.Create("DNumSlider", panel)
    fontslider:Dock(TOP)
    fontslider:DockMargin(6, 0, 0, 0)
    fontslider:SetText("Font size")
    fontslider:SetMin(8)
    fontslider:SetMax(48)
    fontslider:SetDecimals(0)
    fontslider:SetValue(gmlfi.editor.settings.fontsize)
    fontslider.OnValueChanged = function(self, val)
        gmlfi.editor.settings.fontsize = val
        gmlfi.editor.UpdateFontSize()
    end

    local loadbtn = vgui.Create("DButton", frame)
    loadbtn:Dock(BOTTOM)
    loadbtn:SetText("Load settings")
    loadbtn.DoClick = function()
        gmlfi.editor.LoadSettings()
        combo:SetValue("Theme - " .. gmlfi.editor.settings.theme)
        fontslider:SetValue(gmlfi.editor.settings.fontsize)
    end
    loadbtn.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, (self:IsDown() or gmlfi.editor.selected == self) and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg, false, false, true, true)
    end

    local savebtn = vgui.Create("DButton", frame)
    savebtn:Dock(BOTTOM)
    savebtn:SetText("Save settings")
    savebtn.DoClick = function()
        gmlfi.editor.SaveSettings()
        surface.PlaySound("garrysmod/content_downloaded.wav")
        print(string.format("Editor settings saved to %s", gmlfi.editor.settings.configfile))
    end
    savebtn.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, (self:IsDown() or gmlfi.editor.selected == self) and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg, false, false, false, false)
    end
end

gmlfi.editor.panels.CreateFileSelector = function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Lua Editor - File Selector")
    frame:SetSize(ScrW() / 4, ScrH() / 2)
    frame:SetSizable(true)
    frame:MakePopup()
    frame:Center()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, gmlfi.editor.settings.colors.bg)
    end

    local panel = vgui.Create("DPanel", frame)
    panel:Dock(FILL)
    panel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, gmlfi.editor.settings.colors.tabsbg)
    end

    local tree = vgui.Create("DTree", panel)
    tree:Dock(FILL)

    tree.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, gmlfi.editor.settings.colors.tabsbg)
    end

    local selected = false

    tree.AddFolderRec = function(dir, node)
        local menode = node:AddNode(string.GetFileFromFilename(dir), "icon16/folder.png")

        dir = dir .. "/"
        local files, folders = file.Find(dir .. "*", "MOD", "nameasc")
        
        for k, v in ipairs(folders) do
            tree.AddFolderRec(dir .. v, menode)
        end

        for k, v in ipairs(files) do
            if string.GetExtensionFromFilename(v) == "lua" then
                local fnode = menode:AddNode(v, "icon16/page.png")
                fnode.DoClick = function()
                    selected = dir .. v
                end
            end
        end

        return menode
    end

    tree.AddFolderRec("lua", tree):SetExpanded(true, true)

    local opennow = vgui.Create("DButton", panel)
    opennow:Dock(BOTTOM)
    opennow:SetText("Open selected")
    opennow.DoClick = function()
        if not selected or not file.Exists(selected, "MOD") then return surface.PlaySound("friends/message.wav") end

        local content = file.Read(selected, "MOD")
        gmlfi.editor.SetCode(content or "-- File contents is nil???")
        gmlfi.editor.SetSelectedTabName(string.GetFileFromFilename(selected))

        frame:Remove()
    end

    opennow.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, (self:IsDown() or gmlfi.editor.selected == self) and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg)
    end
end

gmlfi.editor.panels.CreateSoundBrowser = function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Lua Editor - Sound Browser")
    frame:SetSize(ScrW() / 4, ScrH() / 2)
    frame:SetSizable(true)
    frame:MakePopup()
    frame:Center()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, gmlfi.editor.settings.colors.bg)
    end

    local panel = vgui.Create("DPanel", frame)
    panel:Dock(FILL)
    panel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, gmlfi.editor.settings.colors.tabsbg)
    end

    local mount = "MOD"

    local combo = vgui.Create("DComboBox", panel)
    combo:Dock(TOP)
    combo:SetSortItems(false)
    combo:SetValue("Mount: " .. mount)
    
    combo.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsDown() and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg)
    end

    combo:AddChoice("MOD")
    combo:AddChoice("GAME")
    combo:AddChoice("DOWNLOAD")
    combo:AddChoice("THIRDPARTY")
    combo:AddChoice("WORKSHOP")
    combo:AddChoice("BSP")
    combo:AddSpacer()
    for k, v in ipairs(engine.GetGames()) do if v.mounted then combo:AddChoice(v.title, v.folder) end end

    local tree = vgui.Create("DTree", panel)
    tree:Dock(FILL)

    tree.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, gmlfi.editor.settings.colors.tabsbg)
    end

    local selected = false

    tree.AddFolderRec = function(dir, node)
        local menode = node:AddNode(string.GetFileFromFilename(dir), "icon16/folder.png")

        dir = dir .. "/"
        local files, folders = file.Find(dir .. "*", mount, "nameasc")
        
        for k, v in ipairs(folders) do
            tree.AddFolderRec(dir .. v, menode)
        end

        for k, v in ipairs(files) do
            local fnode = menode:AddNode(v, "icon16/sound.png")
            fnode.DoClick = function()
                selected = string.Replace(dir .. v, "sound/", "")
            end
        end

        return menode
    end

    local curfolder = tree.AddFolderRec("sound", tree) curfolder:SetExpanded(true, true)
    combo.OnSelect = function(_, _, val, data)
        combo:SetValue("Mount: " .. val)
        curfolder:Remove()
        mount = data or val
        curfolder = tree.AddFolderRec("sound", tree) curfolder:SetExpanded(true, true)
    end

    local bottoml = vgui.Create("DPanel", panel)
    bottoml:Dock(BOTTOM)

    local playb = vgui.Create("DButton", bottoml)
    playb:Dock(LEFT)
    playb:SetText("Play")
    playb.DoClick = function()
        if not selected or not file.Exists("sound/" .. selected, "GAME") then return end
        surface.PlaySound(selected)
    end

    playb.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, (self:IsDown() or gmlfi.editor.selected == self) and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg, false, false, true, false)
    end

    local copyb = vgui.Create("DButton", bottoml)
    copyb:Dock(FILL)
    copyb:SetText("Copy selected")
    copyb.DoClick = function()
        if not selected or not file.Exists("sound/" .. selected, "GAME") then return surface.PlaySound("friends/message.wav") end
        SetClipboardText(selected)
    end

    copyb.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, (self:IsDown() or gmlfi.editor.selected == self) and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg, false, false, false, true)
    end
end

gmlfi.editor.panels.Create = function(shouldhide)
    if gmlfi.editor.panels.frame and IsValid(gmlfi.editor.panels.frame) then print("Deleting old frame...", gmlfi.editor.panels.frame) gmlfi.editor.panels.frame:Remove() end

    gmlfi.editor.panels.frame = vgui.Create("DFrame")
    gmlfi.editor.panels.frame:SetDeleteOnClose(false)
    gmlfi.editor.panels.frame:SetSizable(true)
    gmlfi.editor.panels.frame:SetTitle("Lua Editor")
    gmlfi.editor.panels.frame:SetSize(ScrW() / 2, ScrH() / 2.5)
    gmlfi.editor.panels.frame:SetKeyboardInputEnabled(true)
    gmlfi.editor.panels.frame:Center()
    if shouldhide then gmlfi.editor.panels.frame:Hide()
    else gmlfi.editor.panels.frame:MakePopup() end

    gmlfi.editor.panels.frame.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, gmlfi.editor.settings.colors.bg)
    end

    gmlfi.editor.panels.html = vgui.Create("DHTML", gmlfi.editor.panels.frame)
    gmlfi.editor.panels.html:OpenURL("http://metastruct.github.io/lua_editor")
    gmlfi.editor.panels.html:Dock(FILL)
    gmlfi.editor.panels.html:AddFunction("gmodinterface", "OnCode", function(code)
        if gmlfi.editor.IsSelectedPanelValid() then gmlfi.editor.selected.code = code end
        gmlfi.editor.code = code
    end)

    gmlfi.editor.panels.header = vgui.Create("DPanel", gmlfi.editor.panels.frame)
    gmlfi.editor.panels.header:Dock(TOP)
    gmlfi.editor.panels.header:DockPadding(0, 0, 0, 0)
    gmlfi.editor.panels.header:DockMargin(0, 0, 0, 5)
    gmlfi.editor.panels.header:SetHeight(20)
    gmlfi.editor.panels.header.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, gmlfi.editor.settings.colors.tabsbg)
    end

    gmlfi.editor.panels.tabsholder = vgui.Create("DHorizontalScroller", gmlfi.editor.panels.header)
    gmlfi.editor.panels.tabsholder:Dock(FILL)
    gmlfi.editor.panels.tabsholder:SetOverlap(-4)
    gmlfi.editor.panels.tabsholder.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, gmlfi.editor.settings.colors.tabsbg)
    end

    gmlfi.editor.panels.tabs = gmlfi.editor.panels.tabs or {}

    local SetSelectedTab = function(tab)
        if not tab or not IsValid(tab) then return end
        gmlfi.editor.selected = tab
        gmlfi.editor.code = tab.code
        gmlfi.editor.panels.html:QueueJavascript("SetContent('" .. string.JavascriptSafe(gmlfi.editor.code or gmlfi.editor.codeDefault) .. "'); GotoLine(1);")
    end

    local AddTab = function(name, dont, dontsave)
        local pnl = vgui.Create("DButton", gmlfi.editor.panels.tabsholder)

        pnl:SetImage("icon16/page.png")
        pnl:SetText(name)
        pnl:Dock(LEFT)
        pnl:DockMargin(0, 0, 5, 0)
        pnl:SetWidth(80)

        pnl._ID = #gmlfi.editor.panels.tabs + 1

        pnl.code = pnl.code or gmlfi.editor.codeDefault or ""

        pnl.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, (self:IsDown() or gmlfi.editor.selected == self) and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg)
        end

        pnl.DoClick = function()
            gmlfi.editor.selected = pnl
            gmlfi.editor.code = pnl.code
            gmlfi.editor.panels.html:QueueJavascript("SetContent('" .. string.JavascriptSafe(gmlfi.editor.code or gmlfi.editor.codeDefault) .. "'); GotoLine(1);")
        end

        if not dont then
            pnl.DoRightClick = function()
                local dmenu = DermaMenu()
                dmenu:AddOption("Close tab", function()
                    if gmlfi.editor.selected == pnl then SetSelectedTab(gmlfi.editor.panels.mainsheet) end
                    pnl:Remove()
                    gmlfi.editor.panels.tabs[pnl._ID] = nil
                    gmlfi.editor.SaveTabs(true)
                end):SetIcon("icon16/cross.png")
                dmenu:Open()
            end
        end

        gmlfi.editor.panels.tabsholder:AddPanel(pnl)

        if not dont then gmlfi.editor.panels.tabs[pnl._ID] = pnl end
        if not dontsave then gmlfi.editor.SaveTabs(true) end
        return pnl
    end

    do
        local legacy = gmlfi.editor.codeDefault
        if IsValid(gmlfi.editor.panels.mainsheet) then legacy = gmlfi.editor.panels.mainsheet.code or gmlfi.editor.codeDefault gmlfi.editor.panels.mainsheet:Remove() end
        gmlfi.editor.panels.mainsheet = AddTab("Main", true, true)
        gmlfi.editor.panels.mainsheet._main = true
        gmlfi.editor.panels.mainsheet.code  = legacy
    end

    if next(gmlfi.editor.panels.tabs) ~= nil then
        for k, v in pairs(gmlfi.editor.panels.tabs) do
            if not IsValid(v) then continue end
            local code, name, selected = v.code, v:GetText(), v == gmlfi.editor.selected

            print("Moving", v, "to new editor frame")
            v:Remove() gmlfi.editor.panels.tabs[k] = nil

            local new = AddTab(name or "Tab #" .. k, false, true)
            new.code = code or gmlfi.editor.codeDefault
            if selected then gmlfi.editor.selected = new end
        end

        gmlfi.editor.SaveTabs()
    else
        local tabs = gmlfi.editor.LoadTabs()
        if tabs then
            for k, v in pairs(tabs) do
                if v.main then gmlfi.editor.panels.mainsheet.code = v.code print(string.format("Main tab content set from loaded tab")) continue end

                local new = AddTab(v.name or "Tab #" .. k, false, true)
                new.code = v.code or gmlfi.editor.codeDefault
                if v.selected then gmlfi.editor.selected = new end
                print(string.format("Created editor tab from loaded \"%s\"", v.name or "Tab #" .. k))
            end
        end
    end

    --gmlfi.editor.selected = gmlfi.editor.IsSelectedPanelValid() and gmlfi.editor.selected or gmlfi.editor.panels.mainsheet
    SetSelectedTab(gmlfi.editor.IsSelectedPanelValid() and gmlfi.editor.selected or gmlfi.editor.panels.mainsheet)

    gmlfi.editor.panels.runstr = vgui.Create("DButton", gmlfi.editor.panels.header)
    gmlfi.editor.panels.runstr:Dock(LEFT)
    gmlfi.editor.panels.runstr:DockMargin(0, 0, 2, 0)
    gmlfi.editor.panels.runstr:SetText("")
    gmlfi.editor.panels.runstr:SetImage("icon16/script_go.png")
    gmlfi.editor.panels.runstr:SetWidth(24)
    gmlfi.editor.panels.runstr.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsDown() and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg)
    end
    gmlfi.editor.panels.runstr.DoClick = function()
        local dmenu = DermaMenu()

        dmenu:AddOption("Run on self", function()
            if gmlfi.editor.code == "" or string.Trim(gmlfi.editor.code) == "" then surface.PlaySound("friends/message.wav") print("No code to run!") return end

            local out = CompileString(gmlfi.editor.code, "LFI:Editor", false)

            if type(out) ~= "function" then surface.PlaySound("friends/message.wav") print(string.format("Lua syntax error: %s", out)) return end
            gmlfi.editor.MakeEnvironment(out, LocalPlayer())

            local succ, err = pcall(out)
            if not succ then surface.PlaySound("friends/message.wav") print(string.format("Lua execution error: %s", err)) end
        end):SetIcon("icon16/status_offline.png")

        local a = dmenu:AddOption("Run on server", function()
            if gmlfi.editor.code == "" or string.Trim(gmlfi.editor.code) == "" then surface.PlaySound("friends/message.wav") print("No code to run!") return end

            local cmp = util.Compress(gmlfi.editor.code)
            net.Start("LFI:Editor") -- h4ck me
                net.WriteString("server")
                net.WriteUInt(#cmp, 16)
                net.WriteData(cmp)
            net.SendToServer()
        end)
        
        a:SetIcon("icon16/drive_go.png")
        if not LocalPlayer():IsSuperAdmin() then a:SetEnabled(false) a:SetCursor("no") a:SetTooltip("Superadmin only!") end

        local c = dmenu:AddOption("Run shared", function()
            if gmlfi.editor.code == "" or string.Trim(gmlfi.editor.code) == "" then surface.PlaySound("friends/message.wav") print("No code to run!") return end

            local cmp = util.Compress(gmlfi.editor.code)
            net.Start("LFI:Editor") -- h4ck me
                net.WriteString("shared")
                net.WriteUInt(#cmp, 16)
                net.WriteData(cmp)
            net.SendToServer()
        end)

        c:SetIcon("icon16/drive_user.png")
        if not LocalPlayer():IsSuperAdmin() then c:SetEnabled(false) c:SetCursor("no") c:SetTooltip("Superadmin only!") end

        local b = dmenu:AddOption("Run on all clients", function()
            if gmlfi.editor.code == "" or string.Trim(gmlfi.editor.code) == "" then surface.PlaySound("friends/message.wav") print("No code to run!") return end

            local cmp = util.Compress(gmlfi.editor.code)
            net.Start("LFI:Editor")
                net.WriteString("clients")
                net.WriteUInt(#cmp, 16)
                net.WriteData(cmp)
            net.SendToServer()
        end)

        b:SetIcon("icon16/user_go.png")
        if not LocalPlayer():IsSuperAdmin() then b:SetEnabled(false) b:SetCursor("no") b:SetTooltip("Superadmin only!") end

        local subc, c = dmenu:AddSubMenu("Run on client")
        c:SetIcon("icon16/user_add.png")
        if not LocalPlayer():IsSuperAdmin() then c:SetEnabled(false) c:SetCursor("no") c:SetTooltip("Superadmin only!") else
            for k, ply in ipairs(player.GetHumans()) do
                subc:AddOption(ply:Name(), function()
                    if not IsValid(ply) then return end
                    if gmlfi.editor.code == "" or string.Trim(gmlfi.editor.code) == "" then surface.PlaySound("friends/message.wav") print("No code to run!") return end

                    local cmp = util.Compress(gmlfi.editor.code)
                    net.Start("LFI:Editor")
                        net.WriteString("client")
                        net.WriteUInt(#cmp, 16)
                        net.WriteData(cmp)
                        net.WriteEntity(ply)
                    net.SendToServer()
                end):SetIcon("icon16/user.png")
            end
        end
        
        dmenu:Open()
    end

    gmlfi.editor.panels.settings = vgui.Create("DButton", gmlfi.editor.panels.header)
    gmlfi.editor.panels.settings:Dock(RIGHT)
    gmlfi.editor.panels.settings:DockMargin(2, 0, 0, 0)
    gmlfi.editor.panels.settings:SetText("")
    gmlfi.editor.panels.settings:SetImage("icon16/cog.png")
    gmlfi.editor.panels.settings:SetTooltip("Settings")
    gmlfi.editor.panels.settings:SetWidth(24)
    gmlfi.editor.panels.settings.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsDown() and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg)
    end
    gmlfi.editor.panels.settings.DoClick = gmlfi.editor.panels.CreateSettingsPanel

    gmlfi.editor.panels.newtab = vgui.Create("DButton", gmlfi.editor.panels.header)
    gmlfi.editor.panels.newtab:Dock(RIGHT)
    gmlfi.editor.panels.newtab:DockMargin(2, 0, 0, 0)
    gmlfi.editor.panels.newtab:SetText("")
    gmlfi.editor.panels.newtab:SetImage("icon16/add.png")
    gmlfi.editor.panels.newtab:SetTooltip("New tab")
    gmlfi.editor.panels.newtab:SetWidth(24)
    gmlfi.editor.panels.newtab.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsDown() and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg)
    end
    gmlfi.editor.panels.newtab.DoClick = function()
        local tab = AddTab("Tab " .. #gmlfi.editor.panels.tabs + 1)
        SetSelectedTab(tab)
    end
    gmlfi.editor.panels.newtab.DoRightClick = function()
        local dmenu = DermaMenu()
        dmenu:AddOption("Clear tabs", function()
            for k, v in ipairs(gmlfi.editor.panels.tabs) do
                v:Remove() gmlfi.editor.panels.tabs[k] = nil
            end
        end):SetIcon("icon16/cross.png")
        dmenu:Open()
    end

    gmlfi.editor.panels.fopen = vgui.Create("DButton", gmlfi.editor.panels.header)
    gmlfi.editor.panels.fopen:Dock(RIGHT)
    gmlfi.editor.panels.fopen:DockMargin(2, 0, 0, 0)
    gmlfi.editor.panels.fopen:SetText("")
    gmlfi.editor.panels.fopen:SetImage("icon16/page_edit.png")
    gmlfi.editor.panels.fopen:SetTooltip("Open file")
    gmlfi.editor.panels.fopen:SetWidth(24)
    gmlfi.editor.panels.fopen.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsDown() and gmlfi.editor.settings.colors.tabbgactive or gmlfi.editor.settings.colors.tabbg)
    end
    gmlfi.editor.panels.fopen.DoClick = gmlfi.editor.panels.CreateFileSelector
    gmlfi.editor.panels.fopen.DoRightClick = function()
        local dmenu = DermaMenu()
        dmenu:AddOption("Sound Browser", gmlfi.editor.panels.CreateSoundBrowser):SetIcon("icon16/folder_bell.png")
        dmenu:Open()
    end

    gmlfi.editor.UpdateEditorSettings()
    gmlfi.editor.panels.html:QueueJavascript("SetContent('" .. string.JavascriptSafe(gmlfi.editor.code ~= "" and gmlfi.editor.code or gmlfi.editor.codeDefault) .. "'); GotoLine(1);")

    gmlfi.editor.panels.frame.OnClose = function() gmlfi.editor.SaveTabs(true) end
    gmlfi.editor.LoadSettings()

    print("Editor panel created: ", gmlfi.editor.panels.frame)
end

timer.Create("LFI:Editor", 1, 1, function()
    gmlfi.editor.panels.Create(true)
end)

local whathappened = { -- lua switch statement xd
    ["client"] = function(data)
        local bytes = net.ReadUInt(16)
        local data = net.ReadData(bytes)
        if not data then return end
    
        data = util.Decompress(data)
        if not data or data == "" then return end

        RunString(data, "LFI:Editor", false)
    end,

    ["error-lua"] = function()
        local message = net.ReadString()
        surface.PlaySound("friends/message.wav") print(string.format("Lua execution error: %s", message))
    end,
    ["error-datainvalid"] = function()
        surface.PlaySound("friends/message.wav") print("Error: invalid data!")
    end,
    ["error-typeinvalid"] = function()
        surface.PlaySound("friends/message.wav") print("Error: invalid type!")
    end,
    ["error-playerinvalid"] = function()
        surface.PlaySound("friends/message.wav") print("Error: invalid player!")
    end
}
net.Receive("LFI:Editor", function()
    local what = net.ReadString()
    if whathappened[what] then whathappened[what]() end
end)

concommand.Add("gmlfi_editor", function()
    if not gmlfi.editor.panels.frame or not IsValid(gmlfi.editor.panels.frame) then
        gmlfi.editor.panels.Create()
    else gmlfi.editor.panels.frame:Show() gmlfi.editor.panels.frame:MakePopup() gmlfi.editor.SaveTabs(true) end
end)

concommand.Add("gmlfi_editor_cleartabs", function()
    for k, v in ipairs(gmlfi.editor.panels.tabs) do
        v:Remove() gmlfi.editor.panels.tabs[k] = nil
    end
end)

net.Receive("LFI:Editor.Chat", function()
    local str = net.ReadString()
    if net.ReadBool() then
        if net.ReadBool() then chat.AddText(Color(255, 85, 85), "/bin/sh: ", Color(255, 255, 255), str)
        else chat.AddText(Color(255, 255, 255), "```lua\n" .. str .. "\n```") end
    return end

    local ply = net.ReadEntity() local v = IsValid(ply)
    local c, n = v and team.GetColor(ply:Team()) or Color(0, 187, 0), gmlfi.Transliterate(v and string.gsub(ply:Name(), " ", "") or "gmodserver")
    chat.AddText(c, n, Color(0, 187, 0), "@masterserver", Color(255, 255, 255), ":", Color(85, 85, 255), "~", Color(255, 255, 255), "$ ", str)
end)
