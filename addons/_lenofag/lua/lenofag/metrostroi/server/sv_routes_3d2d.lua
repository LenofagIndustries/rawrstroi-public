util.AddNetworkString("LFI:Metro.Routes")

local signalClass = "gmod_track_signal"

gmlfi.metro.routes = gmlfi.metro.routes or {routesInfo = {}}

local signals = ents.FindByClass(signalClass)

local GenerateRoutes = function()
    gmlfi.metro.Log("generating signal routes list...") local t = os.clock()
    gmlfi.metro.routes.routesInfo = {}

    signals = ents.FindByClass(signalClass)
    for _, signal in ipairs(signals) do
        if not IsValid(signal) or not signal.Routes then continue end
        local info = {}

        for _, route in ipairs(signal.Routes) do
            local name = route.RouteName
            if not name or name == "" then
                if route.Manual and signal.Name and signal.Name ~= "" then
                    name = signal.Name
                else continue end
            end
            if string.Trim(name) ~= name then name = "\"" .. name .. "\"" end
            if route.Emer then name = "Резервный " .. name end
            info[#info + 1] = name
        end

        if next(info) == nil then continue end
        gmlfi.metro.routes.routesInfo[signal:EntIndex()] = info
    end

    gmlfi.metro.Log("finished generating %s routes in %s seconds", table.Count(gmlfi.metro.routes.routesInfo), os.clock() - t)
    return gmlfi.metro.routes.routesInfo
end

local SendRoutes = function(ply, regen)
    if regen or not gmlfi.metro.routes.routesInfo or next(gmlfi.metro.routes.routesInfo) == nil then GenerateRoutes() end
    net.Start("LFI:Metro.Routes")
    net.WriteString(util.TableToJSON(gmlfi.metro.routes.routesInfo))
    if ply then net.Send(ply) else net.Broadcast() end
end

hook.Add("MetrostroiLoaded", "LFI:Metro.Routes", function()
    local postSignalInit = Metrostroi.PostSignalInitialize
    Metrostroi.PostSignalInitialize = function(...)
        signals = ents.FindByClass(signalClass)
        timer.Simple(3, SendRoutes)
        postSignalInit(...)
    end
end)

timer.Create("LFI:Metro.Routes.State", 2, 0, function()
    for _, v in ipairs(signals) do
        if IsValid(v) and v:GetNW2Bool("MSRouteClosed", false) ~= v.Close then v:SetNW2Bool("MSRouteClosed", v.Close) end
    end
end)

-- this really looks like a lag exploit to me
net.Receive("LFI:Metro.Routes", function(_, ply)
    if not net.ReadBool() then SendRoutes(ply) gmlfi.metro.Log("%s requested routes from server", ply) end
end)

concommand.Add("gmlfi_metro_routes_generate", function(ply) if not IsValid(ply) or (ply:IsPlayer() and ply:IsSuperAdmin()) then SendRoutes(nil, true) end end)
