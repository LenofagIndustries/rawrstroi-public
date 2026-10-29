local sw, sh = ScrW(), ScrH()
local ww = function(w) return w / 1920 * sw end
local hh = function(h) return h / 1080 * sh end

local CreateFont = surface.CreateFont
local font = function(n, s, w) return CreateFont("LFI:Interface" .. n, {font = "Roboto", size = ww(s), weight = w or 800, antialias = true, extended = true}) end

font("", 32)
font(".Station", 24)
font(".Small", 20)
font(".Medium", 24)
font(".Speed", 36)

local col = {
    no = Color(0, 0, 0, 200),
    tx = Color(255, 255, 255),
    th = Color(200, 200, 200),
    wm = Color(255, 255, 255, 63),
    nm = Color(0, 0, 0, 63),
}

local speed, speedl = 0, 0
local calcSpeed = {
    ["gmod_subway_81-760"] = function(self)
        speed, speedl = self:GetNWBool("80km", false) and 80 or self:GetNWInt("BMCISSpeedAng", 0) / 10, self.BUKP.SpeedLimit or 0
    end,
    ["gmod_subway_81-722_new"] = function(self)
        speed, speedl = self:GetNWInt("MFDUSpeed", 0), self:GetNWInt("MFDUSpeedLimit", -1)
    end,
}

hook.Add("HUDPaint", "LFI:Interface", function()
    local lp = LocalPlayer()
    if not IsValid(lp) or not lp:Alive() then return end

    draw.SimpleTextOutlined(lp:GetNetVar("LFI:Metro.RouteInfo/Station", "") ~= "-" and lp:GetNetVar("LFI:Metro.RouteInfo/Station", "") or "", "LFI:Interface.Station", 13, sh - hh(41), col.tx, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, col.no)
    local rk = lp:GetNetVar("LFI:Metro.RouteInfo/RKPos", false) if rk then draw.SimpleTextOutlined("РК: " .. rk, "LFI:Interface.Speed", 13, sh - hh(83), col.tx, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, col.no) end

    draw.SimpleTextOutlined(os.date("!%H:%M:%S МСК", os.time() + 10800), "LFI:Interface", ww(1791), hh(990), col.tx, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, col.no)
    draw.SimpleTextOutlined("Время игры:", "LFI:Interface.Small", ww(1675), hh(1021), col.tx, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, col.no)
    draw.SimpleTextOutlined("Время сессии:", "LFI:Interface.Small", ww(1675), hh(1044), col.tx, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, col.no)

    local timeu, timen = lp:GetUTimeTotalTime(), lp:GetUTimeSessionTime()
    draw.SimpleTextOutlined(string.format("%01d:%02d:%02d", math.floor(timeu / 3600), math.floor(timeu / 60) % 60, math.floor(timeu) % 60), "LFI:Interface.Small", sw - ww(13), hh(1021), col.tx, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, col.no)
    draw.SimpleTextOutlined(string.format("%01d:%02d:%02d", math.floor(timen / 3600), math.floor(timen / 60) % 60, math.floor(timen) % 60), "LFI:Interface.Small", sw - ww(13), hh(1044), col.tx, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, col.no)
    
    draw.SimpleTextOutlined("gm.lenofag.ru", "LFI:Interface", sw - ww(13), hh(13), col.wm, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, col.nm)
    draw.SimpleTextOutlined("/rawrstroi", "LFI:Interface.Medium", sw - ww(13), hh(44), col.wm, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, col.nm)
end)

local bad = {CHudHealth = true, CHudBattery = true, CHudAmmo = true, CHudSecondaryAmmo = true}
hook.Add("HUDShouldDraw", "LFI.Interface", function(name)
    if bad[name] then return false end
end)

local badtabs = {
    ["#spawnmenu.category.dupes"] = true,
    ["#spawnmenu.category.saves"] = true,
    ["#spawnmenu.category.npcs"] = true,
    ["#spawnmenu.content_tab"] = "v",
}

