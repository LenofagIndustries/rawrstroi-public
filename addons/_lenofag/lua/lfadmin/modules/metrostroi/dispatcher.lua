LFAdmin.Command("disp", "u", {}, function(calling_ply)
    MDispatcher.Disp(calling_ply)
end)

LFAdmin.Command("undisp", "u", {}, function(calling_ply)
    MDispatcher.UnDisp(calling_ply)
end)

LFAdmin.Command("dmenu", "u", {}, function(calling_ply)
    MDispatcher.DispatcherMenu(calling_ply)
end)

local wait = 30
local last = -wait
LFAdmin.Command({"getsched", "sget"}, "u", {}, function(calling_ply)
    if last + wait > CurTime() then
		calling_ply:ChatPrint("Пожалуйста, подождите еще "..math.Round(last + wait - CurTime()).." секунд(ы), перед запросом расписания!")
        return
    end
    last = CurTime()
	MDispatcher.GetSchedule(calling_ply)
end)

LFAdmin.Command({"clearsched", "sclear"}, "u", {}, function(calling_ply)
    MDispatcher.ClearSchedule(calling_ply)
end)

LFAdmin.Command({"autosched", "sauto"}, "u", {}, function(calling_ply)
	if calling_ply:GetInfoNum("mdispatcher_autochedule", 0) == 1 then
		calling_ply:ConCommand("mdispatcher_autochedule 0")
		calling_ply:ChatPrint("Автоматическая перевыдача расписания после оборота выключена")
	else
		calling_ply:ConCommand("mdispatcher_autochedule 1")
		calling_ply:ChatPrint("Автоматическая перевыдача расписания после оборота включена")
	end
end)

local undisp = function(target)
	if target:GetNW2Bool("MDispatcher") then
		MDispatcher.UnDisp(target, target)
	end
end

LFAdmin.Command("voteundisp", "u", {"string"}, function(activator, reason)
    if LFAdmin.GetSteamIDTimedVar(activator, "LFABANVOTED") then return LFAdmin.LogPlayer(activator, "Вам временно запретили начинать голосования") end
	local target
	for k, v in ipairs(player.GetAll()) do if v:GetNW2Bool("MDispatcher") then target = v break end end
	if not IsValid(target) then return LFAdmin.LogPlayer(activator, "Диспетчер отсутствует") end
	if gmlfi.votes.Start( -- this syntax is brain melting ik
		"Снять с игрока " .. target:Name() .. " роль Диспетчера?",
		activator, {"Да", "Нет"}, function(ok, winner)
			if ok and winner == "Да" then
				undisp(target)
				LFAdmin.SetSteamIDTimedVar(target, "LFADISPBANNED", 60 * 60)
			end
		end) == false then LFAdmin.LogPlayer(activator, "Сейчас проходит другое голосование!")
	else
		LFAdmin.LogPlayer(true, activator, " начал голосование за снятие диспетчера (", target, ") с поста: \"", "#" .. reason, "\"")
		gmlfi.votes.active.IsDispKick = true
	end
end)

LFAdmin.Command("stopvoteundisp", "m", {}, function(activator)
	if not gmlfi.votes.active or not gmlfi.votes.active.IsDispKick then LFAdmin.LogPlayer(activator, "Голосование за снятие диспетчера сейчас не проводится")
	else gmlfi.votes.Stop() LFAdmin.LogPlayer(true, activator, " остановил голосование за снятие с поста диспетчера") end
end)

LFAdmin.Command("dispban", "m", {"player", "time"}, function(activator, target, time)
	local inf = time.time == 0
	LFAdmin.LogPlayer(true, activator, " запретил ", target, " вставать на пост диспетчера на ", (inf and "всю игровую сессию" or ("#" .. time.raw)))
	undisp(target)
	LFAdmin.SetSteamIDTimedVar(target, "LFADISPBANNED", inf and true or time.time)
end)

LFAdmin.Command("dispunban", "m", {"player"}, function(activator, target)
	local banned = LFAdmin.GetSteamIDTimedVar(target, "LFADISPBANNED")
	if banned then
		LFAdmin.LogPlayer(true, activator, " снял с ", target, " блокировку поста диспетчера")
		LFAdmin.SetSteamIDTimedVar(target, "LFADISPBANNED", false)
	else
		LFAdmin.LogPlayer(activator, "У ", target, " нет блокировки поста диспетчера")
	end
end)

LFAdmin.Command("dispkick", "m", {"player"}, function(activator, target)
	LFAdmin.LogPlayer(true, activator, " снял ", target, " с поста диспетчера")
	undisp(target)
end)

if SERVER then
	hook.Add("PlayerCanDisp", "LFAdmin.Dispatcher", function(ply)
		local banned = LFAdmin.GetSteamIDTimedVar(ply, "LFADISPBANNED")
		if banned then return false, LFAdmin.LogPlayer(ply, "Вам был временно заблокирован доступ к посту диспетчера") end
	end)

	hook.Add("MDispatcher.TookPost", "LFAdmin.Dispatcher", function(_, ply)
		LFAdmin.LogPlayer(true, "<font=Roboto;22>Рекомендуется перейти в канал рации</font> ", "#Диспетчерская", "<font=Roboto;22> в С-меню</font>")
	end)
end

LFAdmin.RegisterAccess("setdisp", "m")

LFAdmin.CommandDescription("disp", "Занимает пост диспетчера")
LFAdmin.CommandDescription("undisp", "Снимает с поста диспетчера")
LFAdmin.CommandDescription("dmenu", "Открывает меню диспетчера")
LFAdmin.CommandDescription("getsched", "Получает расписание")
LFAdmin.CommandDescription("clearsched", "Очищает расписание")
LFAdmin.CommandDescription("autosched", "Переключает авто-перевыдачу расписания")
LFAdmin.CommandDescription("dispkick", "Снимает цель с поста диспетчера")
LFAdmin.CommandDescription("dispban", "Запрещает цели вставать на пост диспетчера")
LFAdmin.CommandDescription("dispunban", "Снимает запрет цели на пост диспетчера")
LFAdmin.CommandDescription("voteundisp", "Начинает голосование на запрет цели встать на пост диспетчера")
LFAdmin.CommandDescription("stopvoteundisp", "Останавливает голосование на запрет цели встать на пост диспетчера")