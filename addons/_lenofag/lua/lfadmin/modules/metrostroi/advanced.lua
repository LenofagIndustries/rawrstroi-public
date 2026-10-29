-- metrostroi_advanced/lua/ulx/modules/sh/metrostroi_advanced.lua
-- rewriten to lfadmin
-- blah blah developers alexell agent smith wow real agent smith from matrix wtf how did that happen why did he write a stupid amount of stupid huge math calculations tho

if SERVER then util.AddNetworkString("metrostroi_stations_gui") end

local function lang(str)
	return MetrostroiAdvanced.Lang[str]
end

-- телепортация в состав
local function GotoTrain (ply,tply,train,sit)
	print(ply, tply, train, sit)
	if not IsValid(train) then return end
    if IsValid(ply:GetVehicle()) then
        ply:ExitVehicle()
    end
    local pos = train:GetPos()
    ply:SetMoveType(8)
    if sit == true then
        ply:Freeze(true)
        ply:SetPos(pos-Vector(0,0,40))
		if ply == tply then
			train.DriverSeat:UseClientSideAnimation() -- пусть ебучую анимацию отрабатывает клиент
			timer.Simple(1, function()
				train.DriverSeat:Use(ply,ply,3,1)
				LFAdmin.LogPlayer(true, ply, " "..lang("Teleported")..lang("Teleported1"))
				ply:Freeze(false)
			end)
		else
			train.InstructorsSeat:UseClientSideAnimation()
			timer.Simple(1, function()
				train.InstructorsSeat:Use(ply,ply,3,1)
				LFAdmin.LogPlayer(true, ply, " "..lang("Teleported")..lang("Teleported2").." " ,tply)
				ply:Freeze(false)
			end)
		end
    else
		if ply == tply then
			ply:SetPos(pos-Vector(0,0,40))
			LFAdmin.LogPlayer(true, ply, " "..lang("Teleported")..lang("Teleported3"))
		else
			ply:SetPos(pos-Vector(0,0,40))
			LFAdmin.LogPlayer(true, ply, " "..lang("Teleported")..lang("Teleported4").." ",tply)
		end
    end
end

------------------------------------------------------
--		***	METROSTROI TRAIN START SCRIPT ***		--
--				Made by Agent Smith					--
--		https://steamcommunity.com/id/ag-sm1th/		--
------------------------------------------------------

local function Set(button,state,train)
	if not IsValid(train) then return end
	if train[button] then
		train[button]:TriggerInput("Set",state)
	end
end

