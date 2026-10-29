local userself = function(from, to)
    if from ~= to and (IsValid(from) and not from:HasAccess("m")) then return true, LFAdmin.LogPlayer(from, "Использование этой команды на других игроков доступно только администрации") end
end

LFAdmin.Command("god", "v", {"players?"}, function(activator, target)
    for k, v in ipairs(target or {activator}) do if not userself(activator, v) then v:GodEnable() else return end end
    LFAdmin.LogPlayer(true, activator, " выдал бессмертие ", target or "#самому себе")
end)

LFAdmin.Command("ungod", "v", {"players?"}, function(activator, target)
    for k, v in ipairs(target or {activator}) do if not userself(activator, v) then v:GodDisable() else return end end
    LFAdmin.LogPlayer(true, activator, " забрал бессмертие ", target or "#самому себе")
end)

LFAdmin.Command({"hp", "health", "sethp", "sethealth"}, "a", {"players", "number"}, function(activator, target, num)
    for k, v in ipairs(target) do v:SetHealth(num) end
    LFAdmin.LogPlayer(true, activator, " установил здоровье ", target, " на ", num)
end)

LFAdmin.Command("freeze", "t", {"players"}, function(activator, target)
    for k, v in ipairs(target) do v:Lock() v.LFAFREEZE = true end
    LFAdmin.LogPlayer(false, activator, " заморозил ", target)
end)

LFAdmin.Command("unfreeze", "t", {"players"}, function(activator, target)
    for k, v in ipairs(target) do v:UnLock() v.LFAFREEZE = false end
    LFAdmin.LogPlayer(false, activator, " разморозил ", target)
end)

LFAdmin.Command("setmodel", "s", {"players", "string"}, function(activator, target, model)
    for k, v in ipairs(target) do v:SetModel(model) end
    LFAdmin.LogPlayer(false, activator, " установил модель ", target, " на ", "#" .. model)
end)

LFAdmin.Command("strip", "v", {"players?"}, function(activator, target)
    for k, v in ipairs(target or {activator}) do if not userself(activator, v) then v:StripWeapons() else return end end
    LFAdmin.LogPlayer(false, activator, " забрал оружие у ", target)
end)

LFAdmin.Command({"slay", "kill"}, "v", {"players?"}, function(activator, target)
    for k, v in ipairs(target or {activator}) do if not userself(activator, v) then v:Kill() else return end end
    LFAdmin.LogPlayer(false, activator, " убил ", target)
end)

LFAdmin.Command({"forcerespawn", "respawn", "spawn"}, "v", {"players?"}, function(activator, target)
    if #target == 1 and target[1]:IsPlayerFrozen() then return end
    for k, v in ipairs(target or {activator}) do if not userself(activator, v) and not v:IsPlayerFrozen() then v:KillSilent() v:Spawn() else return end end
    LFAdmin.LogPlayer(false, activator, " зареспавнил ", target)
end)

LFAdmin.Command("fakeban", "s", {"steamid", "time", "string"}, function(activator, target, duration, reason)
    local time = duration.time local perma = time ~= 0
    LFAdmin.LogPlayer(NULL, activator, " зафейкбанил ", target, perma and " на " or "# навсегда", perma and ("#" .. duration.raw) or "", ": ", "#" .. reason)
    LFAdmin.LogPlayer(true, activator, " забанил ", target, perma and " на " or "# навсегда", perma and ("#" .. duration.raw) or "", ": ", "#" .. reason)
end)

LFAdmin.Command("slap", "m", {"players"}, function(activator, target)
    for k, v in ipairs(target) do v:ExitVehicle() v:SetVelocity(Vector(math.random(500), math.random(500), math.random(250, 500))) v:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(4) .. ".wav") end
    LFAdmin.LogPlayer(true, activator, " шлёпнул ", target)
end)

LFAdmin.Command("whip", "m", {"players", "number"}, function(activator, target, num)
    for k, v in ipairs(target) do
        local n = "LFAdmin.Whip:" .. tostring(v)
        timer.Create(n, 0, num, function()
            if not IsValid(v) or not v:Alive() then return timer.Remove(n) end
            timer.Adjust(n, .5)
            v:ExitVehicle()
            v:SetVelocity(Vector(math.random(500), math.random(500), math.random(250, 500)))
            v:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(4) .. ".wav")
        end)
    end
    LFAdmin.LogPlayer(true, activator, " шлёпнул ", target, " ", num, " раз")
end)

LFAdmin.CommandDescription("god", "Включает режим бессмертия цели")
LFAdmin.CommandDescription("ungod", "Выключает режим бессмертия цели")
LFAdmin.CommandDescription("hp", "Устанавливает здоровье цели")
LFAdmin.CommandDescription("freeze", "Замораживает цель")
LFAdmin.CommandDescription("unfreeze", "Размораживает цель")
LFAdmin.CommandDescription("strip", "Забирает все оружие у цели")
LFAdmin.CommandDescription("fakeban", "Банит цель понарошку")
LFAdmin.CommandDescription("setmodel", "Устанавливает модель цели")