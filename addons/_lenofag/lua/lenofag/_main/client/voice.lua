if not gmlfi then return print("voice.lua says gmlfi is nil...") end

surface.CreateFont("LFI:Voice", {
    font = "Roboto",
    size = 18,
    weight = 300,
    extended = true
})

gmlfi.voice = gmlfi.voice or {}
gmlfi.voice.players = gmlfi.voice.players or {}

hook.Add("PlayerStartVoice", "LFI:Voice", function(ply)
    if not ply or not IsValid(ply) or not ply:IsPlayer() then return end
    if not IsValid(gmlfi.voice.panel) then return end

    if not IsValid(ply._LFIVoicePanel) then
        surface.SetFont("LFI:Voice")

        local panel = vgui.Create("DPanel", gmlfi.voice.panel) --vgui.Create("DPanel")
        --panel:SetAlpha(0)

        local info = {name = ply:Name(), color = team.GetColor(ply:Team())}

        panel.Paint = function(self, w, h)
            --draw.RoundedBoxEx(4, 0, 0, w, h, Color(50, 50, 50, 200), false, true, false, true)

            surface.SetDrawColor(50, 50, 50, 200)
            surface.DrawRect(1, 1, w, h)

            surface.SetDrawColor(info.color.r, info.color.g, info.color.b, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        panel:SetSize(160, 32)
        panel:Dock(BOTTOM)
        panel:DockMargin(0, 2, 0, 2)

        panel.avatar = vgui.Create("AvatarImage", panel)
        panel.avatar:Dock(LEFT)
        panel.avatar:SetSize(32, 32)
        panel.avatar:SetPlayer(ply, 32)

        panel.name = vgui.Create("DLabel", panel)
        panel.name:Dock(FILL)
        panel.name:DockMargin(5, 0, 0, 0)
        panel.name:SetFont("LFI:Voice")
        panel.name:SetText(info.name)
        panel.name:SetTextColor(Color(255, 255, 255))

        gmlfi.voice.players[ply] = panel
        ply._LFIVoicePanel = panel
    end
    
    return true
end)

hook.Add("PlayerEndVoice", "LFI:Voice", function(ply)
    if gmlfi.voice.players[ply] and IsValid(gmlfi.voice.players[ply]) then
        gmlfi.voice.players[ply]:Remove()
        gmlfi.voice.players[ply] = nil
        ply._LFIVoicePanel = nil
    end
end)

hook.Add("InitPostEntity", "LFI:Voice.Init", function()
    gmlfi.voice.panel = vgui.Create("DPanel")
    print("Voice panel created: ", gmlfi.voice.panel)

    gmlfi.voice.panel:ParentToHUD()
    gmlfi.voice.panel:SetPos(ScrW() - 300, 100)
    gmlfi.voice.panel:SetSize(250, ScrH() - 200)
    gmlfi.voice.panel:SetPaintBackground(false)
end)