local function TrainStart(train)
	if not IsValid(train) then return end
	-- Проход по составам - самая большая группа - Номерной и древнее
	if train:GetClass() and (train:GetClass():sub(13,18) ~= "81-718" and train:GetClass():sub(13,18) ~= "81-720" and train:GetClass():sub(13,18) ~= "81-722") then
		if train.KVWrenchMode ~= 1  or train.KVWrenchMode == 1 then
			train:PlayOnce("revers_in","cabin", 0.7)
			train.KVWrenchMode = 1
			train.KV:TriggerInput("Enabled", 1)
		end
		if train.KVWrenchMode == 1  then
			train.KV:TriggerInput("ReverserSet", 1)
		end 
		if train.Pneumatic.DriverValvePosition ~= 2 then
			train.Pneumatic:TriggerInput("BrakeSet", 2)
		end
		Set("ALS",0, train)
		Set("ARS", 0, train)	
		Set("EPK", 0, train)
		Set("EPV", 0, train)
		timer.Simple(0.5, function()	
			Set("A53", 1, train)
			Set("A49", 1, train)
			Set("A63", 1, train)
			Set("VB", 1, train)
			--Set("BPSNon", 1, train)
			Set("VMK", 1, train)
			Set("V1", 1, train)
			Set("KU1", 1, train)	-- МК для Еж
			Set("VUS", 1, train)	
		end)
		timer.Simple(1, function()	
			Set("VUD1", 1, train)
			Set("V2", 1, train)
			Set("L_1", 1, train)
			Set("L_3", 1, train)
			Set("L_4", 1, train)
			Set("R_UNch", 1, train)
			Set("R_ZS", 1, train)
			Set("R_G", 1, train)
			Set("R_Radio", 1, train)
			Set("PLights", 1, train) -- для Еж3
			Set("GLights", 1, train) -- для Еж3
			Set("VU14", 1, train)	-- для Еж3
			Set("KU16", 1, train)	-- Фары для Еж
			Set("KU2", 1, train)	-- двери для Еж
		end)
		if train.ALS_ARS then 	-- условие на наличие АРС
			timer.Simple(1.5, function() -- таймер на AРC
				Set("ALS", 1, train)
				Set("ARS", 1, train)
				Set("EPK", 1, train)
				Set("EPV", 1, train)			
			end)
			timer.Simple(2.5, function() -- таймер на разобщительный кран (013)
				Set("DriverValveDisconnect", 1, train)
			end)
			timer.Simple(2, function() -- таймер на краны двойной тяги (334)
				Set("DriverValveBLDisconnect", 1, train)
				Set("DriverValveTLDisconnect", 1, train)
			end)
			timer.Create("KBPressed", 4, 2, function() -- таймер на отмену КВТ (Ема)
				Set("KB", 1, train)
			end)
			timer.Create("KBReleased", 5, 2, function() -- таймер на отмену КВТ (Ема)
				Set("KB", 0, train)
			end)
			timer.Create("KVTPressed", 4, 2, function() -- таймер на отмену КВТ
				Set("KVT", 1, train)		
			end)	
			timer.Create("KVTReleased", 5, 2, function() -- таймер на отмену КВТ
				Set("KVT", 0, train)		
			end)
		else
			timer.Simple(2, function() -- таймер на разобщительный кран (013)
				Set("DriverValveDisconnect", 1, train)
			end)
			timer.Simple(2, function() -- таймер на краны двойной тяги (334)
				Set("DriverValveBLDisconnect", 1, train)
				Set("DriverValveTLDisconnect", 1, train)
			end)	
		end
	-- ТИСУ
	elseif train:GetClass():sub(13,18) == "81-718" then
		if train.WrenchMode ~= 1 or train.WrenchMode == 1 then
			train:PlayOnce("kr_in", "cabin",1)
			train.WrenchMode = 1
		end
		if train.WrenchMode == 1 then
			train.KR:TriggerInput("Set", train.KR.Position + 1)
		end
		if train.Pneumatic.DriverValvePosition ~= 2 then
			train.Pneumatic:TriggerInput("BrakeSet", 2)
		end
		Set("SA15", 0, train)
		Set("SA13", 0, train)
		Set("EPK", 0, train)	
		Set("SA16", 1, train)
		Set("SAP39", 1, train)		
		timer.Simple(0.5, function() -- таймер на тумблера
			Set("SA2/1", 1, train)
			Set("SA4/1", 1, train)				
			Set("SA5", 1, train)
		end)
		timer.Simple(1, function() -- таймер на AРC
			Set("SA15", 1, train)
			Set("SA13", 1, train)
			Set("EPK", 1, train)
		end)
		timer.Simple(1.5, function() -- таймер на разобщительный кран (013)
			Set("DriverValveDisconnect", 1, train)
		end)
		timer.Simple(2, function() -- таймер на отмену КВТ
			Set("SB9", 1, train)		
		end)	
		timer.Simple(3, function() -- таймер на отмену КВТ
			Set("SB9", 0, train)		
		end)
	-- Яуза	
	elseif train:GetClass():sub(13,18) == "81-720" then 	-- не проверено!
		if train.WrenchMode ~= 1 or train.WrenchMode == 1 then
			train:PlayOnce("kro_in", "cabin",1)
			train.WrenchMode = 1
			timer.Simple(0.25, function() -- таймер на переключение реверса
				train.RV:TriggerInput("KROSet", train.RV.KROPosition + 1)
			end)
		end	
		timer.Simple(0.5, function() -- таймер на тумблера сзади
			Set("Headlights1", 1, train) -- Фары для Яузы
			Set("Headlights2", 1, train) -- Фары для Яузы
			Set("CabLightStrength", 1, train) -- Фары для Яузы				
		end)
		timer.Simple(1, function() -- таймер на переход в штатный режим
			if train["BUKP"].State ~= 5 then
				train["BUKP"].State = 5
			end
		end)
		timer.Simple(1.5, function() -- таймер на кнопки спереди
			Set("DoorClose", 1, train) 
			Set("DoorSelectL", 1, train) 
			Set("DoorSelectR", 0, train) 
		end)
		timer.Create("AttentionPressed1", 3, 2, function() -- таймер на отмену (Яуза)
			Set("AttentionMessage", 1, train)
			Set("AttentionBrake", 1, train)
		end)
		timer.Create("AttentionReleased1", 3.25, 2, function() -- таймер на отмену (Яуза)
			Set("AttentionMessage", 0, train)
			Set("AttentionBrake", 0, train)
		end)
	else
	-- Юбилейный (без комментариев)
		if train:GetClass():sub(13,18) == "81-722" then 	
			Set("ALS", 0, train)
			Set("ARS", 0, train)
			if train.MFDU.State ~= 1 then train.MFDU.State = 1 end
			timer.Simple(0.5, function() 
				train.BUKP.Active = 1
				train:SetPackedBool("MFDUActive", true)	
				Set("PassVent", 2, train)					
			end)
			timer.Simple(1, function() 
				Set("ALS", 1, train)
				Set("ARS", 1, train)			
			end)
			timer.Simple(1.5, function() 
				Set("Vigilance", 1, train)		
			end)	
			timer.Simple(2, function() 
				Set("Vigilance", 0, train)		
				Set("Headlights", 2, train)
				Set("DoorClose", 2, train)
			end)
			timer.Simple(2.5, function() 
				train.KRO:TriggerInput("Set", 2) 
			end)
		end
	end
