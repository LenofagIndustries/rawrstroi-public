local cvarfreeze = CreateConVar("gmlfi_antilag_prop_freeze", "1", FCVAR_SERVER_CAN_EXECUTE, "Freezes props on spawn", 0, 1)

hook.Add("PlayerSpawnedProp", "LFI:Antilag.SpawnFreeze", function(ply, model, ent)
    if not cvarfreeze:GetBool() then return end
    if not ent or not IsValid(ent) then return end
    local phys = ent:GetPhysicsObject() if not phys or not IsValid(phys) then return end

    phys:Sleep()
    phys:EnableMotion(false)
end)

hook.Add("PlayerSpawnedRagdoll", "LFI:Antilag.SpawnFreeze", function(ply, model, ent)
    if not cvarfreeze:GetBool() then return end
    if not ent or not IsValid(ent) or not IsValid(ent:GetPhysicsObject()) then return end
    for k = 0, ent:GetPhysicsObjectCount() - 1 do
        ent:GetPhysicsObjectNum(k):EnableMotion(false)
    end
end)

hook.Add("PlayerSpawnedSENT", "LFI:Antilag.Spawn", function(_, ent)
    ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
    -- timer.Simple(1, function()
    --     for v in pairs(constraint.GetAllConstrainedEntities(ent) or {}) do
    --         v:SetCollisionGroup(COLLISION_GROUP_WORLD)
    --     end
    -- end)
end)

hook.Add("PlayerSpawnedVehicle", "LFI:Antilag.Spawn", function(_, ent)
    ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
end)

if not gmlfi then return print("sv_antilag says gmlfi is nil...") end

util.AddNetworkString("LFI:Antilag")
util.AddNetworkString("LFI:Antilag.Increase")
util.AddNetworkString("LFI:Antilag.BadPlayer")

gmlfi.antilag = gmlfi.antilag or {}
gmlfi.antilag.enabled = true

gmlfi.antilag.badStress = 100

gmlfi.antilag.notify = function(action, opt)
    net.Start("LFI:Antilag")
        net.WriteInt(action, 5)
        net.WriteInt(opt or 0, 13)
    net.Broadcast()
end

gmlfi.antilag.notifyBadPlayer = function(ply, props)
    gmlfi.antilag.log(string.format("%s [%s] props is lagging (%s props in total)", ply:Name(), ply:SteamID(), props))
    net.Start("LFI:Antilag.BadPlayer")
        net.WriteEntity(ply)
        net.WriteUInt(props, 14)
    net.Send(gmlfi.AdminsRecipientFilter())
end

