gmlfi.score = gmlfi.score or {}

gmlfi.score.settings = {
	server = "/rawrstroi",
	url = "https://gm.lenofag.ru/",
	font = "Roboto",
	size = {w = 846, h = 976},
	colors = {
		main = Color(130, 5, 255),
		back = Color(0, 0, 0, 200),
		gradient = Color(100, 0, 255, 30),
		ply = Color(0, 0, 0, 100),
		card = Color(0, 0, 0, 125),
		but = Color(30, 30, 30, 100),
		buth = Color(50, 50, 50, 100),
		buta = Color(80, 80, 80, 100),
	},
}

local settings = gmlfi.score.settings

local sw, sh = ScrW(), ScrH()
local ww = function(w) return w / 1920 * sw end
local hh = function(h) return h / 1080 * sh end

local CreateFont = surface.CreateFont
local font = function(n, s, w) return CreateFont("LFI:Score" .. n, {font = settings.font, size = ww(s), weight = w or 800, antialias = true, extended = true}) end

font(".Title", 42)
font(".SubTitle", 25)

font(".Time", 36)
font(".Date", 24)

font(".Player", 20)
font(".PlayerSmall", 15)

font(".Card", 17)
font(".CardSmall", 12)

font(".Footer", 21)
font(".SubFooter", 13)

local gradient = Material("vgui/gradient_up")
local thumbsup, thumbsdown = Material("icon16/thumb_up.png"), Material("icon16/thumb_down.png")
local wh, bl = Color(255, 255, 255), Color(0, 0, 0)

local statusicons = {}
local webmats, defmat = {}, Material("error")
local download = function(name, url)
	webmats[name] = Material(string.format("data/gmlfi/materials/%s.%s", name, string.GetExtensionFromFilename(url)))
    if not webmats[name]:IsError() then return print(string.format("%s already downloaded", name)) end
	http.Fetch(url, function(body, _, _, c)
		if c >= 200 and c <= 299 and not string.find(body, "<!DOCTYPE html>") then
			if not gmlfi.file.IsDir("materials") then gmlfi.file.CreateDir("materials") end
			local f = string.format("materials/%s.%s", name, string.GetExtensionFromFilename(url))
			gmlfi.file.Write(f, body)
			webmats[name] = Material("data/gmlfi/" .. f)
			print(string.format("Saved %s to data/gmlfi/%s", name, f))
		else print(string.format("Error downloading \"%s\": %s", name, c)) print(body) end
	end)
end

