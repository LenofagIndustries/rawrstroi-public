net.Receive("LFI:AAFK", function()
    local ply, state = net.ReadEntity(), net.ReadBool()
    if not ply or not IsValid(ply) or not ply:IsPlayer() then return end
    chat.AddText(team.GetColor(ply:Team()), ply:Name(), Color(255, 255, 255), state and " вернулся из " or " теперь ", state and Color(150, 255, 50) or Color(255, 50, 50), "AFK")
end)

surface.CreateFont("LFI:AAFK.Title", {
    font = "Roboto",
    extended = true,
    size = 52,
    weight = 600,
    blursize = .5,
    shadow = true
})

surface.CreateFont("LFI:AAFK.Subtitle", {
    font = "Roboto",
    extended = true,
    size = 38,
    weight = 400,
    blursize = .5,
    shadow = true
})

local blur = Material("pp/blurscreen")

hook.Add("HUDPaint", "LFI:AAFK", function()
    if not gmlfi.IsHuman(LocalPlayer()) or gmlfi.timeout.is or not LocalPlayer():GetNWBool("LFI:AAFK", false) then return end
    
    DisableClipping(true)
    surface.SetMaterial(blur)
    surface.SetDrawColor(255, 255, 255, 255)

    for i = 0.33, 1, 0.33 do
        blur:SetFloat("$blur", 5 * i)
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end

    surface.SetDrawColor(10, 10, 10, 250)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    DisableClipping(false)

    local time = math.abs(LocalPlayer():GetNWInt("LFI:AAFK.Last", CurTime()) - CurTime())

    draw.SimpleText("Wake up, Neo...", "LFI:AAFK.Title", ScrW() / 2, ScrH() / 2, Color(200, 200, 200, 200), TEXT_ALIGN_CENTER)
    draw.SimpleText(string.format("%01d:%02d:%02d", math.floor(time / 3600), math.floor(time / 60) % 60, math.floor(time) % 60), "LFI:AAFK.Subtitle", ScrW() / 2, ScrH() / 1.8, Color(255, 255, 255), TEXT_ALIGN_CENTER)
end)