end

local function TrainStop(train)
	-- Проход по составам - самая большая группа - Номерной и древнее
	if train:GetClass() and (train:GetClass():sub(13,18) ~= "81-718" and train:GetClass():sub(13,18) ~= "81-720" and train:GetClass():sub(13,18) ~= "81-722") then
		if train.Pneumatic.DriverValvePosition ~= 5 then
			train.Pneumatic:TriggerInput("BrakeSet", 5)
		end
		timer.Simple(0.5, function ()
			Set("R_UNch", 0, train)
			Set("R_ZS", 0, train)
			Set("R_G", 0, train)
			Set("V1", 0, train)
		end)
		timer.Simple(1, function ()
			Set("KU1", 0, train)	-- МК для Еж
			Set("KU2", 0, train)
			Set("PLights", 0, train) -- свет в кабине для Еж3
			Set("VMK", 0, train)
		end)		
		timer.Simple(1.5, function ()
			Set("DriverValveDisconnect", 0, train)
			Set("DriverValveBLDisconnect", 0, train)
			Set("DriverValveTLDisconnect", 0, train)
		end)		
		timer.Simple(2, function() -- таймер на полное служебное торможение	
			Set("ALS", 0, train)
			Set("ARS", 0, train)	
			timer.Simple(1, function()			
				Set("VUD1", 0, train)	
				Set("V2", 0, train)			
				train.Pneumatic:TriggerInput("BrakeSet", 2)	
				end)
		end)
		if train.KVWrenchMode == 1  then
			train.KV:TriggerInput("ControllerSet", 0)				
		end 
		if train.KVWrenchMode ~= 0  then
			timer.Simple(2.5, function() -- таймер на откл реверса
				train.KV:TriggerInput("ReverserSet", 0)
				timer.Simple(0.5, function()
					train.KV:TriggerInput("Enabled", 0)
					train.KVWrenchMode = 0
				end)
			end)					
		end	
	-- ТИСУ
	elseif train:GetClass() and train:GetClass():sub(13,18) == "81-718" then
		if train.Pneumatic.DriverValvePosition ~= 6 then
			train.Pneumatic:TriggerInput("BrakeSet", 5)
		end
		timer.Simple(3, function() -- таймер на полное служебное торможение ТИСУ
			Set("DriverValveDisconnect", 0, train)
		end)
		timer.Simple(4, function()
			Set("SAP39", 0, train)
			Set("SA5", 0, train)
			Set("SA16", 0, train)
		end)						
		if train.WrenchMode ~= 0 then
			timer.Simple(5, function() -- таймер на откл реверса. ТИСУ
				train.KR:TriggerInput("Set", train.KR.Position - 1)
				Set("SA15", 0, train)
				Set("SA13", 0, train)
				timer.Simple(1, function() -- таймер на откл реверса. ТИСУ
					train.WrenchMode = 0
					train.Pneumatic:TriggerInput("BrakeSet", 2)
				end)
			end)			
		end		
	-- Яуза
	elseif train:GetClass() and train:GetClass():sub(13,18) == "81-720" then
		if train.WrenchMode ~= 0 then
			train.RV:TriggerInput("KROSet", train.RV.KROPosition - 1)
			timer.Simple(0.5, function() -- таймер на откл реверса. Яуза
				Set("DoorClose", 0, train) 
				Set("DoorSelectL", 0, train) 
				Set("DoorSelectR", 0, train) 
			end)			
			timer.Simple(1, function() -- таймер на откл реверса. Яуза
				train.WrenchMode = 0
			end)
			timer.Simple(1.5, function() -- таймер на откл кнопок
				Set("DoorClose", 0, train) 
				Set("DoorSelectL", 0, train) 
				Set("DoorSelectR", 0, train) 
			end)
		end	
	else 
	-- Юбилейный (без комментариев)
		if train:GetClass():sub(13,18) == "81-722" then 	
			timer.Simple(0.5, function() 
				train.KRO:TriggerInput("Set", 1) 
			end)
			timer.Simple(1, function() 
				Set("ALS", 0, train)
				Set("ARS", 0, train)			
			end)
			timer.Simple(1.5, function() 
				train.BUKP.Active = 0
				train:SetPackedBool("MFDUActive", false)	
				Set("DoorClose", 1, train)				
			end)
		end
	end
