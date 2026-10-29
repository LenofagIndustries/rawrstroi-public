-- totally pasted from https://github.com/TheFUlDeep/gmod_addons/blob/master/metrostroi_scripts/lua/metrostroi/sh_draw_signals_routes.lua
--
-- redesigned and slightly optimized i guess
-- removed "if SERVER then ... end if SERVER then return end" kek

gmlfi.metro.routes = gmlfi.metro.routes or {texts = {}, routesInfo = {}}

hook.Add("InitPostEntity", "LFI:Metro.Routes", function()
    net.Start("LFI:Metro.Routes") net.WriteBool(false) net.SendToServer()
end)

local maxdist, signals, viewpos = 4000^2, ents.FindByClass("gmod_track_signal"), Vector()

net.Receive("LFI:Metro.Routes", function()
    gmlfi.metro.routes.routesInfo = util.JSONToTable(net.ReadString() or "[]") or {}
    signals = ents.FindByClass("gmod_track_signal")
    gmlfi.metro.Log("received routes for %s signals", table.Count(gmlfi.metro.routes.routesInfo))
end)

local off = {vec = Vector(0, 0, 90), ang = Angle(0, 180, 90)}
timer.Create("LFI:Metro.Routes", 1, 0, function()
    gmlfi.metro.routes.texts = {}
    for k, signal in ipairs(signals) do
        if not IsValid(signal) or not gmlfi.metro.routes.routesInfo[signal:EntIndex()] then continue end
        if signal:IsDormant() or signal:GetPos():DistToSqr(viewpos) > maxdist then continue end
        gmlfi.metro.routes.texts[#gmlfi.metro.routes.texts + 1] = {signal, signal:GetPos() + off.vec, signal:GetAngles() + off.ang, gmlfi.metro.routes.routesInfo[signal:EntIndex()], signal:GetNW2Bool("MSRouteClosed", false)}
    end
end)

timer.Create("LFI:Metro.Routes.RefreshSignals", 5, 0, function() signals = ents.FindByClass("gmod_track_signal") end)

surface.CreateFont("LFI:Metro.Routes", {
    font     = "Roboto",
    size     = 240,
    weight   = 570,
    extended = true,
})

local permatexts = { -- permaprops for losers
    {text = {"Выезд из этой канавы нестабилен", "Будьте осторожны!"}, vec = Vector(-4988, -3435, -13090), ang = Angle(0, -90, 90), map = "gm_metro_nekrasovskaya_line_v6"}
} local curmap = game.GetMap()

local white, red, black = Color(255, 255, 255), Color(255, 0, 0), Color(0, 0, 0)
hook.Add("PreDrawEffects", "LFI:Metro.Routes", function()
    viewpos = EyePos()
    for _, params in ipairs(gmlfi.metro.routes.texts) do
        cam.Start3D2D(params[2], params[3], .05)
            local hh = 0
            for _, t in ipairs(params[4]) do
                local _, h = draw.SimpleTextOutlined(t, "LFI:Metro.Routes", 0, hh, params[5] and red or white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, black)
                hh = hh - h
            end
        cam.End3D2D()
    end

    for _, data in ipairs(permatexts) do
        if curmap ~= data.map or data.vec:DistToSqr(viewpos) > maxdist then continue end
        cam.Start3D2D(data.vec, data.ang, .05)
            local hh = 0
            for _, t in ipairs(data.text) do
                local _, h = draw.SimpleTextOutlined(t, "LFI:Metro.Routes", 0, hh, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, black)
                hh = hh - h
            end
        cam.End3D2D()
    end
end)

concommand.Add("gmlfi_metro_routes_request", function() net.Start("LFI:Metro.Routes") net.SendToServer() end)
concommand.Add("gmlfi_metro_routes_print", function() PrintTable(gmlfi.metro.routes.routesInfo) PrintTable(signals) end)