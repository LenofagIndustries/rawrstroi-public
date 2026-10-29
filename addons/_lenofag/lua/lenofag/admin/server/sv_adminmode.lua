local meta = FindMetaTable("Player")

function meta:SetAdminMode(mode)
    self:SetNWBool("LFI:Admin", not not mode)
    self:SetNotSolid(not not mode)
    self:SetNoTarget(not not mode)
    gmlfi.SetInvisible(self, not not mode)
end

function meta:ToggleAdminMode()
    local mode = self:InAdminMode()
    self:SetAdminMode(not mode)
    return not mode
end

hook.Add("PlayerShouldTakeDamage", "LFI:Admin", function(ply, att)
    if ply:InAdminMode() or att:IsPlayer() and att:InAdminMode() then return false end
end)

hook.Add("GetFallDamage", "LFI:Admin", function(ply)
    if ply:InAdminMode() then return 0 end -- removes falling sound smh
end)