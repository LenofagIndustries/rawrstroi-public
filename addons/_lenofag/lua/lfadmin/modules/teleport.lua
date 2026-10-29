--local isconsole = LFAdmin.IsConsole
local isconsole = function(ply) return not IsValid(ply) or not ply:IsPlayer() end

local teleport = function(ply, to)
    to = type(to) == "Player" and (to:GetPos() + Vector(math.random(-200, 200), math.random(-200, 200), 0)) or to
    if not ply:Alive() then ply:Spawn() end
    if ply:InVehicle() then ply:ExitVehicle() end
    ply.LFADMINPREV = ply:GetPos() ply:SetPos(to)
end

LFAdmin.Command("goto", "u", {"player"}, function(activator, target)
    if isconsole(activator) then return end
    if activator:IsPlayerFrozen() then return end
    if target.LFABLOCKGOTO and (activator:GetUserGroup() == "user" or not activator:CanTarget(target)) then return LFAdmin.LogPlayer(activator, target, " запретил к себе телепортироваться") end
    teleport(activator, target)
    LFAdmin.LogPlayer(true, activator, " телепортировался к ", target)
end).SkipAccessCheck = true

LFAdmin.Command("bring", "t", {"players"}, function(activator, target)
    if isconsole(activator) then return end
    if #target == 1 and target[1]:IsPlayerFrozen() then return end
    for k, v in ipairs(target) do
        if v == activator or v:IsPlayerFrozen() then continue end
        teleport(v, activator)
    end
    LFAdmin.LogPlayer(true, activator, " телепортировал " , target, " к себе")
end)

LFAdmin.Command({"tp", "tele", "teleport"}, "u", {"player?"}, function(activator, target)
    if not target then target = activator elseif not activator:HasAccess("t") then return end
    if isconsole(target) then return end
    if target:IsPlayerFrozen() then return end
    teleport(target, activator:GetEyeTrace().HitPos)
    if target ~= activator then LFAdmin.LogPlayer(true, activator, " телепортировал ", target) end
end)

LFAdmin.Command("send", "a", {"player", "player"}, function(activator, from, to)
    if isconsole(activator) then return end
    if from:IsPlayerFrozen() or to:IsPlayerFrozen() then return end
    teleport(from, to)
    LFAdmin.LogPlayer(true, activator, " телепортировал ", from, " к ", to)
end)

LFAdmin.Command("return", "u", {"player?"}, function(activator, target)
    if isconsole(activator) and not target then return LFAdmin.Log("return ur mom lol XD") end
    if not target then target = activator end
    if not target.LFADMINPREV then return LFAdmin.LogPlayer(activator, target, " не имеет предыдущих позиций!") end
    if not isconsole(activator) and activator ~= target and not activator:HasAccess("t") and activator:CanTarget(target) or target:IsPlayerFrozen() then return end
    target:SetPos(target.LFADMINPREV) target.LFADMINPREV = nil
    LFAdmin.LogPlayer(true, activator, " вернул ", target, " на предыдущую позицию")
end)

LFAdmin.Command("blockgoto", "u", {}, function(activator)
    activator.LFABLOCKGOTO = not activator.LFABLOCKGOTO
    LFAdmin.LogPlayer(activator, "Вы ", activator.LFABLOCKGOTO and "#запретили" or "#разрешили", " другим игрокам телепортироваться к вам")
end)

LFAdmin.Command("maps", "u", {}, function(activator)
    LFAdmin.LogPlayer(activator, "Все доступные для смены карты:")
    for k, v in ipairs(gmlfi.rtv.maps) do
        LFAdmin.LogPlayer(activator, k .. ": ", "#" .. v)
    end
end)

LFAdmin.Command("map", "s", {"string"}, function(activator, map)
    local f for _, v in ipairs(gmlfi.rtv.maps) do if v == map then f = true break end end
    if not f then return LFAdmin.LogPlayer(activator, "Карта \"", "#" .. map, "\" не найдена или недоступна") end
    LFAdmin.LogPlayer(true, activator, " меняет карту на \"", "#" .. map, "\"")
    RunConsoleCommand("changelevel", map)
end)

LFAdmin.CommandDescription("goto", "Телепортирует Вас к цели")
LFAdmin.CommandDescription("bring", "Телепортирует цель к Вам")
LFAdmin.CommandDescription("tp", "Телепортирует цель на курсор")
LFAdmin.CommandDescription("send", "Телепортирует цель к другому игроку")
LFAdmin.CommandDescription("return", "Возвращает цель на предыдущую позицию")
LFAdmin.CommandDescription("blockgoto", "Переключает запрет телепортации к себе")
LFAdmin.CommandDescription("maps", "Выдает список доступных карт")
LFAdmin.CommandDescription("map", "Устанавливает карту сервера на выданную")