hook.Add("OnSpawnMenuOpen", "LFI:BadTabs", function()
    for k, v in ipairs(g_SpawnMenu.CreateMenu.Items) do
        if badtabs[v.Name] ~= nil and (isstring(badtabs[v.Name]) and not LocalPlayer():HasAccess(badtabs[v.Name])) then g_SpawnMenu.CreateMenu:CloseTab(v.Tab, true) end
    end
end)

-- VGUI

gmlfi.vgui = gmlfi.vgui or {webmats = {}}

local defmat = Material("error")
gmlfi.vgui.DownloadMaterial = function(name, url)
	gmlfi.vgui.webmats[name] = Material(string.format("data/gmlfi/materials/%s.%s", name, string.GetExtensionFromFilename(url)))
    if not gmlfi.vgui.webmats[name]:IsError() then return print(string.format("%s already downloaded", name)) end
	http.Fetch(url, function(body, _, _, c)
		if c >= 200 and c <= 299 and not string.find(body, "<!DOCTYPE html>") then
			if not gmlfi.file.IsDir("materials") then gmlfi.file.CreateDir("materials") end
			local f = string.format("materials/%s.%s", name, string.GetExtensionFromFilename(url))
			gmlfi.file.Write(f, body)
			gmlfi.vgui.webmats[name] = Material("data/gmlfi/" .. f)
			print(string.format("Saved %s to data/gmlfi/%s", name, f))
		else print(string.format("Error downloading \"%s\": %s", name, c)) print(body) end
	end)
end

gmlfi.vgui.DownloadMaterial("close", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/vrp/close_24dp_FILL1_wght700_GRAD0_opsz24.png")

local gradient = Material("vgui/gradient-l")
local webmats = gmlfi.vgui.webmats

local wh, bl = Color(255, 255, 255), Color(0, 0, 0)
local cr = Color(100, 100, 100)

local cbg, cbd, cbb = Color(30, 30, 30, 250), Color(50, 50, 50, 200), Color(20, 20, 20, 200)
local cbh, cbs = Color(60, 60, 60), Color(75, 75, 75)
local cmn = Color(100, 0, 255)

local sw, sh = ScrW(), ScrH()
local ww = function(w) return w / 1920 * sw end
local hh = function(h) return h / 1080 * sh end

local CreateFont = surface.CreateFont
local font = function(n, s, w, f) return "LFI:VGUI" .. n, CreateFont("LFI:VGUI" .. n, {font = f or "Roboto", size = ww(s), weight = w or 800, antialias = true, extended = true}) end

font(".Title", 32)

font(".Confirm", 20, 800)
font(".Request", 18, 800)
font(".ButtonTitle", 17, 800)
font(".ButtonDesc", 15, 700)

gmlfi.vgui.Font, gmlfi.vgui.ww, gmlfi.vgui.hh = font, ww, hh

local PANEL = {}

function PANEL:Init()
    self:DockPadding(0, 0, 0, 0)
    self:ShowCloseButton(false)
    self:SetKeyboardInputEnabled(false)
    self:SetTitle("")
    self.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, cbg)
        draw.SimpleText(self.NewTitle, "LFI:VGUI.Title", ww(20), hh(20), wh)
    end

    local close = vgui.Create("DButton", self)
    close:SetSize(ww(40), hh(40))
    close:SetText("")
    close.DoClick = function() self:Remove() end
    close.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, cbd)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(webmats.close)
        surface.DrawTexturedRect(ww(9), hh(9), ww(22), hh(22))
    end

    self.CloseButton = close
end

function PANEL:OnSizeChanged(sw, sh)
    self.CloseButton:SetPos(sw - ww(60), hh(20))
end

function PANEL:SetText(t) self.NewTitle = t end

