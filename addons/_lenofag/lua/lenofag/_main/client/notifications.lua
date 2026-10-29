notification = {}

-- remade for vastrp by me lenofag 2000 so idgaf
surface.CreateFont("LFI:Notify", {
	font = "Roboto",
	extended = true,
	antialias = true,
	size = 21,
	weight = 400
})

local wh = Color(255, 255, 255)
local color_background = Color(30, 30, 30, 230)

local notifyTypes = {
	[NOTIFY_GENERIC] = Color(100, 150, 255),
	[NOTIFY_HINT] = Color(255, 200, 100),
	[NOTIFY_ERROR] = Color(255, 100, 100),
	[NOTIFY_UNDO] = Color(255, 140, 0),
	[NOTIFY_SUCCESS] = Color(150, 255, 100),
}

local Notices = {}

function notification.AddProgress(uid, text) end

function notification.Kill(uid)
	if IsValid(Notices[uid]) then
		Notices[uid].StartTime = SysTime()
		Notices[uid].Length = 0.8
	end
end

function notification.AddLegacy(text, type, length)
	type = math.Clamp(type or 0, 0, 5)
	text = tostring(text):Trim()

	if (text:sub(1,1) == "#") then
		text = language.GetPhrase(text)
	end

	local parent
	if GetOverlayPanel then
		parent = GetOverlayPanel()
	end

    local self = vgui.Create("NoticePanel", parent)
    self.NotifyType 	= type
    self.StartTime 	= SysTime()
    self.Length 		= length
    self.VelX			= 0
    self.VelY			= 0
    self.fx 			= ScrW() + 200
    self.fy 			= ScrH()
    self:SetText(text)
    self:SetPos(self.fx, self.fy)
    self:SetMouseInputEnabled(false)
	table.insert(Notices, self)

	MsgC(notifyTypes[type], "Уведомление", wh, ": ", text .. "\n")
end

-- This is ugly because it"s ripped straight from the old notice system

local function UpdateNotice(number, panel, count)
	local x = panel.fx
	local y = panel.fy

	local w = panel:GetWide() + 16
	local h = panel:GetTall() + 16

	local ideal_y = ScrH() - (count - number) * (h - 12) - 150
	local ideal_x = ScrW() - w - 16

	local timeleft = panel.StartTime - (SysTime() - panel.Length)
	if (timeleft < 0.2) then
		ideal_x = ideal_x + w * 2
	end

	local spd = FrameTime() * 15
	y = y + panel.VelY * spd
	x = x + panel.VelX * spd

	do
		local dist = ideal_y - y
		panel.VelY = panel.VelY + dist * spd * 1
		if (math.abs(dist) < 2 && math.abs(panel.VelY) < 0.1) then
			panel.VelY = 0
		end
	end

	do
		local dist = ideal_x - x
		panel.VelX = panel.VelX + dist * spd * 1
		if (math.abs(dist) < 2 && math.abs(panel.VelX) < 0.1) then
			panel.VelX = 0
		end
	end

	panel.VelX = panel.VelX * (0.9 - FrameTime() * 8)
	panel.VelY = panel.VelY * (0.9 - FrameTime() * 8)

	panel.fx = x
	panel.fy = y
	panel:SetPos(panel.fx, panel.fy)

end

hook.Add("Think", "NotificationThink", function()
	for k, v in ipairs(Notices) do
		UpdateNotice(k, v, #Notices)
		if IsValid(v) and v:KillSelf() then
			table.remove(Notices, k)
		end
	end
end)

local webmats = gmlfi.vgui.webmats
gmlfi.vgui.DownloadMaterial("notify_background", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/notifications/image_2025-09-19_18-00-24.png")
gmlfi.vgui.DownloadMaterial("notify_success", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/notifications/notify_success.png")
gmlfi.vgui.DownloadMaterial("notify_error", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/notifications/notify_error.png")
gmlfi.vgui.DownloadMaterial("notify_generic", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/notifications/notify_generic.png")
gmlfi.vgui.DownloadMaterial("notify_hint", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/notifications/notify_hint.png")

local NOTIFY_ICONS = {
	[NOTIFY_GENERIC] = "notify_generic",
	[NOTIFY_HINT] = "notify_hint",
	[NOTIFY_SUCCESS] = "notify_success",
	[NOTIFY_ERROR] = "notify_error",
}

local PANEL = {}

function PANEL:Init()
	self.NotifyType = NOTIFY_GENERIC

	self.Label = vgui.Create("DLabel", self)
	self.Label:SetFont("LFI:Notify")
	self.Label:SetTextColor(wh)
	self.Label:SetPos(13, 4)
	self.Label:SetContentAlignment(4)
end

function PANEL:SetText(txt)
	self.Label:SetText(txt)
	self:SizeToContents()
end

function PANEL:SizeToContents()
	local nt = self.NotifyType
	nt = nt and NOTIFY_ICONS[nt]
	if nt then
		self.Label:SetX(38)
	end

	self.Label:SizeToContents()
	self:SetWidth(self.Label:GetWide() + (nt and 48 or 26))
	self:SetHeight(30)
	self:InvalidateLayout()
end

function PANEL:KillSelf()
	if (self.StartTime + self.Length < SysTime()) then
		self:Remove()
		return true
	end
	return false
end

local color_load = Color(75, 75, 75)
local color_load_a = Color(255, 255, 255, 25)
local colors_load = {}
for k, v in pairs(notifyTypes) do
    colors_load[k] = Color(v.r, v.g, v.b, 25)
end

function PANEL:Paint(w, h)
	if (hook.Call("HUDShouldDraw", GAMEMODE, "Notifications") == false) then
		return
	end

	draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(color_background, 220))

	local nt = self.NotifyType
	if nt then
		if nt ~= NOTIFY_UNDO and notifyTypes[nt] then
			surface.SetMaterial(webmats.notify_background)
			surface.SetDrawColor(notifyTypes[nt])
			surface.DrawTexturedRect(0, 0, 120, h)

			local left = (self.Length / (self.StartTime - (SysTime() - self.Length)))
			draw.RoundedBox(8, 39, h - 2, w - 48, 2, colors_load[nt] or color_load_a)
			draw.RoundedBox(8, w - (w / left - 15), h - 2, w / left - 23, 2, color_load)
		end

		if NOTIFY_ICONS[nt] then
			surface.SetMaterial(webmats[NOTIFY_ICONS[nt]])
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(4, 4, 22, 22)
		end
	end 
end

vgui.Register("NoticePanel", PANEL, "DPanel")

concommand.Add("ntest", function()
	for i = 0, 5 do
		timer.Simple(math.random() * i, function()
			notification.AddLegacy(gmlfi.RandomName() .. " стал " .. table.Random(team.GetAllTeams()).Name, i, math.random(5, 10))
		end)
	end
end)

if IsValid(vgui.GetWorldPanel()) then -- delete existing notifications
	for k, v in ipairs(vgui.GetWorldPanel():GetChildren()) do
		if v.NotifyType then v:Remove() end
	end
end