gmlfi.antilag.actions = {
    -- metrostroi gaming
    -- [3] = function()
    --     local e2s = ents.FindByClass("gmod_wire_expression2")
    --     if next(e2s) == nil then gmlfi.antilag.notify(3, 0) return gmlfi.antilag.log("no e2s found, action skipped...") end

    --     gmlfi.antilag.log(string.format("stopping %s e2s...", #e2s))
    --     gmlfi.antilag.notify(3, #e2s)
    --     for k, v in ipairs(e2s) do
    --         v:PCallHook("destruct")
    --     end
    -- end,
    -- [5] = function()
    --     local all = ents.GetAll()
    --     if next(all) == nil then return gmlfi.antilag.log("WTF NO ENTITIES??????") end -- lol

    --     gmlfi.antilag.log("freezing all physics objects...")
    --     gmlfi.antilag.notify(5)

    --     local badguys = {}
    --     for k, v in ipairs(all) do
    --         local phys, owner = v:GetPhysicsObject(), v:CPPIGetOwner()
    --         if IsValid(phys) then
    --             if owner and IsValid(owner) and owner:IsPlayer() and phys:GetStress() >= gmlfi.antilag.badStress then badguys[owner] = badguys[owner] and badguys[owner] + 1 or 1 end
    --             phys:Sleep()
    --             phys:EnableMotion(false)
    --         end
    --     end

    --     for ply, props in pairs(badguys) do
    --         gmlfi.antilag.notifyBadPlayer(ply, props)
    --     end
    -- end,
    -- [7] = function()
    --     gmlfi.antilag.log("critical: cleaning up map...")
    --     gmlfi.antilag.notify(7)
    --     game.CleanUpMap()
    -- end,
    -- [10] = function()
    --     gmlfi.antilag.log("WARNING: server is still lagging! cleaning map again...")
    --     gmlfi.antilag.notify(10)
    --     game.CleanUpMap()
    -- end,
    [5] = function()
        local e2s = ents.FindByClass("gmod_wire_expression2")
        if next(e2s) == nil then gmlfi.antilag.notify(3, 0) return gmlfi.antilag.log("no e2s found, action skipped...") end

        gmlfi.antilag.log(string.format("stopping %s e2s...", #e2s))
        gmlfi.antilag.notify(3, #e2s)
        for k, v in ipairs(e2s) do
            v:PCallHook("destruct")
        end
    end,
    [10] = function()
        local all = ents.GetAll()
        if next(all) == nil then return gmlfi.antilag.log("WTF NO ENTITIES??????") end -- lol

        gmlfi.antilag.log("freezing all physics objects...")
        gmlfi.antilag.notify(5)

        local badguys = {}
        for k, v in ipairs(all) do
            local phys, owner = v:GetPhysicsObject(), v:CPPIGetOwner()
            if IsValid(phys) then
                if owner and IsValid(owner) and owner:IsPlayer() and phys:GetStress() >= gmlfi.antilag.badStress then badguys[owner] = badguys[owner] and badguys[owner] + 1 or 1 end
                phys:Sleep()
                phys:EnableMotion(false)
            end
        end

        for ply, props in pairs(badguys) do
            gmlfi.antilag.notifyBadPlayer(ply, props)
        end
    end,
    [15] = function()
        gmlfi.antilag.log("CRITICAL: server is still lagging! cleaning map and resetting lag level...") --this may be DoS, check your network logs; 
        gmlfi.antilag.notify(13)
        gmlfi.antilag.level = 0
        game.CleanUpMap()
    end
}

gmlfi.antilag.log = function(text) print(string.format("sv_antilag: %s", text)) end
gmlfi.antilag.increaseLevel = function()
    gmlfi.antilag.level = gmlfi.antilag.level + 1
    gmlfi.antilag.log(string.format("lag level increased (current is %s)", gmlfi.antilag.level))
    
    net.Start("LFI:Antilag.Increase")
    net.WriteInt(gmlfi.antilag.level, 5)
    net.Broadcast()

    if gmlfi.antilag.actions[gmlfi.antilag.level] then gmlfi.antilag.actions[gmlfi.antilag.level]() end
end
gmlfi.antilag.resetLevel = function() gmlfi.antilag.level = 0 gmlfi.antilag.log("resetting lag level...") gmlfi.antilag.notify(0) end
gmlfi.antilag.last = RealTime()
gmlfi.antilag.normal = 33
gmlfi.antilag.normalcount = 0
gmlfi.antilag.level = 0

hook.Add("Tick", "LFI:Antilag", function()
    if not gmlfi.antilag.enabled then return end
    if (2 / (RealTime() - gmlfi.antilag.last)) <= 2.2 then gmlfi.antilag.increaseLevel() end
    if (2 / (RealTime() - gmlfi.antilag.last)) == math.huge then return end
    if (2 / (RealTime() - gmlfi.antilag.last)) >= 16 and gmlfi.antilag.level ~= 0 then gmlfi.antilag.resetLevel() end
    gmlfi.antilag.last = RealTime()
end)

concommand.Add("gmlfi_antilag_toggle", function(ply)
    if gmlfi.IsHuman(ply) then return end
    gmlfi.antilag.enabled = not gmlfi.antilag.enabled
    gmlfi.antilag.log(string.format("antilag is now %s", gmlfi.antilag.enabled and "enabled" or "disabled"))
end)

hook.Add("PlayerSpawnSWEP", "LFI:Antilag", function() return false end)
hook.Add("PlayerSpawnNPC", "LFI:Antilag", function() return false end)

local restrictions = {
    swep = {
        ["weapon_crossbow"] = true,
        ["weapon_rpg"] = "m",
        ["weapon_shotgun"] = "m",
        ["weapon_ar2"] = "m",
        ["weapon_pistol"] = "m",
        ["weapon_smg1"] = "m",
        ["weapon_frag"] = true,
        ["weapon_stunstick"] = "m",
        ["weapon_bugbait"] = true,
        ["weapon_slam"] = true,
        ["weapon_357"] = "m",
        ["weapon_spade"] = "s",
        ["manhack_welder"] = "s",
        ["weapon_flechettegun"] = "*",
        ["weapon_vape_mega"] = "*",
    },
    sent = {
        ["item_suitcharger"] = "a",
        ["gmod_track_arm"] = function(ply) return ply:GetNW2Bool("MDispatcher") or ply:HasAccess("m") end,
        ["item_healthcharger"] = "a",
        ["sent_ball"] = true,
        ["prop_thumper"] = true,
        ["item_suit"] = true,
        ["gmod_track_scb_server"] = "m",
        ["npc_grenade_frag"] = true,
        ["item_ammo_ar2_altfire"] = true,
        ["gmod_subway_gvmu"] = "v",
        ["gmod_subway_tatra_t3"] = "v",
        ["gmod_subway_motovz"] = "v",
        ["gmod_track_switch"] = "m",
        ["combine_mine"] = true,
        ["weapon_striderbuster"] = true,
        ["gmod_track_clock_arrive"] = "m",
        ["gmod_track_powermeter"] = function(ply) return ply:GetNW2Bool("MDispatcher") or ply:HasAccess("m") end,
        ["grenade_helicopter"] = true,
        ["combine_mine_resistance"] = "a",
        ["item_battery"] = "a",
        ["item_ammo_smg1_grenade"] = "a",
        ["item_ammo_crossbow"] = "a",
        ["ent_poker_game"] = "v",
        ["edit_fog"] = "*",
        ["edit_sky"] = "*",
        ["edit_sun"] = "*"
    },
    tool = {
        ["signalling"] = "a",
        ["paint"] = true,
        ["duplicator"] = true,
        ["inflator"] = true,
        ["advdupe2"] = "v",
        ["wire_expression2"] = "v",
        ["wire_explosive"] = "a",
        ["wire_simple_explosive"] = "a",
        ["wire_igniter"] = "a",
        ["wire_turret"] = "*"
    },
    vehicle = {
        ["prop_vehicle_apc"] = "a"
    },
    models = {
        ["models/props_c17/oildrum001_explosive.mdl"] = "s",
        ["models/props_junk/gascan001a.mdl"] = "s",
        ["models/props_phx/oildrum001_explosive.mdl"] = "s",
        ["models/props_phx/ball.mdl"] = "s",
        ["models/props_phx/cannonball_solid.mdl"] = "s",
        ["models/props_phx/misc/smallcannonball.mdl"] = "s",
        ["models/props_phx/cannonball.mdl"] = "s",
        ["models/props_phx/misc/potato_launcher_explosive.mdl"] = "s",
        ["models/props_phx/misc/flakshell_big.mdl"] = "s",
        ["models/props_phx/ww2bomb.mdl"] = "s",
        ["models/props_phx/mk-82.mdl"] = "s",
        ["models/props_phx/amraam.mdl"] = "s",
        ["models/props_phx/torpedo.mdl"] = "s",
    }
}

hook.Add("PlayerGiveSWEP", "LFI:Antilag", function(ply, wep)
    local r = restrictions.swep[wep] if not r then return end
    if (r == true and not ply:IsRamzi()) or r and ((isfunction(r) and not r(ply)) or not ply:HasAccess(r)) then return false, ply:ChatPrint("Вашему рангу недоступна выдача этого оружия!") end
end)

hook.Add("PlayerSpawnSENT", "LFI:Antilag", function(ply, class)
    local r = restrictions.sent[class] if not r then return end
    if r == true then return false, ply:ChatPrint("Спавн этого энтити запрещен!") end
    if isfunction(r) and not r(ply) then return false, ply:ChatPrint("Вам недоступен спавн этого энтити!") end
    if not isfunction(r) and not ply:HasAccess(r) then return false, ply:ChatPrint("Вашему рангу недоступен спавн этого энтити!") end
end)

hook.Add("PlayerSpawnVehicle", "LFI:Antilag", function(ply, _, _, table)
    local class = table.Class or ""
    local r = restrictions.vehicle[class] if not r then return end
    if r == true then return false, ply:ChatPrint("Спавн этого транспортного средства запрещен!") end
    if isfunction(r) and not r(ply) then return false, ply:ChatPrint("Вам недоступен спавн этого транспортного средства!") end
    if not isfunction(r) and not ply:HasAccess(r) then return false, ply:ChatPrint("Вашему рангу недоступен спавн этого транспортного средства!") end
end)

hook.Add("CanTool", "LFI:Antilag", function(ply, _, name)
    local r = restrictions.tool[name] if not r then return end
    if (r == true and not ply:IsRamzi()) or r and ((isfunction(r) and not r(ply)) or not ply:HasAccess(r)) then return false, ply:ChatPrint("Вашему рангу недоступен этот инструмент!") end
end)

local permadelete = {
    ["gm_metro_nekrasovskaya_line_v6"] = {
        [2831] = true,
    }
}

hook.Add("InitPostEntity", "LFI:Antilag", function()
    permadelete = permadelete[game.GetMap()] if not permadelete then return end
    for _, v in ipairs(ents.GetAll()) do
        if permadelete[v:MapCreationID()] then v:Remove() end
    end
end)

local ia = function(ply, model)
    if not ply:IsVIP() then return false end
    local r = restrictions.models[model] if not r then return end
    if (r == true and not ply:IsRamzi()) or r and ((isfunction(r) and not r(ply)) or not ply:HasAccess(r)) then return false, ply:ChatPrint("Вашему рангу недоступен спавн объектов с этой моделью!") end
end
hook.Add("PlayerSpawnEffect", "LFI:Antilag", ia)
hook.Add("PlayerSpawnProp", "LFI:Antilag", ia)
hook.Add("PlayerSpawnRagdoll", "LFI:Antilag", ia)

hook.Add("StarfallCanSuperUser", "LFI:Antilag", function(ply) return not IsValid(ply) or ply:IsRamzi() end)
