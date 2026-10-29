local unwarn = function(target)
    if not Either(IsValid(target), IsValid(target) and target:IsStaff(), LFAdmin.Groups.Stored[LFAdmin.GetDBUser(target) or "user"]:IsStaff()) then
        sql.Query("DELETE FROM lfadmin_warns WHERE sid64 = " .. SQLStr(LFAdmin.GetSteamID(target, true)))
    end
end
LFAdmin.Command("ban", "t", {"steamid", "time", "string"}, function(activator, target, duration, reason)
    -- if LFAdmin.GetBan(target) then LFAdmin.LogPlayer(activator, target, " уже забанен")
    -- else
        local time = duration.time local perma = time ~= 0
        local maxban = not LFAdmin.IsConsole(activator) and activator:GetRank().MaxBan if maxban and (not perma or time > maxban) then return LFAdmin.LogPlayer(activator, "Максимальный срок бана для вашего ранга: ", "#" .. string.NiceTime(maxban)) end
        LFAdmin.LogPlayer(true, activator, LFAdmin.GetBan(target) and " перебанил " or " забанил ", target, perma and " на " or "# навсегда", perma and ("#" .. duration.raw) or "", ": ", "#" .. reason)
        LFAdmin.Ban(target, activator, reason, time)
        unwarn(target)
    -- end
end)

LFAdmin.Command("unban", "m", {"steamid", "string?"}, function(activator, target, reason)
    local sid64 = LFAdmin.GetSteamID(target, true)
    local ban = LFAdmin.GetBan(sid64)
    if not ban then LFAdmin.LogPlayer(activator, target, " не забанен")
    else
        if not LFAdmin.IsConsole(activator) and not activator:HasAccess("s") and (ban.adminsid ~= activator:SteamID64() or os.time() - ban.time > 3600) then
            LFAdmin.LogPlayer(NULL, activator, " попытался разбанить ", target, reason and ": " or "", reason and ("#" .. reason) or "")
            return LFAdmin.LogPlayer(activator, "Вам недоступен разбан игроков, которых забанили не вы, или игроков, которые забанены вами уже больше часа")
        end
        LFAdmin.LogPlayer(true, activator, " разбанил ", target, reason and ": " or "", reason and ("#" .. reason) or "")
        LFAdmin.Unban(sid64)
    end
end)

LFAdmin.Command("bans", "t", {"steamid"}, function(activator, target)
    local data = sql.Query("SELECT admin, reason, duration, time FROM lfadmin_bans WHERE sid64 = " .. SQLStr(LFAdmin.GetSteamID(target, true)) .. " ORDER BY time DESC")
    if not data then return LFAdmin.LogPlayer(activator, target, " не имеет данных о банах") end
    LFAdmin.LogPlayer(activator, "Баны игрока ", target, ":")
    for k, v in ipairs(data) do
        local tt = tonumber(v.duration)
        LFAdmin.LogPlayer(activator, "#" .. os.date("%X %d.%m.%Y", v.time), ": \"", "#" .. v.reason, tt == 0 and "\" " or "\" на ", "#" .. (tt and (tt == 0 and "навсегда" or LFAdmin.FormatTime(tt - v.time)) or "(неизвестно)"), " от ", "#" .. (LFAdmin.GetSteamID(v.admin) or "Консоль"))
    end
end)

local unjail

LFAdmin.Command("kick", "t", {"player", "string?"}, function(activator, target, reason)
    local iv = IsValid(target)
    LFAdmin.LogPlayer(true, activator, " кикнул ", target, reason and (": \"" .. reason .. "\"") or "")
    local r = string.format(LFAdmin.Config.kickmessage, LFAdmin.IsConsole(activator) and "Консоль" or activator:Name(), reason or "[не указана]")
    if IsValid(target) then
        unjail(target)
        target:Kick(r)
    else game.KickID(target, r) end
end)