download("mute", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/scoreboard/mute.png")
download("unmute", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/scoreboard/unmute.png")
download("collapse_all", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/scoreboard/clear_all_48dp_E3E3E3_FILL0_wght700_GRAD200_opsz48.png")

local shouldcount = {
	["props"] = "Пропы",
	["gmod_contr_spawners"] = "Дубликаты",
	["wire_expressions"] = "Expression 2",
	["starfall_processor"] = "Starfall",
}

local countwire = {
	["wire_cpus"] = "CPU",
	["wire_gpus"] = "GPU",
	["wire_spus"] = "SPU",
	["wire_gatess"] = "Gates",
}

local _tcache = {}
local getTrainName = function(name)
	if _tcache[name] then return _tcache[name] end
	local ENT, ENTL = scripted_ents.Get(name), list.Get("SpawnableEntities")[name]
	if not ENT.Spawner and not ENT.SubwayTrain then _tcache[name] = name return name end

	_tcache[name] = string.Replace(ENTL and ENTL.PrintName or ENT.Spawner and ENT.Spawner.Name or string.format("%s (%s)", ENT.SubwayTrain.Name, ENT.SubwayTrain.Manufacturer), " головной", "")
	_tcache[name] = (utf8.len(_tcache[name]) > 15 and "" or "Состав ") .. _tcache[name]
	return _tcache[name]
end

gmlfi.score.Create = function()
	gmlfi.score.Frame = vgui.Create("Panel") if not IsValid(gmlfi.score.Frame) then return print("Failed to create scoreboard panel!!!") end
	local frame = gmlfi.score.Frame

	local plyc = {}
	local c, cm = 0, game.MaxPlayers()

	frame:SetSize(ww(settings.size.w), hh(settings.size.h))
	frame:Center()
	frame:MakePopup()
	frame:SetKeyboardInputEnabled(false)

	local surl = vgui.Create("DButton", frame)
	surl:SetPos(ww(23), hh(15))
	surl:SetSize(ww(221), hh(40))
	surl:SetText("")
	surl.Paint = function() end
	surl.DoClick = function() gui.OpenURL(settings.url .. settings.server:gsub("^/", "")) end

	frame.Paint = function(self, w, h)
		surface.SetDrawColor(settings.colors.gradient.r, settings.colors.gradient.g, settings.colors.gradient.b, settings.colors.gradient.a)
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(0, 0, w, h)

		surface.SetDrawColor(settings.colors.back.r, settings.colors.back.g, settings.colors.back.b, settings.colors.back.a)
		surface.DrawRect(0, 0, w, h)

		draw.SimpleText("gm.lenofag.ru", "LFI:Score.Title", ww(23), hh(15), surl:IsHovered() and settings.colors.main or wh)
		draw.SimpleText(settings.server, "LFI:Score.SubTitle", ww(245), hh(50), wh, TEXT_ALIGN_RIGHT)

		draw.SimpleText(os.date("%H:%M:%S"), "LFI:Score.Time", w - ww(16), hh(14), wh, TEXT_ALIGN_RIGHT)
		draw.SimpleText(os.date("%d.%m.%Y"), "LFI:Score.Date", w - ww(16), hh(50), wh, TEXT_ALIGN_RIGHT)

		surface.SetDrawColor(0, 0, 0)
		surface.DrawLine(ww(19), hh(107), w - ww(16), hh(107))
		surface.DrawLine(ww(19), h - hh(40), w - ww(16), h - hh(40))

		draw.SimpleText(c .. "/" .. cm, "LFI:Score.Footer", ww(19), h - hh(20), wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		draw.SimpleText(gmlfi.FormatTime(CurTime()), "LFI:Score.Footer", w - ww(15), h - hh(27), wh, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Аптайм сервера", "LFI:Score.SubFooter", w - ww(16), h - hh(12), wh, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	local muteall = vgui.Create("DButton", frame)
	muteall:SetPos(ww(802), hh(80))
	muteall:SetSize(ww(22), hh(22))
	muteall:SetText("")
	muteall.DoClick = function()
		gmlfi.score.MuteAll = not gmlfi.score.MuteAll
		for k, v in ipairs(player.GetAll()) do v:SetMuted(gmlfi.score.MuteAll) end
	end
	muteall.Paint = function(self, w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(webmats[gmlfi.score.MuteAll and "unmute" or "mute"])
		surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, 0)
	end

	local toggleall = vgui.Create("DButton", frame)
	toggleall:SetPos(ww(776), hh(80))
	toggleall:SetSize(ww(22), hh(22))
	toggleall:SetText("")
	toggleall.DoClick = function()
		gmlfi.score.ToggleAll = gmlfi.score.ToggleAll == nil or not gmlfi.score.ToggleAll
		for k, v in ipairs(plyc) do if IsValid(v) then v.Collapsed = not gmlfi.score.ToggleAll v:DoClick() end end
	end
	toggleall.Paint = function(self, w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(webmats.collapse_all)
		surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, 0)
	end

	local scroll = vgui.Create("DScrollPanel", frame)
	scroll:SetPos(ww(16), hh(123))
	scroll:SetSize(ww(814), hh(804))
	scroll:GetVBar():SetWidth(0)
	
	local add = function(ply)
		local me = LocalPlayer()
		local isme = me == ply

		local panel = vgui.Create("DButton", scroll)
		panel:Dock(TOP)
		panel:DockMargin(0, 0, 0, hh(6))
		panel:SetHeight(hh(ply.LFISCOREBOARDOPENED and 120 or 30))
		panel:SetZPos(ply:Team()) --  - string.byte(ply:Name()[1]) * .001
		panel:SetText("")

		local name, t = ply:Name(), ply:Team()
		local tm, col = team.GetName(t), team.GetColor(t)
		local long = utf8.len(name) >= 30
		panel.Paint = function(self, w, h)
			surface.SetDrawColor(col.r, col.g, col.b)
			surface.DrawRect(0, 0, ww(3), hh(30))
			
			surface.SetDrawColor(settings.colors.ply.r, settings.colors.ply.g, settings.colors.ply.b, settings.colors.ply.a)
			surface.DrawRect(ww(3), 0, w - ww(3), h)

			draw.SimpleText(name, "LFI:Score.Player" .. (long and "Small" or ""), ww(34), hh(30) / 2, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleTextOutlined(tm, "LFI:Score.Player", w / 2, hh(30) / 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, bl)

			draw.SimpleText(ply:Ping(), "LFI:Score.Player", w - ww(32), hh(30) / 2, wh, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		panel.Collapsed = not ply.LFISCOREBOARDOPENED
		panel.DoClick = function(self)
			self.Collapsed = not self.Collapsed
			self.TargetHeight = self.Collapsed and hh(30) or hh(120)
			ply.LFISCOREBOARDOPENED = not self.Collapsed
		end
		
		panel.Think = function(self)
			if not IsValid(ply) then self:Remove() scroll:InvalidateLayout() c = c - 1 return end
			if self.TargetHeight and (self:GetTall() ~= self.TargetHeight) then -- pasted from sup 0_o
				local tall = self:GetTall()
				local mul = tall > self.TargetHeight and -1 or 1
		
				tall = tall + FrameTime() * (tall - self.TargetHeight * -mul) * 8 * mul
				if (math.abs(tall - self.TargetHeight) < 1) then
					tall = self.TargetHeight
		
					self.TargetHeight = nil
				end
		
				self:SetHeight(tall)
			end
		end

		plyc[#plyc + 1] = panel

		local pfp = vgui.Create("AvatarImage", panel)
		pfp:SetPos(ww(3) + ww(4), hh(4))
		pfp:SetSize(ww(22), hh(22))
		pfp:SetPlayer(ply)
		
		local prf = vgui.Create("DButton", pfp)
		prf:Dock(FILL)
		prf:SetText("")
		prf.DoClick = function() ply:ShowProfile() end
		prf.Paint = function() end

		local status = vgui.Create("DPanel", panel)
		status:SetPos(ww(530), hh(4))
		status:SetSize(ww(215), hh(22))
		status.Paint = function(self, w, h)
			if self.Count and self.Count > 0 then
				surface.SetDrawColor(settings.colors.ply.r, settings.colors.ply.g, settings.colors.ply.b, settings.colors.ply.a)
				surface.DrawRect(0, 0, w, h)
			end
		end
		
		local sk = {}
		local addstatus = function(icon, tip)
			if IsValid(sk[tip]) then sk[tip].Added = CurTime() return end
			if not statusicons[icon] then statusicons[icon] = Material(icon) end

			local panel = vgui.Create("DPanel", status)
			panel.SK = table.Count(sk)
			sk[tip] = panel
			panel:SetPos(ww(215) - (ww(20) * panel.SK), hh(4))
			panel:SetSize(ww(14), hh(14))
			panel:SetTooltip(tip)
			panel.Added = CurTime()
			panel.Paint = function(self, w, h)
				surface.SetMaterial(statusicons[icon])
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect(0, 0, w, h)
			end

			panel.PosUpdate = function(self, i) panel.SK = i self:SetPos(ww(215) - (ww(20) * i), hh(4)) end
		end

		status.Think = function(self)
			if self.NextThink and self.NextThink > CurTime() then return end
			if not IsValid(ply) then return end

			if ply:IsBot() then addstatus("icon16/tux.png", "Бот") end
			if ply:GetNWBool("LSpawnProtect") then addstatus("icon16/shield.png", "SpawnProtect") end
			if ply:GetNWBool("LFI:AAFK") then addstatus("icon16/status_offline.png", "AFK") end
			if ply:IsTyping() then addstatus("icon16/comments.png", "Печатает...") end
			if ply:GetNWBool("LFI:Timeout", false) then addstatus("icon16/transmit_error.png", "Завис...") end
			if ply:GetNW2Bool("ZENMODE", false) then addstatus("icon16/sound_mute.png", "В режиме дзена") end
			if ply:GetNW2Bool("INFECTED", false) then addstatus("icon16/pill_delete.png", "Заражен") end

			local friend = ply:GetFriendStatus()
			if friend == "friend" then addstatus("icon16/user_green.png", "Друг") end
			if friend == "requested" then addstatus("icon16/user_go.png", "Запрос в друзья отправлен") end
			if friend == "blocked" then addstatus("icon16/user_red.png", "Заблокирован вами в Steam") end

            if gmlfi and gmlfi.pstatus then
                local dec = gmlfi.pstatus.Deconstruct(ply:GetNWString("LFI:PStatus"))
                if dec[gmlfi.pstatus.enums.IN_MENU] then addstatus("icon16/application_home.png", "В меню") end
                if dec[gmlfi.pstatus.enums.IN_EDITOR] then addstatus("icon16/page_edit.png", "В Lua Editor") end
                if dec[gmlfi.pstatus.enums.TABBED_OUT] then addstatus("icon16/application_double.png", "Свернул игру") end    
                if dec[gmlfi.pstatus.enums.IN_SCOREBOARD] then addstatus("icon16/eye.png", "Тоже смотрит скорборд") end    
            end

            local train = ply:GetNetVar("LFI:Metro.RouteInfo/Class", false)
            if train and train ~= "" then addstatus("icon16/car.png", "Едет на " .. train) end
			if MDispatcher and MDispatcher.Dispatcher == ply:Name() then addstatus("icon16/user_gray.png", "Диспетчер") end
			local owd = ply:GetNetVar("LFI:Metro.RouteInfo/Operating.Other", false) if owd then addstatus("icon16/car_add.png", "Едет на составе, которым владеет " .. owd) end

			local i = 0
			for k, v in pairs(sk) do i = i + 1 if IsValid(v) and v.Added < CurTime() then v:Remove() sk[k] = nil else v.PosUpdate(v, i) end end
			self.Count = i
			self.NextThink = CurTime() + 1
		end

		local mute = vgui.Create("DButton", panel)
		mute:SetPos(ww(786), hh(4))
		mute:SetSize(ww(22), hh(22))
		mute:SetText("")
		mute.DoClick = function() ply:SetMuted(not ply:IsMuted()) end
		mute.Paint = function(self, w, h)
			if not IsValid(ply) then return end
			surface.SetDrawColor(isme and 100 or 255, isme and 100 or 255, isme and 100 or 255)
			surface.SetMaterial(webmats[(ply:IsMuted() or isme) and "unmute" or "mute"])
			surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, 0)
		end

		local geoip = ply:GetNetVar("GeoIP", {})
		local geostr = geoip.city and string.format("%s, %s", geoip.city or "Неизвестно", geoip.country or "Неизвестно") or geoip.country or "Неизвестно"
		local cnt = "flags16/" .. (geoip.flag or "fam") .. ".png"
		if not statusicons[cnt] then statusicons[cnt] = Material(cnt) end local cntmat = statusicons[cnt] or Material("error")

		local family, familyname, familyid = ply:GetNWString("LFI:FamilySharing", false)
		local sid, sid64 = ply:SteamID(), ply:SteamID64()

		local card = vgui.Create("DPanel", panel)
		card:SetPos(ww(3), hh(30))
		card:SetSize(ww(811), hh(90))
		card.Paint = function(self, w, h)
			if panel.Collapsed and not panel.TargetHeight or not IsValid(ply) then return end -- do not draw when collapsed
			surface.SetDrawColor(settings.colors.card.r, settings.colors.card.g, settings.colors.card.b, settings.colors.card.a)
			surface.DrawRect(0, 0, w, h)

			draw.SimpleText("Время игры:", "LFI:Score.Card", ww(4), hh(4), wh)
			draw.SimpleText("Время сессии:", "LFI:Score.Card", ww(4), hh(22), wh)

			draw.SimpleText(gmlfi.FormatTime(ply:GetUTimeTotalTime()), "LFI:Score.Card", ww(120), hh(4), wh)
			draw.SimpleText(gmlfi.FormatTime(ply:GetUTimeSessionTime()), "LFI:Score.Card", ww(120), hh(22), wh)

			draw.SimpleText("Скопировать SteamID", "LFI:Score.Card", ww(4), hh(40), wh)
			
			surface.SetDrawColor(255, 255, 255)
			surface.DrawLine(ww(4), hh(56), ww(155), hh(56))

			draw.SimpleTextOutlined(sid, "LFI:Score.Card", ww(4), hh(58), settings.colors.main, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, bl)
			draw.SimpleTextOutlined(sid64, "LFI:Score.Card", ww(4), hh(72), settings.colors.main, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, bl)

			surface.SetDrawColor(255, 255, 255)
			surface.DrawLine(ww(161), hh(41), ww(161), h - hh(4))

			draw.SimpleText("Репутация", "LFI:Score.Card", ww(206), hh(40), wh, TEXT_ALIGN_CENTER)
			draw.SimpleText(ply:GetNWInt("LFI:Reputation", 0), "LFI:Score.Card", ww(206), hh(60), wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			surface.SetDrawColor(255, 255, 255)
			surface.DrawLine(ww(250), hh(4), ww(250), h - hh(4))

			if family then
				draw.SimpleText("Аккаунт Family Sharing", "LFI:Score.Card", ww(260), hh(4), wh)
				draw.SimpleText(familyname or "Загрузка...", "LFI:Score.CardSmall", ww(303), hh(20), wh)
				draw.SimpleText(familyid, "LFI:Score.CardSmall", ww(303), hh(32), settings.colors.main)
			else draw.SimpleText("Игрок владеет игрой", "LFI:Score.Card", ww(260), hh(4), wh) end

			surface.SetDrawColor(255, 255, 255)
			surface.DrawLine(ww(260), h - hh(27), ww(460), h - hh(27))

			surface.SetMaterial(cntmat)
			surface.DrawTexturedRect(ww(262), h - hh(19), ww(16), hh(11))

			draw.SimpleText(geostr, "LFI:Score.Card", ww(282), h - hh(22), wh)

			surface.SetDrawColor(255, 255, 255)
			surface.DrawLine(ww(470), hh(4), ww(470), h - hh(4))

            local line = ply:GetNetVar("LFI:Metro.RouteInfo/Line", "")
			draw.SimpleText(line ~= "" and string.format("Едет по %s пути (№ %s)", line, ply:GetNetVar("LFI:Metro.RouteInfo/Route", "??")) or "Стоит на месте", "LFI:Score.Card", ww(480), hh(4))

            local station = ply:GetNetVar("LFI:Metro.RouteInfo/Station", "")
            if station ~= "" then draw.SimpleText(station or "Не на станции", "LFI:Score.Card", ww(480), hh(22)) end

            local train = ply:GetNetVar("LFI:Metro.RouteInfo/Class", "")
            if train ~= "" then
                draw.SimpleText(getTrainName(train), "LFI:Score.Card", ww(480), hh(38))

                local wagons = ply:GetNetVar("LFI:Metro.RouteInfo/Wagons", "0")
                draw.SimpleText("Состоит из " .. wagons .. " вагонов", "LFI:Score.Card", ww(480), hh(54))    
            end

			surface.SetDrawColor(255, 255, 255)
			surface.DrawLine(ww(480), hh(20), ww(620), hh(20))
		end

		if family then
			familyid = util.SteamIDFrom64(family)
			steamworks.RequestPlayerInfo(family, function(name) familyname = name or "[unknown]" end)

			local pfp = vgui.Create("AvatarImage", card)
			pfp:SetPos(ww(260), hh(20))
			pfp:SetSize(ww(40), hh(40))
			pfp:SetSteamID(family, 64)
			
			local prf = vgui.Create("DButton", pfp)
			prf:Dock(FILL)
			prf:SetText("")
			prf.DoClick = function() gui.OpenURL("https://steamcommunity.com/profiles/" .. family) end
			prf.Paint = function() end

			local pst = vgui.Create("DButton", card)
			pst:SetPos(ww(303), hh(32))
			pst:SetSize(ww(110), hh(12))
			pst:SetText("")
			pst.DoClick = function() SetClipboardText(familyid) surface.PlaySound("garrysmod/ui_click.wav") end
			pst.Paint = function() end
		end

		local copyid = vgui.Create("DButton", card)
		copyid:SetPos(ww(4), hh(60))
		copyid:SetSize(ww(150), hh(14))
		copyid:SetText("")
		copyid.Paint = function() end
		copyid.DoClick = function() SetClipboardText(ply:SteamID()) surface.PlaySound("garrysmod/ui_click.wav") end

		local copyid64 = vgui.Create("DButton", card)
		copyid64:SetPos(ww(4), hh(74))
		copyid64:SetSize(ww(150), hh(14))
		copyid64:SetText("")
		copyid64.Paint = function() end
		copyid64.DoClick = function() SetClipboardText(ply:SteamID64()) surface.PlaySound("garrysmod/ui_click.wav") end

		local repup = vgui.Create("DButton", card)
		repup:SetPos(ww(177), hh(62))
		repup:SetSize(ww(12), hh(12))
		repup:SetText("")
		repup.Paint = function(self, w, h)
			surface.SetMaterial(thumbsup)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, w, h)
		end
		repup.DoClick = function()
			if not IsValid(ply) then return end
			net.Start("LFI:Reputation")
			net.WriteEntity(ply)
			net.WriteBool(true)
			net.SendToServer()
		end

		local repdown = vgui.Create("DButton", card)
		repdown:SetPos(ww(224), hh(62))
		repdown:SetSize(ww(12), hh(12))
		repdown:SetText("")
		repdown.Paint = function(self, w, h)
			surface.SetMaterial(thumbsdown)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, w, h)
		end
		repdown.DoClick = function()
			if not IsValid(ply) then return end
			net.Start("LFI:Reputation")
			net.WriteEntity(ply)
			net.WriteBool(false)
			net.SendToServer()
		end

		if LFAdmin then
			local ascroll = vgui.Create("DScrollPanel", card)
			ascroll:SetPos(ww(666), hh(5))
			ascroll:SetSize(ww(140), hh(82))
			ascroll:GetVBar():SetHideButtons(true)
			ascroll:GetVBar():SetWide(1)

			local si = 0
			local addAction = function(name, func, funcr)
				local cmd = LFAdmin.Commands[func]
				if not cmd then return end
				if not (LFAdmin.CanAccess(me, func) and (cmd.SkipAccessCheck or me:CanTarget(ply))) then return end --??????????????????????????? -- не стоило тебе мою сборку давать
				si = si + 1
				local but = vgui.Create("DButton", ascroll)
				but:SetPos(0, hh(20) * si - hh(15))--ww(666), hh(20) * si - hh(15))
				but:SetSize(ww(140), hh(19))
				but:SetText("")
				but.Paint = function(self, w, h)
					draw.RoundedBox(0, 0, 0, w, h, self:IsDown() and settings.colors.buta or self:IsHovered() and settings.colors.buth or settings.colors.but)
					draw.SimpleText(name, "LFI:Score.Card", w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				but.DoClick = function()
					if not IsValid(ply) then return end
					if isfunction(funcr) then funcr()
					else RunConsoleCommand("lf", func, ply:SteamID(), funcr) end
				end
			end
			
			addAction("Телепортироваться", "goto")
			addAction("Телепортировать", "teleport")
			addAction("Скриншот", "screenshot")
			addAction("Следить", "spectate")
			addAction("Заджайлить", "jailtp")
			addAction("Замутить", "mute", "0")
			addAction("Гагнуть", "gag", "0")
			addAction("Зафризить", "freeze")
			addAction("Написать", "pm", function()
				gmlfi.vgui.request.String("Введите текст сообщения", "Давай мясо !!!", function(t)
					if not IsValid(ply) then return chat.AddText(wh, "Игрок уже вышел") end
					if not t then return end
					RunConsoleCommand("lf", "pm", ply:SteamID(), t)
				end)
			end)
			addAction("Быстрый кик", "kick", function()
				gmlfi.vgui.request.String("Введите причину кика", "Убивает бес причины!!!!!!!!", function(t)
					if not IsValid(ply) then return chat.AddText(wh, "Игрок уже вышел") end
					if not t then return end
					RunConsoleCommand("lf", "kick", ply:SteamID(), t)
				end)
			end)
		end
	end

	local uc = 0
	for k, v in ipairs(player.GetAll()) do if not v:GetNWBool("LFI:Hide", false) then add(v) else uc = uc + 1 end end
	c = gmlfi.nw.Get("player.GetCountTotal", player.GetCount()) - uc
end

local gesc = gui.EnableScreenClicker -- big optimizon solutions
hook.Add("ScoreboardShow", "LFI:Score", function()
	if not IsValid(gmlfi.score.Frame) then gmlfi.score.Create() end
	gesc(true)

	return true
end)

hook.Add("ScoreboardHide", "LFI:Score", function()
	gesc(false)
	if IsValid(gmlfi.score.Frame) then gmlfi.score.Frame:Remove() end
end)