derma.DefineControl("LFI:Frame", "", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
    self:DockPadding(ww(5), hh(5), ww(5), 0)
    self.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, cbd) end

    local vbar = self:GetVBar()
    vbar:SetWidth(1)
    vbar:SetHideButtons(true)
end

derma.DefineControl("LFI:Panel", "", PANEL, "DScrollPanel")

local PANEL = {}

AccessorFunc(PANEL, "TitleText", "TitleText", FORCE_STRING)
AccessorFunc(PANEL, "DescriptionText", "DescriptionText", FORCE_STRING)
AccessorFunc(PANEL, "ButtonColor", "Color", FORCE_COLOR)
AccessorFunc(PANEL, "IsActive", "IsActive", FORCE_BOOL)
AccessorFunc(PANEL, "HoverHighlight", "HoverHighlight", FORCE_BOOL)

function PANEL:Init()
    self.TitleText = ""

    local item = self
    item:DockMargin(ww(5), hh(5), ww(5), 0)
    item:SetHeight(hh(41))
    item:SetText("")

    item.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, self:IsDown() and cbs or (self.IsActive or (self.HoverHighlight and self:IsHovered())) and cbh or cbb)

        local jc = self.ButtonColor
        if jc then
            surface.SetDrawColor(jc.r, jc.g, jc.b, 20)
            surface.SetMaterial(gradient)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        
        draw.SimpleText(self.TitleText, "LFI:VGUI.ButtonTitle", ww(4), self.DescriptionText and hh(13) or h / 2, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if self.DescriptionText then draw.SimpleText(self.DescriptionText, "LFI:VGUI.ButtonDesc", ww(4), hh(30), cr, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
    end
end

derma.DefineControl("LFI:ButtonDesc", "", PANEL, "DButton")

local PANEL = {}

function PANEL:Init()
    self:DockPadding(0, 0, 0, 0)
    self:ShowCloseButton(false)
    self:SetTitle("")
    self.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, cbg)
        for k, v in ipairs(self.NewTitle) do
            draw.SimpleText(v, "LFI:VGUI.Request", w / 2, hh(27) + (k - 1) * hh(18), wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

function PANEL:SetText(t)
    self.NewTitle = string.Wrap("LFI:VGUI.Request", t, self:GetWide() - ww(56))
    if #self.NewTitle > 1 then self:SetTall(self:GetTall() + (#self.NewTitle - 1) * hh(18)) end
end

local requestBase = vgui.RegisterTable(PANEL, "DFrame")
local cbc, cbr = Color(44, 57, 38), Color(57, 42, 42)
local cac, car = Color(cbc.r * 1.5, cbc.g * 1.5, cbc.b * 1.5), Color(cbr.r * 1.5, cbr.g * 1.5, cbr.b * 1.5)

gmlfi.vgui.request = {
    Bool = function(name, cb)
        local self = vgui.CreateFromTable(requestBase)
        self:SetSize(ww(565), hh(117))
        self:MakePopup()
        self:SetText(name)
        self:Center()

        local confirm = vgui.Create("DButton", self)
        confirm:SetPos(ww(28), self:GetTall() - hh(60))
        confirm:SetSize(ww(237), hh(34))
        confirm:SetText("")
        confirm.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and cac or cbc)
            draw.SimpleText("Подтвердить", "LFI:VGUI.Confirm", w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local cancel = vgui.Create("DButton", self)
        cancel:SetPos(ww(300), self:GetTall() - hh(60))
        cancel:SetSize(ww(237), hh(34))
        cancel:SetText("")
        cancel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and car or cbr)
            draw.SimpleText("Отмена", "LFI:VGUI.Confirm", w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        confirm.DoClick = function() if cb then cb(true) end self:Remove() end
        cancel.DoClick = function() if cb then cb(false) end self:Remove() end
    end,
    String = function(name, ph, cb, def, notrim) ph = ph or "Введите текст..."
        local self = vgui.CreateFromTable(requestBase)
        self:SetSize(ww(565), hh(159))
        self:MakePopup()
        self:SetText(name)
        self:Center()

        local tpan = vgui.Create("DPanel", self)
        tpan:SetPos(ww(28), self:GetTall() - hh(102))
        tpan:SetSize(ww(509), hh(34))
        tpan.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, cbd) end

        local text = vgui.Create("DTextEntry", tpan)
        text:Dock(FILL)
        text:DockMargin(ww(5), 0, 0, 0)
        text:SetFont("LFI:VGUI.Request")
        text:SetPlaceholderText(ph)
        text:SetDrawLanguageID(false)
        if def then text:SetValue(def) end
        text.Paint = function(self, w, h)
            if self:GetValue() ~= "" then self:DrawTextEntryText(wh, cmn, cmn)
            elseif self:GetPlaceholderText() and self:GetPlaceholderText() ~= "" then
                local old = self:GetText()
                self:SetText(self:GetPlaceholderText())
                self:DrawTextEntryText(cr, cmn, cmn)
                self:SetText(old)
            end
        end

        local confirm = vgui.Create("DButton", self)
        confirm:SetPos(ww(28), self:GetTall() - hh(60))
        confirm:SetSize(ww(237), hh(34))
        confirm:SetText("")
        confirm.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and cac or cbc)
            draw.SimpleText("Подтвердить", "LFI:VGUI.Confirm", w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local cancel = vgui.Create("DButton", self)
        cancel:SetPos(ww(300), self:GetTall() - hh(60))
        cancel:SetSize(ww(237), hh(34))
        cancel:SetText("")
        cancel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and car or cbr)
            draw.SimpleText("Отмена", "LFI:VGUI.Confirm", w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        cb = cb or function() end
        text.OnEnter = function(_, v) cb(notrim and v or string.Trim(v)) self:Remove() end
        confirm.DoClick = function() cb(notrim and text:GetValue() or string.Trim(text:GetValue())) self:Remove() end
        cancel.DoClick = function() cb(false) self:Remove() end
    end,
    Notify = function(name, cb)
        local self = vgui.CreateFromTable(requestBase)
        self:SetSize(ww(565), hh(117))
        self:MakePopup()
        self:SetText(name)
        self:Center()

        local confirm = vgui.Create("DButton", self)
        confirm:SetPos(ww(28), self:GetTall() - hh(60))
        confirm:SetSize(ww(509), hh(34))
        confirm:SetText("")
        confirm.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and cac or cbc)
            draw.SimpleText("Понятно", "LFI:VGUI.Confirm", w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        confirm.DoClick = function() if cb then cb(true) end self:Remove() end
    end
}

net.Receive("LFI:Request", function()
    -- todo: other types and callbacks
    gmlfi.vgui.request[net.ReadString()](net.ReadString())
end)

hook.Run("LFI:VGUILoaded")

do -- https://github.com/SuperiorServers/dash/blob/master/lua/dash/extensions/client/string.lua
    local surface_SetFont 		= surface.SetFont
    local surface_GetTextSize 	= surface.GetTextSize
    local string_Explode 		= string.Explode

    function string.Wrap(font, text, width)
        surface_SetFont(font)
            
        local sw = surface_GetTextSize(' ')
        local ret = {}
            
        local w = 0
        local s = ''

        local t = string_Explode('\n', text)
        for i = 1, #t do
            local t2 = string_Explode(' ', t[i], false)
            for i2 = 1, #t2 do
                local neww = surface_GetTextSize(t2[i2])
                    
                if (w + neww >= width) then
                    ret[#ret + 1] = s
                    w = neww + sw
                    s = t2[i2] .. ' '
                else
                    s = s .. t2[i2] .. ' '
                    w = w + neww + sw
                end
            end
            ret[#ret + 1] = s
            w = 0
            s = ''
        end
            
        if (s ~= '') then
            ret[#ret + 1] = s
        end

        return ret
    end
end
