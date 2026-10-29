if SERVER then
    util.AddNetworkString("LFI:ULX.ClearDecales")
end

if CLIENT then
    net.Receive("LFI:ULX.ClearDecales", function()
        game.CleanUpMap()
        game.RemoveRagdolls()
    end)
end

LFAdmin.Command("decals", "v", {}, function(activator)
    game.RemoveRagdolls()
    net.Start("LFI:ULX.ClearDecales")
    net.Broadcast()
    for k, v in ipairs(ents.FindByClass("weapon_*")) do if v and IsValid(v) and not v.Owner or not IsValid(v.Owner) then v:Remove() end end
    LFAdmin.LogPlayer(true, activator, " очистил декали")
end)

LFAdmin.Command("freezeall", "*", {}, function(activator)
    for _, ent in ipairs(ents.GetAll()) do
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:Sleep()
        end
    end
    LFAdmin.LogPlayer(true, activator, " заморозил все объекты")
end)

LFAdmin.Command("cleanmap", "*", {}, function(activator)
    game.CleanUpMap()
    LFAdmin.LogPlayer(true, activator, " очистил карту")
end)

LFAdmin.Command("cleanup", "a", {"player"}, function(activator, target)
    if not target.CPPIGetOwner then return LFAdmin.LogPlayer(activator, "Ошибка: CPPI функции не существуют", true) end
    for _, ent in ipairs(ents.GetAll()) do
        if ent:CPPIGetOwner() == target then ent:Remove() end
    end
    LFAdmin.LogPlayer(true, activator, " очистил пропы ", target)
end)

LFAdmin.Command("kickbots", "*", {}, function(activator)
    if #player.GetBots() == 0 then return LFAdmin.LogPlayer(activator, "На сервере нет ботов!") end
    for _, v in ipairs(player.GetBots()) do v:Kick("Kicked using lf kickbots!") end
    LFAdmin.LogPlayer(true, activator, " кикнул всех ботов")
end)

LFAdmin.Command("screenshot", "a", {"players"}, function(activator, target)
    for _, ply in ipairs(target) do
        LSS.Screenshot(ply, activator, true)
    end
    LFAdmin.LogPlayer(false, activator, " запросил скриншот ", target)
    -- LFAdmin.LogPlayer(activator, "Вероятно, сейчас функция скриншота не работает, так как наш хостинг-провайдер отключил всем на нашем тарифе NodeJS и прочие скрипты")
end)

LFAdmin.Command({"adminmode", "am", "admin"}, "m", {}, function(activator)
    if IsValid(activator) then
        LFAdmin.LogPlayer(false, activator, " ", "#" .. (activator:ToggleAdminMode() and "включил" or "выключил"), " режим администратора")
    end
end)

local RTV_COOLDOWN = 30 * 60
local RTV_COOLDOWN_CHANGELEVEL = 30 * 60

gmlfi.rtv.Cooldown = gmlfi.rtv.Cooldown or (CurTime() + RTV_COOLDOWN_CHANGELEVEL)
LFAdmin.Command({"rtv", "nominate", "votemap"}, "u", {}, function(activator)
    if not gmlfi.rtv.started and gmlfi.rtv.Cooldown and gmlfi.rtv.Cooldown > CurTime() and IsValid(activator) and not activator:IsRamzi() then return LFAdmin.LogPlayer(activator, "Следующее голосование за карту будет доступно через ", ("#" .. math.floor(gmlfi.rtv.Cooldown - CurTime())), " секунд") end
    if gmlfi.rtv.Start() ~= false then LFAdmin.LogPlayer(true, activator, " начал голосование за карту, используйте команду ", "#!rtv", " для голосования") gmlfi.rtv.Cooldown = CurTime() + RTV_COOLDOWN gmlfi.rtv.Open(activator) else gmlfi.rtv.Open(activator) end
end)

LFAdmin.Command("stoprtv", "a", {}, function(activator)
    if gmlfi.rtv.Stop() ~= false then LFAdmin.LogPlayer(true, activator, " остановил голосование за карту") else LFAdmin.LogPlayer(activator, "Голосование за карту не начато!") end
end)

