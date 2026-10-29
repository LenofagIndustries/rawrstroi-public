surface.CreateFont("LFI:Interface.TargetID.Name", {
    font = "Roboto",
    size = 18,
    weight = 700,
    extended = true
})

hook.Add("HUDDrawTargetID", "LFI:Interface.TargetID", function()
    local tr = LocalPlayer():GetEyeTrace()
    if not tr or not tr.Entity or not IsValid(tr.Entity) or (not tr.Entity:IsPlayer() and not tr.Entity:IsNPC()) --[[or not (tr.Entity:IsPlayer() and tr.Entity:GetNWBool("LFI:Hide", false) or tr.Entity:IsNPC())]] then return true end
    if not tr.Entity:IsNPC() and tr.Entity:IsPlayer() and tr.Entity:GetNWBool("LFI:Hide", false) then return true end

    local ent = tr.Entity
    local isnpc = ent:IsNPC()
    
    local name = isnpc and ent:GetClass() or ent:Name()
    surface.SetFont("LFI:Interface.TargetID.Name")

    local w, h = surface.GetTextSize(name)
    local mx, my = gui.MouseX(), gui.MouseY()

    if mx == 0 and my == 0 then mx, my = ScrW() / 2, ScrH() / 2 end

    local x, y = mx - w / 2, my + 30

    draw.SimpleTextOutlined(name, "LFI:Interface.TargetID.Name", x, y, isnpc and Color(255, 255, 255) or team.GetColor(ent:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))

    y = y + h + 1
    local tm = ent:Health() .. "%" --team.GetName(ply:Team())

    surface.SetFont("LFI:Interface.TargetID.Name")
    local w, h = surface.GetTextSize(tm)
    local x = mx - w / 2

    draw.SimpleTextOutlined(tm, "LFI:Interface.TargetID.Name", x, y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
    return false
end)
