-- I LOVE DETOURING!!!!!!!!!!!!
local load = function()
    player_manager._TranslatePlayerModelReal = player_manager._TranslatePlayerModelReal or player_manager.TranslatePlayerModel
    player_manager.TranslatePlayerModel = function(n)
        local m = player_manager.AllValidModels()[n]
        return m or "models/player/metrodriver/metrodriver_0" .. math.random(9) .. ".mdl"
    end

    -- gamemodes/sandbox/gamemode/player_class/player_sandbox.lua

    local PLAYER = player_manager.GetPlayerClasses()["player_sandbox"]
    local JUMPING
    function PLAYER:StartMove(move)
        if bit.band(move:GetButtons(), IN_JUMP) ~= 0 and bit.band(move:GetOldButtons(), IN_JUMP) == 0 and self.Player:OnGround() then
            JUMPING = true
        end
    end

    function PLAYER:FinishMove(move)
        if JUMPING then
            local forward = move:GetAngles()
            forward.p = 0
            forward = forward:Forward()
            local speedBoostPerc = 0.5
            local speedAddition = math.abs( move:GetForwardSpeed() * speedBoostPerc )
            move:SetVelocity(forward * speedAddition + move:GetVelocity())
        end

        JUMPING = nil
    end

    player_manager.RegisterClass("player_sandbox", PLAYER, "player_default")
end

hook.Add("Initialize", "LFI:Metro.UnKleiner", load) if player_manager and player_manager._TranslatePlayerModelReal then load() end