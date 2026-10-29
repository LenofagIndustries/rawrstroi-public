local lnt = {distance = 5000, offset = Vector(0, 0, 80), boffset = Vector(0, 0, 20)}

surface.CreateFont("LNametags.Name", {
	font	= "Roboto",
	size	= 120,
	weight	= 570,
	extended = true,
    blursize = 1
})

surface.CreateFont("LNametags.Team", {
	font	= "Roboto",
	size	= 80,
	weight	= 570,
	extended = true,
    blursize = 1
})

local ecvar = CreateClientConVar("gmlfi_nametags_enabled", "1", true, false, "Enables nametags above players", 0, 1)
local enabled = ecvar:GetBool()
cvars.AddChangeCallback(ecvar:GetName(), function(_, _, new) enabled = tobool(new) end)

local dcvar = CreateClientConVar("gmlfi_nametags_distance", tostring(lnt.distance), true, false, "Sets render distance of nametags")
lnt.distance = dcvar:GetInt()
cvars.AddChangeCallback(dcvar:GetName(), function(_, _, new) lnt.distance = tonumber(new) end)

local wh, bl, gr = Color(255, 255, 255), Color(0, 0, 0), Color(100, 100, 100)
hook.Add("PostPlayerDraw", "LFI:Nametags", function(ply)
    if not enabled then return end
    if not IsValid(ply) --[[or ply == LocalPlayer() or not ply:Alive()]] or ply:IsDormant() or ply:InAdminMode() or ply:GetNWBool("LFI:Hide", false) then return end

    local pos = ply:GetPos()
    local dist, color = pos:Distance(LocalPlayer():GetPos()), team.GetColor(ply:Team()) or wh
    if dist < lnt.distance then
        local eyes = RenderAngles()
        eyes:RotateAroundAxis(eyes:Forward(), 90)
		eyes:RotateAroundAxis(eyes:Right(), 90)

        local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
        local status = ply:GetNetVar("UserStatus")
        cam.Start3D2D((bone and ply:GetBonePosition(bone) or pos) + (bone and lnt.boffset or lnt.offset + eyes:Up()), Angle(0, eyes.y, 90), .05)
            if ply:IsTyping() then draw.SimpleTextOutlined(string.rep(".", CurTime() % 3), "LNametags.Team", 0, status and -160 or -80, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0)) end
            if status then draw.SimpleTextOutlined(status, "LNametags.Team", 0, -80, gr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0)) end
            draw.SimpleTextOutlined(ply:Name() or "(unknown)", "LNametags.Name", 0, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0))
            draw.SimpleTextOutlined(team.GetName(ply:Team()) or "(unknown)", "LNametags.Team", 0, 115, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, bl)
        cam.End3D2D()
    end
end)