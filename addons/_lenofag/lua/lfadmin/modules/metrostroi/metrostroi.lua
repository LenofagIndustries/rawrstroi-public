LFAdmin.Command("routes", "u", {}, function(calling_ply)
    if CPPI then
        --local N = {}
        for k,v in pairs(Metrostroi.TrainClasses) do
            if  v == "gmod_subway_base" then continue end
            local ents = ents.FindByClass(v)
            for k2,v2 in pairs(ents) do
                if v2.GetDriverName and v2.RouteNumber then LFAdmin.LogPlayer(calling_ply, "#" .. v2:GetDriverName(), " have a route: ",v2.RouteNumber) else LFAdmin.LogPlayer(calling_ply, "#" .. v2:GetDriverName(), " don't have a route") end
            end
        end
    end
end)

local MAX_TRAINS_ON = 7
local MAX_TRAINS_OFF = 1

LFAdmin.Command("parade", "a", {}, function(ply)
    LFAdmin.ParadeMode = not LFAdmin.ParadeMode
    if LFAdmin.ParadeMode then LFAdmin.LogPlayer(true, "Уважаемые игроки! ", ply, " включил режим Парада. Новые составы смогут спавнить исключительно члены Администрации")
    else LFAdmin.LogPlayer(true, ply, " отключил режим Парада, спавн составов разблокирован") end
    RunConsoleCommand("metrostroi_maxtrains_onplayer", LFAdmin.ParadeMode and MAX_TRAINS_ON or MAX_TRAINS_OFF)
end)

hook.Add("MetrostroiSpawnerRestrict", "LFAdmin.ParadeMode", function(ply)
    if LFAdmin.ParadeMode and not ply:IsStaff() then
        LFAdmin.LogPlayer(ply, "Режим Парада включен, спавн составов разрешен исключительно членам Администрации")
        return true
    end
end)

hook.Add("PlayerSpawnSENT", "LFAdmin.ParadeMode", function(ply)
    if LFAdmin.ParadeMode and not ply:IsStaff() then
        LFAdmin.LogPlayer(ply, "Режим Парада включен, спавн составов разрешен исключительно членам Администрации")
        return false
    end
end)

LFAdmin.CommandDescription("routes", "Выдает список маршрутов")
LFAdmin.CommandDescription("parade", "Включает режим парада, запрещая спавн составов игрокам")