end

------------------------------------------------------
--			***	TRAIN START SCRIPT END	***			--
------------------------------------------------------

-- Смена кабины
local function ChangeCab (ply,train1,train2)
    local tim = 3
	local tim2 = tim + 1.5
	local tim3 = tim2 + 1.5
	if ply:GetNW2String("LFI:Metro.RouteInfo/Class","") == "gmod_subway_81-720" then tim = 1  tim2 = tim + 1 tim3 = tim2 + 1 end
	if ply:GetNW2String("LFI:Metro.RouteInfo/Class","") == "gmod_subway_81-722" then tim = 1  tim2 = tim + 1 tim3 = tim2 + 1 end
	TrainStop(train1)	
	timer.Simple(tim, function()
		ply:ExitVehicle()
		ply:SetMoveType(8)
	end)
	timer.Simple(tim2, function()
		train2.DriverSeat:UseClientSideAnimation() -- пусть ебучую анимацию отрабатывает клиент	
		train2.DriverSeat:Use(ply,ply,3,1)
	end)
	timer.Simple(tim3, function()
		TrainStart(train2)
	end)	
end

LFAdmin.Command("stations", "u", {}, function(activator)
    net.Start("metrostroi_stations_gui")
    net.Send(activator)
end)

LFAdmin.Command("station", "u", {"string?"}, function(calling_ply, station)
	if calling_ply:IsPlayerFrozen() then return end
    if not station then
        net.Start("metrostroi_stations_gui")
        net.Send(calling_ply)
    return end

    station = string.PatternSafe(station:lower())

    --Обработка сообщений вида станция:номер для станций, которые имеют несколько позиций
    local add = 0
    if station:find("[^:]+:%d+$") then
        local st,en = station:find(":%d+$")
        add = tonumber(station:sub(st+1,en))
        station = station:sub(1,st-1)
    end

    --Проверка на наличие таблицы
    if not Metrostroi.StationConfigurations then LFAdmin.LogPlayer( calling_ply, lang("MapNotCongigured"), true ) return end

    --Создание массива найденых станций по индкесу станции или куска имени
    local st = {}
    for k,v in pairs(Metrostroi.StationConfigurations) do
        if not v.positions then continue end
        if v.names then
            for _,stat in pairs(v.names) do
                if stat:lower():find(station) then
                    table.insert(st,k)
                    break
                end
            end
        end
        if tostring(k):find(station) then
            table.insert(st,k)
        end
    end

    if #st == 0 then
        LFAdmin.LogPlayer( calling_ply, Format(lang("StationNotFound").." %s",station), true )
        return
    elseif #st > 1 then
        LFAdmin.LogPlayer( calling_ply,  Format(lang("ManyStations").." %s:",station), true )
        for k,v in pairs(st) do
            local tbl = Metrostroi.StationConfigurations[v]
            if tbl.names and tbl.names[1] then
                LFAdmin.LogPlayer( calling_ply, Format("\t%s=%s",v,tbl.names[1]), true )
            else
                LFAdmin.LogPlayer( calling_ply, Format("\t%s",k), true )
            end
        end
        LFAdmin.LogPlayer( calling_ply, lang("StationIncorrect"), true )
        return
    end
    local key = st[1]
    st = Metrostroi.StationConfigurations[key]
    local ptbl
    if add > 0 then
        local pos = st.positions
        ptbl = pos[math.min(#pos,add+1)]
    else
        ptbl = st.positions and st.positions[1]
    end
    if IsValid(calling_ply) then
        if ptbl and ptbl[1] then
            if calling_ply:InVehicle() then calling_ply:ExitVehicle() end
            calling_ply.LFADMINPREV = calling_ply:GetPos()
            calling_ply:SetPos(ptbl[1])
            calling_ply:SetAngles(ptbl[2] or Angle(0,0,0))
            calling_ply:SetEyeAngles(ptbl[2] or Angle(0,0,0))
            LFAdmin.LogPlayer(true, calling_ply, " "..lang("Teleported")..lang("Teleported5").." ", "#" .. (st.names and st.names[1] or key))
        else
            LFAdmin.LogPlayer( calling_ply, lang("StationConfigError")..key, true )
        end

    else
        if ptbl and ptbl[1] then
            print(Format("DEBUG1:Teleported to %s(%s) pos:%s ang:%s",st.names and st.names[1] or key,key,ptbl[1],ptbl[2]))
        else
            LFAdmin.LogPlayer( calling_ply, lang("StationConfigError"), "#" .. station:gsub("^%l", string.upper))
        end
    end
end)

-- Замена !trains
local wagonswaittime = 10
local wagonslasttime = -wagonswaittime
LFAdmin.Command("trains", "u", {}, function(calling_ply)
    if wagonslasttime + wagonswaittime > CurTime() then
        LFAdmin.LogPlayer( calling_ply, lang("PleaseWait").." "..math.Round(wagonslasttime + wagonswaittime - CurTime()).." "..lang("Seconds")..lang("CommandDelay"), true )
        return
    end
    wagonslasttime = CurTime()
    LFAdmin.LogPlayer(calling_ply, lang("ServerWagons").." ", Metrostroi.TrainCount())
	local Wags = {}
	local Trains = {}
	local Routes = {}
	local Locs = {}
	local wag_num = 0
	local wag_str = lang("wagon1")
	
	for train in pairs(Metrostroi.SpawnedTrains) do
		if not IsValid(train) then continue end
		if not MetrostroiAdvanced.TrainList[train:GetClass()] then continue end
		local cl = train:GetClass()
		local ply = train.Owner
		if not IsValid(ply) then continue end
		if Trains[ply:Nick()] then continue end
		Trains[ply:Nick()] = MetrostroiAdvanced.TrainList[cl]
		Wags[ply:Nick()] = #train.WagonList
		local rnum = 0
		if cl == "gmod_subway_81-540_2" then
			rnum = tonumber(train.RouteNumbera.RouteNumbera)
		elseif cl == "gmod_subway_81-722" or cl == "gmod_subway_81-722_3" or cl == "gmod_subway_81-722_new" or cl == "gmod_subway_81-7175p" then
			rnum = tonumber(train.RouteNumberSys.RouteNumber)
		elseif cl == "gmod_subway_81-717_6" or cl == "gmod_subway_81-740_4" then
			rnum = train.ASNP.RouteNumber
		else
			if train.RouteNumber then
				rnum = tonumber(train.RouteNumber.RouteNumber)
			end
		end
		if table.HasValue({"gmod_subway_em508","gmod_subway_81-702","gmod_subway_81-703","gmod_subway_81-705_old","gmod_subway_ezh","gmod_subway_ezh3","gmod_subway_ezh3ru1","gmod_subway_81-717_mvm","gmod_subway_81-718","gmod_subway_81-720","gmod_subway_81-720_1","gmod_subway_81-720a","gmod_subway_81-717_freight","gmod_subway_81-717_5a"},cl) then
			rnum = rnum / 10
		end
		Routes[ply:Nick()] = tostring(rnum)
		Locs[ply:Nick()] = MetrostroiAdvanced.GetLocation(train)
	end
	
	for k,v in pairs(Trains) do
		wag_num = tonumber(Wags[k])
		if wag_num >= 2 and wag_num <= 4 then wag_str = lang("wagon2") end
		if wag_num >= 5 then wag_str = lang("wagon3") end
		LFAdmin.LogPlayer(calling_ply, "#" .. k, ":\n\t", "#" .. wag_num, " ", wag_str.." ", "#" .. Trains[k], " \n\t"..lang("Route")..": ", "#" .. Routes[k], "\n\t"..lang("Location")..": ", "#" .. Locs[k])
	end
	local wag_awail = (GetConVar("metrostroi_maxtrains"):GetInt()*GetConVar("metrostroi_advanced_maxwagons"):GetInt())-GetGlobalInt("metrostroi_train_count")
    LFAdmin.LogPlayer(calling_ply, lang("WagonsAwail").." ", wag_awail)
end)

LFAdmin.Command("expass", "u", {}, nil, function()
    RunConsoleCommand("metrostroi_expel_passengers")
end)

LFAdmin.Command("binds", "u", {}, nil, function()
    RunConsoleCommand("metrostroi_expel_passengers")
end)

LFAdmin.Command("traintp", "u", {"player?"}, function(calling_ply, target_ply)
	if calling_ply:IsPlayerFrozen() then return end
    if not IsValid(target_ply) then target_ply = calling_ply end
	local class = target_ply:GetNetVar("LFI:Metro.RouteInfo/Class", "") --IT WAS GETNW2STRING NOT GETNETVAR D:
	if class == "" then return end
	local teleported = false
	local ents = ents.FindByClass(class)
	for k,v in pairs(ents) do
		if v.Owner == target_ply then
			
			if class:sub(13,18) == "81-760" or class:sub(13,19) == "81-760a" then
				if v.RV.KROPosition ~= 0 then
					GotoTrain(calling_ply,target_ply,v,true)
					teleported = true
				end
			elseif class:sub(13,18) == "81-722" then
				if v.Electric.CabActive ~= 0 then
					GotoTrain(calling_ply,target_ply,v,true) 
					teleported = true
				end
			elseif class:sub(13,18) == "81-720" then
				if v.WrenchMode ~= 0 then
					if v.RV.KROPosition ~= 0 then
						GotoTrain(calling_ply,target_ply,v,true)
						teleported = true
					end
				end
			elseif class:sub(13,18) == "81-718" then
				if v.WrenchMode ~= 0 then
					if v.KR.Position ~= 0 then
						GotoTrain(calling_ply,target_ply,v,true)
						teleported = true
					end
				end
			else
				if v.KVWrenchMode ~= 0 then
					if v.KV.ReverserSet ~= 0 then
						GotoTrain(calling_ply,target_ply,v,true)
						teleported = true
					end
				end
			end
		end
	end
	if not teleported then
		for k,v in pairs(ents) do
			if v.Owner == target_ply then
				GotoTrain(calling_ply,target_ply,v,false)
				break
			end
		end
	end
end).SkipAccessCheck = true

LFAdmin.Command("signaltp", "u", {"string"}, function(calling_ply, signal)
	if calling_ply:IsPlayerFrozen() then return end
	for _,sig in pairs(ents.FindByClass("gmod_track_signal")) do
		if sig.Name and sig.Name:upper() == signal:upper() then
			if calling_ply:InVehicle() then calling_ply:ExitVehicle() end
			calling_ply:SetPos(sig:GetPos())
			calling_ply:SetEyeAngles(sig:GetAngles()+Angle(0,-90,0))	
			calling_ply:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!				
			return
		end
	end
	LFAdmin.LogPlayer( calling_ply, lang("Signal").." "..signal.." "..lang("NotFound") )
end)

LFAdmin.Command("entitytp", "u", {"number"}, function(calling_ply, ID)
	if calling_ply:IsPlayerFrozen() then return end
	for _,ent in pairs(ents.GetAll()) do
		if ent:EntIndex() == ID then
			if calling_ply:InVehicle() then calling_ply:ExitVehicle() end
			calling_ply:SetPos(ent:GetPos())
			calling_ply:SetEyeAngles(ent:GetAngles()+Angle(0,-90,0))	
			calling_ply:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!				
			return
		end
	end
	LFAdmin.LogPlayer( calling_ply, ID, " "..lang("NotFound") ) 	
end)

LFAdmin.Command({"setwagnumber", "swn"}, "u", {"string"}, function(ply, WagNumber)
	if not IsValid(ply) then return end
	local train = ply:GetEyeTrace().Entity
	if ((not IsValid(train)) or (not train.WagonNumber)) then
		LFAdmin.LogPlayer(ply, lang("SetWagNum1"))
		return
	end
	if (train.Owner ~= ply) then
		LFAdmin.LogPlayer(ply, lang("SetWagNum2"))
		return
	end
	local double = false
	for k, v in pairs(Metrostroi.SpawnedTrains) do
		if k.WagonNumber == WagNumber then
			double = true
		end
	end 
	if not double then
		train.WagonNumber = WagNumber
		train:SetNW2Int("WagonNumber",train.WagonNumber)
	else
		LFAdmin.LogPlayer(ply, lang("SetWagNum3"))
	end
end)

LFAdmin.Command({"udochka", "udc"}, "v", {}, function(calling_ply)
	local boxes = {}
	if (game.GetMap():find("gm_mus_loopline")) then
		boxes = ents.FindByClass("func_tracktrain")
	else
		boxes = ents.FindByClass("func_physbox")
	end
	for k,v in pairs(boxes) do
		v:SetAngles(MetrostroiAdvanced.Box_Angles[k])
		v:SetPos(MetrostroiAdvanced.Box_Positions[k])
		local p = v:GetPhysicsObject()
		if IsValid(p) then p:EnableMotion(true) end
	end
	boxes = nil
	for k,v in pairs(ents.FindByClass("gmod_track_udochka")) do
		local pos = MetrostroiAdvanced.Udc_Positions[k]
		if not pos then print("Warning: " .. k .. " udc position not found") continue end
		v:SetPos(pos)
		local p = v:GetPhysicsObject()
		if IsValid(p) then p:EnableMotion(true) end
	end
	LFAdmin.LogPlayer(true, calling_ply, " "..lang("UDCMessage"))
end)

LFAdmin.Command("enter", "m", {"player"}, function(calling_ply)
	if not IsValid(target_ply) then return end
	if calling_ply:IsPlayerFrozen() then return end
	local train = calling_ply:GetEyeTrace().Entity
	if not IsValid(train) then LFAdmin.LogPlayer( calling_ply, lang("WagonIncorrect") ) return end
	if not train.DriverSeat then LFAdmin.LogPlayer( calling_ply, lang("WagonIncorrect") ) return end
	if IsValid(target_ply:GetVehicle()) then
		target_ply:ExitVehicle()
	end
	local pos = train:GetPos()
	target_ply:SetMoveType(8)
	target_ply:Freeze(true)
	target_ply:SetPos(pos-Vector(0,0,40))
	timer.Simple(0.2, function()
		train.DriverSeat:UseClientSideAnimation()
		train.DriverSeat:Use(target_ply,target_ply,3,1)
		target_ply:Freeze(false)
		if train.DriverSeat == target_ply:GetVehicle() then
			LFAdmin.LogPlayer(true, calling_ply, " "..lang("EnterPlayer").." ", target_ply, " "..lang("IntoTrain"))
		else
			LFAdmin.LogPlayer( calling_ply, lang("EnterFail") )
		end
	end)
end)

LFAdmin.Command("expel", "m", {"player"}, function(calling_ply)
	if not IsValid(target_ply) then return end
	if not IsValid(target_ply:GetVehicle()) then
		LFAdmin.LogPlayer( calling_ply, target_ply, " "..lang("NotInVehicle") )
		return
	else
		target_ply:ExitVehicle()
	end
	LFAdmin.LogPlayer( true, calling_ply, " "..lang("ExpelPlayer").." ", target_ply, " "..lang("OutTrain") )
end)

LFAdmin.Command("ch", "u", {}, function(calling_ply)
	if not IsValid(calling_ply) then return end
	local seat = calling_ply:GetVehicle()
	if not IsValid(seat) then return end
	local train = seat:GetNW2Entity("TrainEntity")
	if not IsValid(train) then return end
	local seatlink = ""
	
	local seats = {"DriverSeat","InstructorsSeat","ExtraSeat"}
	for _,st in pairs(seats) do
		for i=0,4 do
			if i == 0 then i = "" end
			if IsValid(train[st..i]) and train[st..i] == seat then
				seatlink = st..i
				break
			end
		end
	end
	
	if seatlink ~= "" then
		for t,wag in pairs(train.WagonList) do
			if (wag:GetClass() == train:GetClass() and wag ~= train) then
				calling_ply:ExitVehicle()
				calling_ply:SetMoveType(8)
				wag[seatlink]:UseClientSideAnimation()
				timer.Simple(1, function()
					wag[seatlink]:Use(calling_ply,calling_ply,3,1)
				end)
			end
		end
	end
end)

LFAdmin.Command("smartch", "u", {}, function(calling_ply)
	local seat = calling_ply:GetVehicle()
	if not IsValid(seat) then return end
	local seattype = seat:GetNW2String("SeatType")
	if seattype ~= "driver" then return end
	local train1 = seat:GetNW2Entity("TrainEntity")
	if not IsValid(train1) then return end
	if train1:GetClass() == "gmod_subway_81-760" or train1:GetClass() == "gmod_subway_81-760a" then
		calling_ply:ChatPrint(lang("TS760"))
		return
	end
	local train2
	for t,wag in pairs(train1.WagonList) do
		if (wag:GetClass() == train1:GetClass() and wag ~= train1) then
			train2 = wag
		end
	end
	ChangeCab(calling_ply,train1,train2)
end)

LFAdmin.Command("trainstart", "u", {}, function(calling_ply)
	if not IsValid(calling_ply) then return end
    local train = calling_ply:GetTrain()
	if not IsValid(train) then return end
	if train:GetClass() == "gmod_subway_81-760" or train:GetClass() == "gmod_subway_81-760a" then
		calling_ply:ChatPrint(lang("TS760"))
		return
	end
	TrainStart(train)
	LFAdmin.LogPlayer(true, calling_ply, " "..lang("UseTrainStart"))
end)

LFAdmin.Command("trainstop", "u", {}, function(calling_ply)
	if not IsValid(calling_ply) then return end
    local train = calling_ply:GetTrain()
	if not IsValid(train) then return end
	if train:GetClass() == "gmod_subway_81-760" or train:GetClass() == "gmod_subway_81-760a" then
		calling_ply:ChatPrint("Oka is not supported yet.")
		return
	end
	TrainStop(train)
end)

local updated = Metrostroi.Version > 1537278077
for k, v in ipairs({"sopen", "sclose", "sactiv", "sdeactiv", "sopps", updated and "senao", updated and "sdisao"}) do
    if not v then continue end
    LFAdmin.Command(v, "u", {"string"}, function(calling_ply, arg)
        MetrostroiAdvanced.SignalSayHook(calling_ply,"!" .. v, arg, true)
    end)
end

LFAdmin.RegisterAccess("metrostroi_anyplace_spawn", "u")
LFAdmin.RegisterAccess("metrostroi_station_spawn", "u")

LFAdmin.RegisterAccess("gmod_subway_81-717_test", "*")
LFAdmin.RegisterAccess("gmod_subway_81-7401", "v")
LFAdmin.RegisterAccess("gmod_subway_81-7404", "v")

LFAdmin.CommandDescription("stations", "Показывает список станций")
LFAdmin.CommandDescription("station", "Телепортирует на станцию")
LFAdmin.CommandDescription("trains", "Показывает список всех поездов")
LFAdmin.CommandDescription("expass", "Высаживает всех пассажиров")
LFAdmin.CommandDescription("binds", "Открывает меню биндов")
LFAdmin.CommandDescription("traintp", "Телепортирует в поезд игрока")
LFAdmin.CommandDescription("signaltp", "Телепортирует на сигнал")
LFAdmin.CommandDescription("entitytp", "Телепортирует к энтити")
LFAdmin.CommandDescription("setwagnumber", "Устанавливает бортовой номер вагона")
LFAdmin.CommandDescription("udochka", "Сбрасывает позицию удочек")
LFAdmin.CommandDescription("enter", "Телепортирует в кресло машиниста поезда вагона, на который вы смотрите")
LFAdmin.CommandDescription("expel", "Высаживает игрока из поезда")
LFAdmin.CommandDescription("ch", "Меняет кабину")
LFAdmin.CommandDescription("smartch", "Меняет кабину... но умно")
LFAdmin.CommandDescription("trainstart", "Автозапускает поезд")
LFAdmin.CommandDescription("trainstop", "Выключает поезд")