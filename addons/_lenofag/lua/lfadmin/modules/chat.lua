LFAdmin.Command({"psay", "pm"}, "u", {"player", "string"}, function(ply, target, text)
    if ply.LFAMUTED then return end
    LFAdmin.LogPlayerPrefixed(ply, "pm", "#Вы", " -> ", target, ": ", text)
    LFAdmin.LogPlayerPrefixed(target, "pm", ply, " -> ", "#Вам", ": ", text)
    if IsValid(ply) and IsValid(target) then LFAdmin.LogPlayer(NULL, ply, " -> ", target, ": ", text) end
end).SkipAccessCheck = true

LFAdmin.Command("asay", "u", {"string"}, function(ply, text)
    if ply.LFAMUTED then return end
    LFAdmin.LogPlayerPrefixed(false, "asay", ply, ": ", text)
    if IsValid(ply) and not ply:IsStaff() then LFAdmin.LogPlayer(ply, "#Вы", " написали в админ-чат: ", text) end
end)

LFAdmin.Command("vote", "v", {"string", "string", "string", "string?", "string?", "string?"}, function(activator, subject, ...)
    if activator.LFAMUTED then return end
    if LFAdmin.GetSteamIDTimedVar(activator, "LFABANVOTED") then return LFAdmin.LogPlayer(activator, "Вам временно запретили начинать голосования") end
    local vv = {...}
	if gmlfi.votes.Start(subject, activator, vv) == false then LFAdmin.LogPlayer(activator, "Сейчас проходит другое голосование!")
	else
		LFAdmin.LogPlayer(false, activator, " начал голосование \"", "#" .. subject, "\" с вариантами: ", "#" .. table.concat(vv, ", "))
	end 
end)

LFAdmin.Command("stopvote", "t", {}, function(activator)
    if not gmlfi.votes.active then LFAdmin.LogPlayer(activator, "Голосование сейчас не проводится")
	else gmlfi.votes.Stop() LFAdmin.LogPlayer(true, activator, " остановил текущее голосование") end
end)

LFAdmin.Command("banvote", "t", {"steamid", "time"}, function(activator, target, time)
    local inf = time.time == 0
    LFAdmin.SetSteamIDTimedVar(target, "LFABANVOTED", inf and true or time.time)
    LFAdmin.LogPlayer(true, activator, " запретил ", target, " начинать голосования на ", "#" .. (inf and "всю игровую сессию" or time.raw))
end)

if gmlfi.radio then
    LFAdmin.Command({"radio", "r"}, "u", {"string"}, function(activator, text)
        if activator.LFAMUTED then return end
        local ch = activator.LFRadio or "default"
        LFAdmin.LogPlayerPrefixed(gmlfi.radio.GetMembers(ch), "radio", activator, ": ", text)
        if not (gmlfi.radio.secrets or {})[ch] then LFAdmin.LogPlayer(NULL, activator, " по рации канала ", "#" .. ch,  ": ", text) end
    end)
end

LFAdmin.Command({"local", "l"}, "u", {"string"}, function(activator, text)
    if activator.LFAMUTED then return end
    local targets = {}
    local pos = activator:GetPos()
    for k, v in ipairs(player.GetAll()) do if v:GetPos():DistToSqr(pos) < 250000 then targets[#targets + 1] = v end end
    LFAdmin.LogPlayerPrefixed(targets, "local", activator, ": ", text)
    LFAdmin.LogPlayer(NULL, activator, " локально: ", text)
end)

LFAdmin.Command("me", "u", {"string"}, function(activator, text)
    LFAdmin.LogPlayerPrefixed(true, "me", activator, "# " .. text)
end)

LFAdmin.Command("forcenotify", "m", {"number"}, function(activator, n)
    BroadcastLua("gmlfi.SendNotify(" .. tonumber(n) .. ")")
    LFAdmin.LogPlayer(true, activator, " отправил всем напоминание №", n)
end)

LFAdmin.Command("t", "t", {"players", "string"}, function(activator, target, text)
    gmlfi.request.Notify(target, "Администратор отправил вам уведомление: \"" .. text .. "\"")
    LFAdmin.LogPlayer(false, activator, " отправил ", target, " уведомление на экран: \"", text, "\"")
end)

hook.Add("PlayerSay", "LFAdmin.Chat", function(ply, text)
    if not ply.LFAMUTED and string.sub(text, 1, 1) == "@" then
        text = string.Trim(string.sub(text, 2))
        if text ~= "" then LFAdmin.Commands["asay"].callback(ply, text) return "" end
    end
end)

LFAdmin.CommandDescription("psay", "Отправляет цели сообщение")
LFAdmin.CommandDescription("asay", "Отправляет сообщение в админ-чат")
LFAdmin.CommandDescription("vote", "Начинает голосование с выданным названием и вариантами выбора")
LFAdmin.CommandDescription("stopvote", "Останавливает текущее голосование")
LFAdmin.CommandDescription("banvote", "Запрещает цели начинать голосования")
LFAdmin.CommandDescription("radio", "Отправляет сообщение всем игрокам на радио-канале")
LFAdmin.CommandDescription("local", "Отправляет сообщение игрокам в радиусе 500 юнитов")
LFAdmin.CommandDescription("t", "Отправляет цели уведомление на экран")
