-- remake of https://github.com/Alexell/metrostroi_scoreboard_pro/blob/master/lua/autorun/mscoreboard_updater.lua

local GetStationName = function(id)
    return Metrostroi.StationConfigurations and Metrostroi.StationConfigurations[id] and Metrostroi.StationConfigurations[id].names[1] or ""
end

local BuildStationInfo = function(train)
    local prevs, curs, nexts = "", "", ""

    curs = GetStationName(train:ReadCell(49160))
    if curs ~= "" then return train:ReadCell(49168), curs end

    prevs, nexts = GetStationName(train:ReadCell(49162)), GetStationName(train:ReadCell(49161))
    if prevs ~= "" and nexts ~= "" then return train:ReadCell(49167), string.format("%s - %s", prevs, nexts) end

    local ent_station = 0
    local pos, map_pos = train:GetPos()
    local radius = 4000 -- Радиус по умолчанию для станций на всех картах
    local cur_map = game.GetMap()
    local Sz
    local S
    
    radius = radius*radius

    if Metrostroi.StationConfigurations then
        for k, v in pairs(Metrostroi.StationConfigurations) do
            if isnumber(k) and v.positions[2] then 
                map_pos = v.positions and v.positions[2] 
            else 
                map_pos = v.positions and v.positions[1] 
            end
            if cur_map:find("gm_metro_jar_imagine_line") and (v.names[1] == "ДДЭ" or v.names[1] == "Диспетчерская") then continue end
            if map_pos then
                S = pos:DistToSqr(map_pos[1])
                if (pos.z > 0 and map_pos[1].z < 0) or (pos.z < 0 and map_pos[1].z > 0) then
                    Sz = math.abs(pos.z) + math.abs(map_pos[1].z)
                end
                if (pos.z > 0 and map_pos[1].z > 0) or (pos.z < 0 and map_pos[1].z < 0) then
                    Sz = math.abs(pos.z - map_pos[1].z)
                end
                if S < radius and Sz < 200 then 
                    ent_station = k
                    radius = S
                end
            end
        end
    end

    return 0, GetStationName(ent_station)
end

local trainsw = {
    ["gmod_subway_em508"] = true,
    ["gmod_subway_81-702"] = true,
    ["gmod_subway_81-703"] = true,
    ["gmod_subway_81-705_old"] = true,
    ["gmod_subway_ezh"] = true,
    ["gmod_subway_ezh3"] = true,
    ["gmod_subway_ezh3ru1"] = true,
    ["gmod_subway_81-717_mvm"] = true,
    ["gmod_subway_81-718"] = true,
    ["gmod_subway_81-720"] = true,
    ["gmod_subway_81-720_1"] = true,
    ["gmod_subway_81-720a"] = true,
    ["gmod_subway_81-717_freight"] = true,
    ["gmod_subway_81-717_5a"] = true,
}
local FixedRoute = function(class, route)
    local n = tonumber(route)
    return class ~= "" and route ~= "" and (trainsw[class] and n / 10 or n) or route or ""
end

local trains = {}
timer.Simple(1.5, function()
    for _, class in pairs(Metrostroi.TrainClasses) do
        local ENT = scripted_ents.Get(class)
        if not ENT.Spawner or not ENT.SubwayTrain then continue end
        trains[class] = true
    end
end)

local st = { -- special treatment
    a = {
        ["gmod_subway_81-722"]     = true,
        ["gmod_subway_81-722_3"]   = true,
        ["gmod_subway_81-722_new"] = true,
        ["gmod_subway_81-7175p"]   = true,
    },
    b = {
        ["gmod_subway_81-717_6"]   = true,
        ["gmod_subway_81-740_4"]   = true,
    }
}
local run = function()
    local route, class, owner
    local now = CurTime()
    for train in pairs(Metrostroi.SpawnedTrains) do -- idk why this uses key-value table
        if not IsValid(train) or not trains[train:GetClass()] or not IsValid(train.Owner) then continue end
        class, owner, route = train:GetClass(), train.Owner, 0

        if st.a[class] then route = train.RouteNumberSys.CurrentRouteNumber
        elseif st.b[class] then route = train.ASNP.RouteNumber
        else if train.RouteNumber then route = train.RouteNumber.RouteNumber end end

        route = FixedRoute(class, route)

        local line, station = BuildStationInfo(train)
        owner:SetNetVar("LFI:Metro.RouteInfo/Class", train:GetClass()) -- idc
        owner:SetNetVar("LFI:Metro.RouteInfo/Wagons", #train.WagonList)
        owner:SetNetVar("LFI:Metro.RouteInfo/Station", station)
        owner:SetNetVar("LFI:Metro.RouteInfo/Route", tostring(route))
        owner:SetNetVar("LFI:Metro.RouteInfo/Line", line)
        owner:SetNetVar("LFI:Metro.RouteInfo/Operating", train.DriverSeat and train.DriverSeat == owner:GetVehicle())
        owner.LFIRouteInfoD = now
        local d, doo = IsValid(train.DriverSeat) and train.DriverSeat:GetDriver()
        if IsValid(d) and d:IsPlayer() and owner ~= d then d:SetNetVar("LFI:Metro.RouteInfo/Operating.Other", owner:Name()) train.LFITRAINDO, doo = d, true end
        if not doo and IsValid(train.LFITRAINDO) then train.LFITRAINDO:SetNetVar("LFI:Metro.RouteInfo/Operating.Other") end
        owner.LFITRAINCUR = train
    end
    route, class, owner = nil, nil, nil -- performance update

    for k, v in ipairs(player.GetAll()) do
        if v.LFIRouteInfoD == now then continue end
        local veh, some = v:GetVehicle(), true
        if IsValid(veh) then
            local train = veh:GetParent()
            if IsValid(train) and trains[train:GetClass()] then
                if train.RheostatController and train.RheostatController.SelectedPosition then v:SetNetVar("LFI:Metro.RouteInfo/RKPos", train.RheostatController.SelectedPosition) end
                if train.Owner == v then continue end
                local line, station = BuildStationInfo(train)
                v:SetNetVar("LFI:Metro.RouteInfo/Station", station)
                v:SetNetVar("LFI:Metro.RouteInfo/Line", line)
                some = nil
            end
        end
        if some then
            v:SetNetVar("LFI:Metro.RouteInfo/RKPos")
            v:SetNetVar("LFI:Metro.RouteInfo/Station")
            v:SetNetVar("LFI:Metro.RouteInfo/Line")
        end
    end
end
timer.Create("LFI:Metro.RouteInfo", 1, 0, function()
    local s, err = pcall(run)
    if not s then print(err) print(debug.traceback()) end
end)

hook.Add("EntityRemoved", "LFI:Metro.RouteInfo", function(ent)
    if ent.Owner and ent.Owner.LFITRAINCUR == ent then
        ent.Owner:SetNetVar("LFI:Metro.RouteInfo/Class")
        ent.Owner:SetNetVar("LFI:Metro.RouteInfo/Wagons")
        ent.Owner:SetNetVar("LFI:Metro.RouteInfo/Station")
        ent.Owner:SetNetVar("LFI:Metro.RouteInfo/Route")
        ent.Owner:SetNetVar("LFI:Metro.RouteInfo/Line")
        ent.Owner:SetNetVar("LFI:Metro.RouteInfo/Operating")
        ent.Owner:SetNetVar("LFI:Metro.RouteInfo/RKPos")
        ent.Owner.LFITRAINCUR = nil
    end
    if IsValid(ent.LFITRAINDO) then ent.LFITRAINDO:SetNetVar("LFI:Metro.RouteInfo/Operating.Other") end
end)
