local cbg, cbbg = Color(50, 50, 50, 250), Color(30, 30, 30, 100)
local cfg, cfng = Color(35, 35, 35, 100), Color(45, 45, 45, 100)
local csl       = Color(50, 255, 50)
local cbn, cbs  = Color(30, 30, 30, 100), Color(100, 50, 50, 255)

surface.CreateFont("LFI:Metro.NoStations", {
    font = "Roboto",
    size = 36,
    weight = 600,
    extended = true,
})

surface.CreateFont("LFI:Metro.Station", {
    font = "Roboto",
    size = 16,
    weight = 700,
    extended = true,
})

net.Receive("metrostroi_stations_gui", function()
    local frame = vgui.Create("DFrame")
    frame:SetSize(math.max(ScrW() / 3, 640), math.max(ScrH() / 4, 270))
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("Станции")
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, cbg)
        draw.RoundedBox(4, 0, 0, w, 25, cbbg)
        
        if not Metrostroi.StationConfigurations then draw.SimpleText("Станции не настроены на этой карте", "LFI:Metro.NoStations", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
    end
    
    if not Metrostroi.StationConfigurations then return end
    
    local stations = vgui.Create("DScrollPanel", frame)
    stations:Dock(FILL)
    stations.Paint = function() end
    
    local sel, i = 0, 0
    
    local tp = vgui.Create("DButton", frame)
    tp:Dock(BOTTOM)
    tp:SetText("Телепортироваться")
    tp:SetEnabled(false)
    tp.Paint = function(self, w, h) draw.RoundedBoxEx(4, 0, 0, w, h, self:IsDown() and cbs or cbn, false, false, true, true) end
    tp.DoClick = function() if sel ~= 0 then print(sel) RunConsoleCommand("lf", "station", "" .. sel) end end
    
    for k, v in pairs(Metrostroi.StationConfigurations) do
        if not v.positions then continue end
    
        local but = vgui.Create("DButton", stations)
        but:Dock(TOP)
        but:SetText("")
        but:SetZPos(tonumber(k))
        
        local ss = v.names and table.concat(v.names, ", ") or ""
        but.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, 50, (tonumber(k) or 0) % 2 == 1 and cfg or cfng)
            draw.SimpleText(k, "LFI:Metro.Station", 7.5, h / 2, sel == k and csl or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(ss, "LFI:Metro.Station", 75, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 
        end
        but.DoClick = function() sel = k tp:SetEnabled(true) end
    end
end)