LFAdmin.Command("skiprtv", "m", {}, function(activator)
    gmlfi.rtv.Cooldown = CurTime()
    LFAdmin.LogPlayer(false, activator, " сбросил кулдаун голосования за карту")
end)

LFAdmin.Command("restart", "*", {"number"}, function(activator, time)
    gmlfi.restart.Schedule(time)
    LFAdmin.LogPlayer(true, activator, " запланировал рестарт через ", time, " секунд")
end)

LFAdmin.Command("stoprestart", "*", {}, function(activator)
    gmlfi.restart.Stop()
    LFAdmin.LogPlayer(true, activator, " отменил рестарт")
end)

LFAdmin.Command("afk", "u", {}, function(activator)
    if not IsValid(activator) then return end
    gmlfi.antiafk.Set(activator, true)
    gmlfi.antiafk.Announce(activator, false)
    LFAdmin.LogPlayer(NULL, activator, " ушел в AFK")
end)

LFAdmin.Command("status", "u", {"string?"}, function(activator, text)
    if not IsValid(activator) then return end
    gmlfi.status.Set(activator, text)
    local new = activator:GetNetVar("UserStatus")
    if new then
        LFAdmin.LogPlayer(activator, "Вы поменяли свой статус на \"", "#" .. new, "\"")
    else LFAdmin.LogPlayer(activator, "Вы ", "#сбросили", " свой статус") end
end)

LFAdmin.Command("hide", "*", {}, function(activator) --idk where to put this -- dw i know a place
    local name = "(Неизвестно)"--gmlfi.RandomName()
    local hid = not activator:GetNWBool("LFI:Hide", false)

    if hid then
        net.Start("LFI:Connect")
        net.WriteString("disconnect")
        net.WriteString(activator:Name())
        net.WriteString("ok")
        net.WriteUInt(activator:Team(), 12)
        net.Broadcast()
    end

    activator:SetNWBool("LFI:Hide", hid)
    activator:SetTeam(hid and LFAdmin.Groups.Stored["user"].Team or activator:GetRank().Team)
    activator:SetAdminMode(hid)
    activator:SetNetVar("CustomName", hid and name or nil)
    if MDispatcher and MDispatcher.RefreshDispatcherName then MDispatcher.RefreshDispatcherName(activator) end

    LFAdmin.LogPlayer(activator, "Вы ", "#" .. (hid and "включили" or "выключили"), " режим скрытия")
end) --hai i wuv u

LFAdmin.Command("zen", "*", {}, function(activator) --mute chat, voice and fix trains not disappearing probably because of csents hz when though
    activator.ZENMODE = not activator.ZENMODE
    activator:SetNW2Bool("ZENMODE", activator.ZENMODE)
    if activator.ZENMODE then gmlfi.zen.filter:AddPlayer(activator) else gmlfi.zen.filter:RemovePlayer(activator) end

    local t = gmlfi.zen.entfilter()

    for _,v in ipairs(t) do
        gmlfi.zen.spt(v, activator, activator.ZENMODE)
    end

    LFAdmin.LogPlayer(activator, "девайс из " .. (activator.ZENMODE and "офлайн..........." or "онлайн....."))
end, function(activator)
    local t = player.GetAll()

    for _,v in ipairs(t) do
        if IsValid(v) then v:SetPos(Vector(-60000,0,-60000)) end
    end
end)

LFAdmin.CommandDescription("decals", "Очистить декали")
LFAdmin.CommandDescription("freezeall", "Замораживает все энтити")
LFAdmin.CommandDescription("cleanmap", "Очищает карту")
LFAdmin.CommandDescription("cleanup", "Очищает все энтити игрока")
LFAdmin.CommandDescription("kickbots", "Кикает всех ботов")
LFAdmin.CommandDescription("screenshot", "Скриншотит цель")
LFAdmin.CommandDescription("adminmode", "Переключает режим администратора")
LFAdmin.CommandDescription("rtv", "Запускает голосование за смену карты")
LFAdmin.CommandDescription("stoprtv", "Останавливает голосование за смену карты")
LFAdmin.CommandDescription("restart", "Планирует рестарт")
LFAdmin.CommandDescription("stoprestart", "Отменяет рестарт")
LFAdmin.CommandDescription("hide", "Переключает режим скрытия")
LFAdmin.CommandDescription("zen", "Переключает режим дзена")