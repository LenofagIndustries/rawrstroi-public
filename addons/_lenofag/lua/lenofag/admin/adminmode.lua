if not gmlfi then return print("adminmode says gmlfi is nil...") end

local meta = FindMetaTable("Player")

function meta:InAdminMode()
    if not gmlfi.IsHuman(self) then return false end
    return self:GetNWBool("LFI:Admin", false)
end

hook.Add("PlayerFootstep", "LFI:SneakyAdmin", function(ply)
    if gmlfi.IsHuman(ply) and ply:InAdminMode() then return true end
end)

if CLIENT then
    hook.Add("DrawPhysgunBeam", "LFI:AdminMode", function(ply)
        if gmlfi.IsHuman(ply) and ply:InAdminMode() then return false end
    end)
end