LFAdmin.Command("voteban", "v", {"player", "time", "string"}, function(activator, target, duration, reason)
    if (activator:IsVIP() and #LFAdmin.GetStaff() > 0) or LFAdmin.GetSteamIDTimedVar(activator, "LFABANVOTED") then return LFAdmin.LogPlayer(activator, "Вам временно запретили начинать голосования") end
    local time = duration.time local perma = time ~= 0
    if not perma and not activator:HasAccess("s") then return LFAdmin.LogPlayer(activator, "\"", "#voteban", "\" навсегда разрешен только с флагом \"", "#s", "\"") end
	local sid = target:SteamID()
    if gmlfi.votes.Start(
		"Забанить игрока " .. target:Name() .. (perma and (" на " .. duration.raw) or " навсегда") .. "?",
		activator, {"Да", "Нет"}, function(ok, winner)
			if ok and winner == "Да" then
                if not IsValid(target) then target = sid end
                LFAdmin.LogPlayer(true, "#(По результату голосования) ", activator, LFAdmin.GetBan(target) and " перебанил " or " забанил ", target, perma and " на " or "# навсегда", perma and ("#" .. duration.raw) or "", ": ", "#" .. reason)
                LFAdmin.Ban(target, activator, reason, time)
			end
		end) == false then LFAdmin.LogPlayer(activator, "Сейчас проходит другое голосование!")
	else
		LFAdmin.LogPlayer(true, activator, " начал голосование за бан ", target, perma and " на " or "# навсегда", perma and ("#" .. duration.raw) or "", ": ", "#" .. reason)
		gmlfi.votes.active.IsDispKick = true
	end
end)

LFAdmin.Command("votekick", "v", {"player", "string"}, function(activator, target, reason)
    if (activator:IsVIP() and #LFAdmin.GetStaff() > 0) or LFAdmin.GetSteamIDTimedVar(activator, "LFABANVOTED") then return LFAdmin.LogPlayer(activator, "Вам временно запретили начинать голосования") end
	local sid = target:SteamID()
    if gmlfi.votes.Start(
		"Кикнуть игрока " .. target:Name() .. "?",
		activator, {"Да", "Нет"}, function(ok, winner)
			if ok and winner == "Да" then
                if not IsValid(target) then target = sid end
                LFAdmin.LogPlayer(true, "#(По результату голосования) ", activator, " кикнул ", target, ": ", "#" .. reason)
                local r = string.format(LFAdmin.Config.kickmessage, activator:Name(), reason)
                if IsValid(target) then
                    unjail(target)
                    target:Kick(r)
                else game.KickID(target, r) end
			end
		end) == false then LFAdmin.LogPlayer(activator, "Сейчас проходит другое голосование!")
	else
		LFAdmin.LogPlayer(true, activator, " начал голосование за кик ", target, ": ", "#" .. reason)
		gmlfi.votes.active.IsDispKick = true
	end
end)

LFAdmin.Command("mute", "t", {"steamid", "time", "string?"}, function(activator, target, time, reason)
    local inf = time.time == 0
    LFAdmin.LogPlayer(true, activator, " замутил ", target, " на ", "#" .. (inf and "всю игровую сессию" or time.raw), ": ", "#" .. (reason or "(причина не указана)"))
    LFAdmin.SetSteamIDTimedVar(target, "LFAMUTED", inf and true or time.time)
end)

LFAdmin.Command("gag", "t", {"steamid", "time", "string?"}, function(activator, target, time, reason)
    local inf = time.time == 0
    LFAdmin.LogPlayer(true, activator, " гагнул ", target, " на ", "#" .. (inf and "всю игровую сессию" or time.raw), ": ", "#" .. (reason or "(причина не указана)"))
    LFAdmin.SetSteamIDTimedVar(target, "LFAGAGGED", inf and true or time.time)
end)

LFAdmin.Command("unmute", "t", {"steamid"}, function(activator, target)
    LFAdmin.LogPlayer(true, activator, " размутил ", target)
    LFAdmin.SetSteamIDTimedVar(target, "LFAMUTED", false)
end)

LFAdmin.Command("ungag", "t", {"steamid"}, function(activator, target)
    LFAdmin.LogPlayer(true, activator, " разгагал ", target)
    LFAdmin.SetSteamIDTimedVar(target, "LFAGAGGED", false)
end)

LFAdmin.Command("pgag", "a", {"steamid", "string?"}, function(activator, target, reason)
    local succ, err = gmlfi.pgm.PGag(IsValid(target) and target or LFAdmin.GetSteamID(target, true), activator, reason)
    if not succ then return LFAdmin.LogPlayer(activator, err or "PMuteGag вызвал ошибку SQL, обратитесь к системному администратору") end
    LFAdmin.LogPlayer(true, activator, " выдал перманентный гаг ", target, ": ", "#" .. (reason or "(причина не указана)"))
end)

LFAdmin.Command("pmute", "a", {"steamid", "string?"}, function(activator, target, reason)
    local succ, err = gmlfi.pgm.PMute(IsValid(target) and target or LFAdmin.GetSteamID(target, true), activator, reason)
    if not succ then return LFAdmin.LogPlayer(activator, err or "PMuteGag вызвал ошибку SQL, обратитесь к системному администратору") end
    LFAdmin.LogPlayer(true, activator, " выдал перманентный мут ", target, ": ", "#" .. (reason or "(причина не указана)"))
end)

LFAdmin.Command("unpgag", "a", {"steamid"}, function(activator, target)
    local succ, err = gmlfi.pgm.UnPGag(IsValid(target) and target or LFAdmin.GetSteamID(target, true))
    if not succ then return LFAdmin.LogPlayer(activator, err or "PMuteGag вызвал ошибку SQL, обратитесь к системному администратору") end
    LFAdmin.LogPlayer(true, activator, " снял перманентный гаг с ", target)
end)

LFAdmin.Command("unpmute", "a", {"steamid"}, function(activator, target)
    local succ, err = gmlfi.pgm.UnPMute(IsValid(target) and target or LFAdmin.GetSteamID(target, true))
    if not succ then return LFAdmin.LogPlayer(activator, err or "PMuteGag вызвал ошибку SQL, обратитесь к системному администратору") end
    LFAdmin.LogPlayer(true, activator, " снял перманентный мут с ", target)
end)

unjail = function(target)
    local p = target:GetPos()
    target.LFAJAILED = nil
    target:KillSilent()
    target:Spawn()
    target:SetPos(p)
    if IsValid(target.LFAJAILPROP) then target.LFAJAILPROP:Remove() end
    LFAdmin.LogPlayer(target, "Вы были выпущены из джайла")
end

local jail = function(activator, target, time, pos)
    if target.LFAJAILED then unjail(target) end
    local j = time and (time.time == 0 and true or CurTime() + time.time) or true
    LFAdmin.LogPlayer(true, activator, " заджайлил ", target, j == true and "" or " на ", j == true and "" or ("#" .. time.raw))
    target.LFAJAILED = j
    local pos = activator:GetEyeTrace().HitPos
    target:KillSilent()
    target:Spawn()
    target:StripWeapons()
    if pos then target:SetPos(pos) end
    target:SetMoveType(MOVETYPE_NONE)
    target.LFAJAILEDPos = pos

    local prop = ents.Create("prop_dynamic")
    if prop then
        -- local ob = target:OBBCenter() ob.z = 0
        prop:SetPos(pos + Vector(26, 0, 71))
        prop:SetAngles(Angle(90, 0, 180))
        prop:SetModel("models/props_phx/construct/metal_wire1x1x2b.mdl")
        prop:Spawn()
        target.LFAJAILPROP = prop
    end

    if j ~= true then
        timer.Create("LFAdmin.Jailed:" .. target:EntIndex(), time.time, 1, function()
            unjail(target)
        end)
    end

    unwarn(target)
end

LFAdmin.Command("jail", "t", {"player", "time?"}, jail)
LFAdmin.Command("jailtp", "t", {"player", "time?"}, function(a, b, c) jail(a, b, c, not LFAdmin.IsConsole(a)) end)
LFAdmin.Command("unjail", "t", {"player"}, function(activator, target)
    LFAdmin.LogPlayer(true, activator, " разджайлил ", target)
    unjail(target)
end)

LFAdmin.Command("nameban", "t", {"steamid", "time", "string?"}, function(activator, target, time, reason)
    local inf = time.time == 0
    local n = gmlfi.RandomName()
    LFAdmin.LogPlayer(true, activator, " сгенерировал ", target, " имя (" , "#" .. n, ") и запретил его менять на ", "#" .. (inf and "всю игровую сессию" or time.raw), ": ", "#" .. (reason or "(причина не указана)"))
    LFAdmin.SetSteamIDTimedVar(target, "LFANAMEBAN", inf and true or time.time)
    target:SetNetVar("CustomName", n)
    if MDispatcher and MDispatcher.RefreshDispatcherName then MDispatcher.RefreshDispatcherName(target) end
end)

LFAdmin.Command("unnameban", "t", {"steamid"}, function(activator, target)
    LFAdmin.LogPlayer(true, activator, " разрешил ", target, " менять свое имя")
    LFAdmin.SetSteamIDTimedVar(target, "LFAGAGGED", false)
end)

if SERVER then
    hook.Add("PlayerCanHearPlayersVoice", "LFAdmin.MG", function(_, ply)
        local gagged = LFAdmin.GetSteamIDTimedVar(ply, "LFAGAGGED")
        if gagged and (gagged == true or gagged > CurTime()) then return false, false end
    end)

    local baddie = function(ply) if ply:IsPlayerFrozen() then return false end end
    hook.Add("PlayerSpawnObject", "LFAdmin.Jail", baddie)
    hook.Add("PlayerSpawnSENT", "LFAdmin.Jail", baddie)
    hook.Add("PlayerSpawnVehicle", "LFAdmin.Jail", baddie)
    hook.Add("PlayerSpawnNPC", "LFAdmin.Jail", baddie)
    hook.Add("PlayerSpawnSWEP", "LFAdmin.Jail", baddie)
    hook.Add("PlayerGiveSWEP", "LFAdmin.Jail", baddie)
    hook.Add("CanPlayerSuicide", "LFAdmin.Jail", baddie)
    hook.Add("PlayerNoClip", "LFAdmin.Jail", baddie)
    hook.Add("PlayerSpawn", "LFAdmin.Jail", function(target)
        if target.LFAJAILED then
            timer.Simple(0, function()
                target:SetVelocity(Vector(0, 0, 0))
                target:StripWeapons()
                if target.LFAJAILEDPos then target:SetPos(target.LFAJAILEDPos) end
                target:SetMoveType(MOVETYPE_NONE)
            end)
        end
    end)
    hook.Add("PlayerDisconnected", "LFAdmin.Jail", function(ply)
        if ply.LFAJAILED then
            local time = ply.LFAJAILED == true and 3600 or timer.TimeLeft("LFAdmin.Jailed:" .. ply:EntIndex()) or 60
            timer.Remove("LFAdmin.Jailed:" .. ply:EntIndex())
            if IsValid(ply.LFAJAILPROP) then ply.LFAJAILPROP:Remove() end
            LFAdmin.Ban(ply, nil, "[AUTO] Правило 9 (Попытка обхода jail/jailtp)", time)
        end
    end)

    LFAdmin.Jail, LFAdmin.UnJail = jail, unjail
end


-- mute hook is in ../_main/commands.lua

LFAdmin.CommandDescription("ban", "Банит цель")
LFAdmin.CommandDescription("unban", "Разбанивает цель")
LFAdmin.CommandDescription("bans", "Выдает список банов цели")
LFAdmin.CommandDescription("kick", "Кикает цель")
LFAdmin.CommandDescription("mute", "Мутит цель")
LFAdmin.CommandDescription("gag", "Гагает цель")
LFAdmin.CommandDescription("voteban", "Начинает голосование на бан цели")
LFAdmin.CommandDescription("unmute", "Снимает мут цели")
LFAdmin.CommandDescription("ungag", "Снимает гаг цели")
LFAdmin.CommandDescription("pmute", "Мутит цель навсегда")
LFAdmin.CommandDescription("pgag", "Гагает цель навсегда")
LFAdmin.CommandDescription("unpmute", "Снимает перманентный мут цели")
LFAdmin.CommandDescription("unpgag", "Снимает перманентный гаг цели")
LFAdmin.CommandDescription("jail", "Выдает джайл цели")
LFAdmin.CommandDescription("jailtp", "Выдает джайл цели и телепортирует на курсор")
LFAdmin.CommandDescription("unjail", "Выпускает цель из джайла")
