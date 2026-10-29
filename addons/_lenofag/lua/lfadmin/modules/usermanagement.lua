LFAdmin.Command("setgroup", "s", {"steamid", "string", "time?", "string?"}, function(activator, target, group, exp, expto)
    local iv = IsValid(activator) and activator:GetRank()
    if not LFAdmin.Groups.Stored[group] and group ~= LFAdmin.Config.defaultUsergroup then return LFAdmin.LogPlayer(activator, "Группа \"", "#" .. group, "\" не существует") end
    if iv and not iv:CanTarget(group) then return LFAdmin.LogPlayer(activator, "Этот ранг выше вашего!"), LFAdmin.LogPlayer(NULL, activator, " попытался выдать ", target, " группу выше своей (", "#" .. group, ")") end
    if exp and expto then
        if not LFAdmin.Groups.Stored[expto] and expto ~= LFAdmin.Config.defaultUsergroup then return LFAdmin.LogPlayer(activator, "Группа \"", "#" .. expto, "\" не существует") end
        if iv and not iv:CanTarget(expto) then return LFAdmin.LogPlayer(activator, "Этот ранг выше вашего!"), LFAdmin.LogPlayer(NULL, activator, " попытался выдать ", target, " группу выше своей через время (", "#" .. expto, ")") end
    end

    if LFAdmin.Groups.Set(target, group, exp and (os.time() + exp.time), expto) then LFAdmin.LogPlayer(activator, "Игрок уже имеет такую группу")
    else LFAdmin.LogPlayer(true, activator, " установил ", IsValid(target) and target or ("#" .. target), " группу ", "#" .. group, exp and " на " or "", exp and "#" .. exp.raw or "", exp and expto and " (потом " or "", exp and expto and ("#" .. expto) or "", exp and expto and ")" or "") end
end)

LFAdmin.Command("warn", "t", {"steamid", "string"}, function(activator, target, reason)
    local is = IsValid(target) and target:IsStaff() or LFAdmin.Groups.Stored[LFAdmin.GetDBUser(target) or "user"]:IsStaff()
    if IsValid(activator) and is and not activator:HasAccess("s") then return LFAdmin.LogPlayer(activator, IsValid(target) and target or ("#" .. target), " не имеет административного ранга") end
    local c = sql.QueryRow("SELECT COUNT(*) as c FROM lfadmin_warns WHERE sid64=" .. SQLStr(LFAdmin.GetSteamID(target, true)))
    c = (c.c or 0) + 1
    LFAdmin.LogPlayer(not is, activator, " выдал варн ", IsValid(target) and target or ("#" .. target), " (", c, is and "/" or " всего", is and 3 or "", ")", reason and ": \"" or "", reason and "#" .. reason or "", reason and "\"" or "")
    if is and c >= 3 then
        LFAdmin.Groups.Set(target, LFAdmin.Config.defaultUsergroup)
        LFAdmin.LogPlayer(false, IsValid(target) and target or ("#" .. target), " был автоматически снят с ранга за 3 варна")
        if IsValid(target) then LFAdmin.LogPlayer(target, "Вы были автоматически сняты с ранга за 3 варна") end
    else
        local from = LFAdmin.GetSteamID(activator, true)
        sql.Query(string.format("INSERT INTO lfadmin_warns VALUES (%s, %s, %s, %s)", LFAdmin.GetSteamID(target, true), c, SQLStr(reason), from and SQLStr(from) or "NULL"))
    end
end)

LFAdmin.Command("unwarn", "s", {"steamid"}, function(activator, target, reason)
    -- if IsValid(target) and not target:IsStaff() then return LFAdmin.LogPlayer(activator, IsValid(target) and target or ("#" .. target), " не имеет административного ранга") end
    local c = sql.QueryRow("SELECT COUNT(*) as c FROM lfadmin_warns WHERE sid64=" .. SQLStr(LFAdmin.GetSteamID(target, true)))
    c = tonumber(c.c) or 0
    if c <= 0 then return LFAdmin.LogPlayer(activator, IsValid(target) and target or ("#" .. target), " не имеет варнов") end
    sql.Query(string.format("DELETE FROM lfadmin_warns WHERE sid64=%s AND id=%s", LFAdmin.GetSteamID(target, true), c))
    local is = IsValid(target) and target:IsStaff() or LFAdmin.Groups.Stored[LFAdmin.GetDBUser(target) or "user"]:IsStaff()
    LFAdmin.LogPlayer(false, activator, " убрал варн ", IsValid(target) and target or ("#" .. target), " (", c - 1, is and "/" or " всего", is and 3 or "", ")")
end)

LFAdmin.Command("warns", "u", {"steamid"}, function(activator, target)
    local data = sql.Query("SELECT id, reason, giver FROM lfadmin_warns WHERE sid64=" .. SQLStr(LFAdmin.GetSteamID(target, true)) .. " ORDER BY id ASC")
    if not data then return LFAdmin.LogPlayer(activator, IsValid(target) and target or ("#" .. target), " не имеет варнов") end
    LFAdmin.LogPlayer(activator, "Варны игрока ", IsValid(target) and target or ("#" .. target), ":")
    for k, v in ipairs(data) do
        LFAdmin.LogPlayer(activator, v.id, ": ", "#" .. v.reason, " от ", "#" .. (LFAdmin.GetSteamID(v.giver) or "Консоль"))
    end
end).SkipAccessCheck = true

LFAdmin.Command({"bot", "bots"}, "*", {"number?"}, function(activator, num)
    num = num or 1
    if player.GetCount() + num > game.MaxPlayers() then return LFAdmin.LogPlayer(activator, num, " превышает максимальное количество игроков!") end
    game.ConsoleCommand(string.rep("bot", num, ";") .. "\n")
    LFAdmin.LogPlayer(true, activator, " добавил ", num, " ботов на сервер")
end)

LFAdmin.Command({"info", "who"}, "u", {"steamid"}, function(ply, target)
    if IsValid(target) then
        LFAdmin.LogPlayer(ply, "Информация об игроке ", target)
        local cn, rn = target:GetNetVar("CustomName"), LFAdmin.RealNameFunc(target)
        if cn and cn ~= rn then LFAdmin.LogPlayer(ply, "Настоящее имя: ", "#" .. rn) end
        LFAdmin.LogPlayer(ply, "SteamID64: ", "#" .. target:SteamID64())
        LFAdmin.LogPlayer(ply, "EntIndex: ", target:EntIndex())
        local gr = target:GetRank()
        local _, _, grd = LFAdmin.GetDBUser(target)
        LFAdmin.LogPlayer(ply, "Группа: ", "#" .. team.GetName(gr.Team), " (", "#" .. gr.Name, ")")
        if grd and grd.expire then
            LFAdmin.LogPlayer(ply, "• ", "До ", "#" .. os.date("%d.%m.%Y %H:%M:%S", grd.expire), " (потом ", "#" .. grd.expireTo, ")")
        end
        LFAdmin.LogPlayer(ply, "Время игры: ", "#" .. gmlfi.FormatTime(target:GetUTimeTotalTime()))
        local pgag, pmute = gmlfi.pgm.HasPGag(target), gmlfi.pgm.HasPMute(target)
        if pgag then
            local a = not pgag.giver or pgag.giver == "[Console]" or LFAdmin.GetPlayer(pgag.giver)
            LFAdmin.LogPlayer(ply, "Перманентный гаг ", "#" .. os.date("%d.%m.%Y %H:%M:%S", pgag.time))
            LFAdmin.LogPlayer(ply, "• \"", "#" .. (pgag.reason or "(причина неизвестна)"), "\"")
            LFAdmin.LogPlayer(ply, "• От ", LFAdmin.GetSteamID(pgag.giver) or pgag.giver == "[Console]" and NULL or ("#" .. (pgag.giver or NULL)))
        end
        if pmute then
            local a = not pmute.giver or pmute.giver == "[Console]" or LFAdmin.GetPlayer(pmute.giver)
            LFAdmin.LogPlayer(ply, "Перманентный мут ", "#" .. os.date("%d.%m.%Y %H:%M:%S", pmute.time))
            LFAdmin.LogPlayer(ply, "• \"", "#" .. (pmute.reason or "(причина неизвестна)"), "\"")
            LFAdmin.LogPlayer(ply, "• От ", LFAdmin.GetSteamID(pmute.giver) or pmute.giver == "[Console]" and NULL or ("#" .. (pmute.giver or NULL)))
        end
    return end
    local sid, sid64 = LFAdmin.GetSteamID(target), LFAdmin.GetSteamID(target, true)
    local uhdata = (sql.QueryRow("SELECT name, lastjoin FROM gmlfi_UserHistory WHERE sid64=" .. SQLStr(sid64)) or {})
    if uhdata then
        local r, _, grd = LFAdmin.GetDBUser(sid)
        local gr = LFAdmin.Groups.Stored[r or "user"]
        local lj, tt = tonumber(uhdata.lastjoin) or 0
        if sql.TableExists("utime") then
            local a = sql.QueryRow("SELECT totaltime FROM utime WHERE player = " .. SQLStr(sid64))
            if a then tt = tonumber(a.totaltime) or 0 end
        end
        LFAdmin.LogPlayer(ply, "Информация об игроке ", "#" .. (uhdata.name or "(неизвестно)"), " (", "#" .. target, ")")
        LFAdmin.LogPlayer(ply, "SteamID64: ", "#" .. sid64)
        LFAdmin.LogPlayer(ply, "Группа: ", "#" .. team.GetName(gr.Team), " (", "#" .. gr.Name, ")")
        if grd and grd.expire then
            LFAdmin.LogPlayer(ply, "• ", "До ", "#" .. os.date("%d.%m.%Y %H:%M:%S", grd.expire), " (потом ", "#" .. grd.expireTo, ")")
        end
        LFAdmin.LogPlayer(ply, "Время игры: ", "#" .. (tt and gmlfi.FormatTime(tt) or "(неизвестно)"))
        LFAdmin.LogPlayer(ply, "Последний заход: ", "#" .. (lj and os.date("%d.%m.%Y %H:%M:%S", lj) or "(неизвестно)"))
        local ban = LFAdmin.GetBan(sid)
        if ban then
            local a = not ban.adminsid or ban.adminsid == "[Console]" or LFAdmin.GetPlayer(ban.adminsid)
            LFAdmin.LogPlayer(ply, "Блокировка ", "#" .. os.date("%d.%m.%Y %H:%M:%S", ban.time))
            LFAdmin.LogPlayer(ply, "• \"", "#" .. (ban.reason or "(причина неизвестна)"), "\"")
            LFAdmin.LogPlayer(ply, "• От ", a ~= true and IsValid(a) and a or a == true and Entity(0) or ("#" .. ban.admin))
            if ban.duration == 0 then LFAdmin.LogPlayer(ply, "• Перманентная блокировка")
            else LFAdmin.LogPlayer(ply, "• Заканчивается ", "#" .. os.date("%d.%m.%Y %H:%M:%S", ban.duration), " (продолжительность: ", gmlfi.FormatTime(ban.duration - ban.time), ")") end
        end
        local pgag, pmute = gmlfi.pgm.HasPGag(sid64), gmlfi.pgm.HasPMute(sid64)
        if pgag then
            local a = not pgag.giver or pgag.giver == "[Console]" or LFAdmin.GetPlayer(pgag.giver)
            LFAdmin.LogPlayer(ply, "Перманентный гаг ", "#" .. os.date("%d.%m.%Y %H:%M:%S", pgag.time))
            LFAdmin.LogPlayer(ply, "• \"", "#" .. (pgag.reason or "(причина неизвестна)"), "\"")
            LFAdmin.LogPlayer(ply, "• От ", LFAdmin.GetSteamID(pgag.giver) or pgag.giver == "[Console]" and NULL or ("#" .. (pgag.giver or NULL)))
        end
        if pmute then
            local a = not pmute.giver or pmute.giver == "[Console]" or LFAdmin.GetPlayer(pmute.giver)
            LFAdmin.LogPlayer(ply, "Перманентный мут ", "#" .. os.date("%d.%m.%Y %H:%M:%S", pmute.time))
            LFAdmin.LogPlayer(ply, "• \"", "#" .. (pmute.reason or "(причина неизвестна)"), "\"")
            LFAdmin.LogPlayer(ply, "• От ", LFAdmin.GetSteamID(pmute.giver) or pmute.giver == "[Console]" and NULL or ("#" .. (pmute.giver or NULL)))
        end
    else LFAdmin.LogPlayer(ply, "Игрок не найден") end
end).SkipAccessCheck = true

LFAdmin.Command({"viewstaff", "staff"}, "u", {}, function(ply)
    local da
    for k, v in ipairs(LFAdmin.GetStaff()) do
        if not da then da = true LFAdmin.LogPlayer(ply, "Администрация онлайн:") end
        LFAdmin.LogPlayer(ply, v, " (", "#" .. v:GetUserGroup(), ")")
    end
    if not da then LFAdmin.LogPlayer(ply, "Администрация онлайн отсутствует") end

    local t = {} for k, v in pairs(LFAdmin.Groups.Stored) do if v:IsStaff() and not v:IsRamzi() then t[#t +1] = SQLStr(k) end end
    local net = sql.Query("SELECT * FROM lfadmin_users WHERE usergroup = " .. table.concat(t, "OR usergroup = "))

    LFAdmin.LogPlayer(ply, "Состав администрации (" .. #net .. "):")
    for k, v in ipairs(net) do
        LFAdmin.LogPlayer(ply, "#" .. v.name, " (", LFAdmin.GetSteamID(v.sid64), ") (", "#" .. v.usergroup, ")")
    end
end)

LFAdmin.Command({"setplaytime", "settime"}, "*", {"steamid", "time"}, function(activator, target, time)
    if IsValid(target) then
        target:SetUTime(time.time)
    end
    sql.Query("UPDATE utime SET totaltime = ".. math.floor(time.time) .." WHERE player = ".. LFAdmin.GetSteamID(target, true) ..";")
    LFAdmin.LogPlayer(true, activator, " установил время игры ", target, " на ", "#" .. time.raw)
end)

local shit = {9,10,11,12,13,32,127,160,173,847,1564,4447,4448,6068,6069,6155,6156,6157,6158,7355,7356,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8203,8204,8205,8206,8207,8234,8235,8236,8237,8238,8239,8287,8288,8289,8290,8291,8292,8293,8294,8295,8296,8297,8298,8299,8300,8301,8302,8303,10240,12288,12644,65024,65025,65026,65027,65028,65029,65030,65031,65032,65033,65034,65035,65036,65037,65038,65039,65279,65440,65520,65521,65522,65523,65524,65525,65526,65527,65528,65532,78844,119155,119156,119157,119158,119159,119160,119161,119162,917504,917505,917506,917507,917508,917509,917510,917511,917512,917513,917514,917515,917516,917517,917518,917519,917520,917521,917522,917523,917524,917525,917526,917527,917528,917529,917530,917531,917532,917533,917534,917535,917536,917537,917538,917539,917540,917541,917542,917543,917544,917545,917546,917547,917548,917549,917550,917551,917552,917553,917554,917555,917556,917557,917558,917559,917560,917561,917562,917563,917564,917565,917566,917567,917568,917569,917570,917571,917572,917573,917574,917575,917576,917577,917578,917579,917580,917581,917582,917583,917584,917585,917586,917587,917588,917589,917590,917591,917592,917593,917594,917595,917596,917597,917598,917599,917600,917601,917602,917603,917604,917605,917606,917607,917608,917609,917610,917611,917612,917613,917614,917615,917616,917617,917618,917619,917620,917621,917622,917623,917624,917625,917626,917627,917628,917629,917630,917631,917760,917761,917762,917763,917764,917765,917766,917767,917768,917769,917770,917771,917772,917773,917774,917775,917776,917777,917778,917779,917780,917781,917782,917783,917784,917785,917786,917787,917788,917789,917790,917791,917792,917793,917794,917795,917796,917797,917798,917799,917800,917801,917802,917803,917804,917805,917806,917807,917808,917809,917810,917811,917812,917813,917814,917815,917816,917817,917818,917819,917820,917821,917822,917823,917824,917825,917826,917827,917828,917829,917830,917831,917832,917833,917834,917835,917836,917837,917838,917839,917840,917841,917842,917843,917844,917845,917846,917847,917848,917849,917850,917851,917852,917853,917854,917855,917856,917857,917858,917859,917860,917861,917862,917863,917864,917865,917866,917867,917868,917869,917870,917871,917872,917873,917874,917875,917876,917877,917878,917879,917880,917881,917882,917883,917884,917885,917886,917887,917888,917889,917890,917891,917892,917893,917894,917895,917896,917897,917898,917899,917900,917901,917902,917903,917904,917905,917906,917907,917908,917909,917910,917911,917912,917913,917914,917915,917916,917917,917918,917919,917920,917921,917922,917923,917924,917925,917926,917927,917928,917929,917930,917931,917932,917933,917934,917935,917936,917937,917938,917939,917940,917941,917942,917943,917944,917945,917946,917947,917948,917949,917950,917951,917952,917953,917954,917955,917956,917957,917958,917959,917960,917961,917962,917963,917964,917965,917966,917967,917968,917969,917970,917971,917972,917973,917974,917975,917976,917977,917978,917979,917980,917981,917982,917983,917984,917985,917986,917987,917988,917989,917990,917991,917992,917993,917994,917995,917996,917997,917998,917999}
for k, v in ipairs(shit) do shit[k], shit[utf8.char(v)] = nil, "" end
local validate = function(activator, name)
    if not IsValid(activator) --[[or activator:IsSuperAdmin()]] then return true end
    name = string.gsub(string.Trim(name), utf8.charpattern, shit)
    if #name < 4 then return false, LFAdmin.LogPlayer(activator, "Это имя слишком короткое!") end
    if LFAdmin.GetSteamID(name) then return false, LFAdmin.LogPlayer(activator, "SteamID нельзя использовать как имя!") end
    for k, v in ipairs(player.GetAll()) do
        if string.lower(v:Name()) == string.lower(name) then return false, LFAdmin.LogPlayer(activator, "Это имя уже занято ", v) end
    end
    return true
end
LFAdmin.Command({"name", "rpname", "nick"}, "u", {"string"}, function(activator, name)
    if not IsValid(activator) or not validate(activator, name) then return end
    if LFAdmin.GetSteamIDTimedVar(activator, "LFANAMEBAN") then return LFAdmin.LogPlayer(activator, "Вам запретили менять никнейм!") end
    name = utf8.sub(string.Trim(name), 1, 36)
    if activator:SteamID64()=="76561199574278723" then name = "АЛЕКСАНДРА" end
    LFAdmin.LogPlayer(true, activator, " сменил своё локальное имя на ", "#" .. name)
    activator:SetNetVar("CustomName", name)
    if MDispatcher and MDispatcher.RefreshDispatcherName then MDispatcher.RefreshDispatcherName(activator) end
end)

LFAdmin.Command({"randomname", "rname"}, "u", {}, function(activator)
    if not IsValid(activator) then return end
    local name = gmlfi.RandomName()
    LFAdmin.LogPlayer(true, activator, " сменил своё локальное имя на ", "#" .. name, " (случайное)")
    activator:SetNetVar("CustomName", name)
    if MDispatcher and MDispatcher.RefreshDispatcherName then MDispatcher.RefreshDispatcherName(activator) end
end)

LFAdmin.Command("setname", "m", {"player", "string"}, function(activator, target, name)
    if not validate(activator, name) then return end
    name = utf8.sub(name, 1, 36)
    LFAdmin.LogPlayer(true, activator, " сменил локальное имя ", target, "  на ", "#" .. name)
    target:SetNetVar("CustomName", name)
    if MDispatcher and MDispatcher.RefreshDispatcherName then MDispatcher.RefreshDispatcherName(target) end
end)

LFAdmin.Command({"clearname", "resetname"}, "u", {"player?"}, function(activator, target)
    if LFAdmin.GetSteamIDTimedVar(activator, "LFANAMEBAN") then return LFAdmin.LogPlayer(activator, "Вам запретили менять никнейм!") end
    if not IsValid(target) then target = activator end
    if IsValid(activator) and activator ~= target and not activator:HasAccess("t") then return LFAdmin.LogPlayer(activator, "Использование этой команды на других игроков доступно только администрации") end
    LFAdmin.LogPlayer(true, activator, " сбросил локальное имя ", target)
    target:SetNetVar("CustomName")
    if MDispatcher and MDispatcher.RefreshDispatcherName then MDispatcher.RefreshDispatcherName(target) end
end)

LFAdmin.Command({"faketeam", "ft"}, "a", {"string", "players?"}, function(activator, group, target)
    if not IsValid(activator) then return end
    local iv, to = activator:GetRank()
    local rank = LFAdmin.Groups.Stored[group]
    if not rank and group ~= LFAdmin.Config.defaultUsergroup then
        local n = tonumber(group)
        if activator:HasAccess("*") and team.Valid(n) then rank, to = {Name = iv.Name, Team = n}, true
        else return LFAdmin.LogPlayer(activator, "Группа \"", "#" .. group, "\" не существует") end
    end
    if iv and (not to and not iv:CanTarget(group)) then return LFAdmin.LogPlayer(activator, "Этот ранг выше вашего!"), LFAdmin.LogPlayer(NULL, activator, " попытался взять ", target, " фейк-группу выше своей (", "#" .. group, ")") end
    if not target or not IsValid(target[1]) then
        target = {activator}
        LFAdmin.LogPlayer(false, activator, " взял фейк-группу ", "#" .. team.GetName(rank.Team), " (", "#" .. group, ")")
    else
        LFAdmin.LogPlayer(false, activator, " выдал ", target, " фейк-группу ", "#" .. team.GetName(rank.Team), " (", "#" .. group, ")")
    end
    for k, v in ipairs(target) do v:SetTeam(rank.Team) end
end)

LFAdmin.Command("sessions", "m", {"steamid"}, function(activator, target)
    local d = sql.QueryTyped("SELECT SteamID, Name, `Start`, `End` FROM gmlfi_Sessions WHERE SteamID = ? ORDER BY Start DESC LIMIT 30", LFAdmin.GetSteamID(target, true))
    if d and next(d) then
        LFAdmin.LogPlayer(activator, "Последние ", #d, " сессий ", target)
        for k, v in ipairs(d) do
            if v.End then
                LFAdmin.LogPlayer(activator, "- от ", "#" .. os.date("%d.%m.%Y %H:%M:%S", v.Start), " до ", "#" .. os.date(os.date("%d", v.Start) == os.date("%d", v.End) and "%H:%M:%S" or "%d.%m.%Y %H:%M:%S", v.End), " (", "#" .. LFAdmin.FormatTime(v.End - v.Start), ")")
            else LFAdmin.LogPlayer(activator, "- от ", "#" .. os.date("%d.%m.%Y %H:%M:%S", v.Start), " (", "#активная сессия", ", ", "#" .. LFAdmin.FormatTime(os.time() - v.Start), ")") end
        end
    else LFAdmin.LogPlayer(activator, "Сессии ", target, " не найдены или еще не записаны") end
end)

LFAdmin.Command("cexec", "*", {"player", "string"}, function(activator, target, cmd)
    LFAdmin.LogPlayer(false, activator, " выполнил команду ", "#" .. cmd, " на ", target)
    target:ConCommand(cmd)
end)

local uar = function(activator, target, cm, restrict)
    local sid64 = LFAdmin.GetSteamID(target, true)
    local e = sql.QueryTyped("SELECT restrict FROM lfadmin_access WHERE sid64 = ?", sid64)
    if e and e[1] then
        if tonumber(e[1].restrict) == (cm and 1 or 0) then return LFAdmin.LogPlayer(activator, "У ", target, " уже " .. (restrict and "отобран" or "выдан") .. " доступ к этой команде/доступу") end
        sql.QueryTyped("DELETE FROM lfadmin_access WHERE access = ? AND sid64 = ?", cm, sid64)
    else
        sql.QueryTyped("INSERT INTO lfadmin_access (sid64, name, restrict) VALUES (?, ?, ?)", sid64, cm)
    end
end

LFAdmin.Command("userallow", "s", {"steamid", "string"}, function(activator, target, cm)
    local iv = IsValid(activator)
    local ac = LFAdmin.CustomAccess[cmd]
    local cmd = LFAdmin.Commands[cmd]
    if not ac and not cmd then return LFAdmin.LogPlayer(activator, "Доступ или команда \"", "#" .. cm, "\" не существует") end
    if iv and not LFAdmin.CanAccess(activator, cm) then return LFAdmin.LogPlayer(activator, "Вы не имеете доступ к этой команде/доступу!"), LFAdmin.LogPlayer(NULL, activator, " попытался выдать ", target, " доступ, который не имеет сам (", "#" .. cm, ")") end
    
    uar(activator, target, cm, cmd and cmd.name or cm, false)
    LFAdmin.LogPlayer(false, activator, " выдал ", target, " доступ к \"", "#" .. ((ac or cmd).name or cm), "\"")
end)

local PLAYER = FindMetaTable("Player")
LFAdmin.RealNameFunc = LFAdmin.RealNameFunc or PLAYER.Name
function PLAYER:Name() return self:GetNetVar("CustomName") or LFAdmin.RealNameFunc(self) end
function PLAYER:Nick() return self:GetNetVar("CustomName") or LFAdmin.RealNameFunc(self) end
function PLAYER:GetName() return self:GetNetVar("CustomName") or LFAdmin.RealNameFunc(self) end

LFAdmin.CommandDescription("setgroup", "Устанавливает группу цели")
LFAdmin.CommandDescription("warn", "Выдает варн цели")
LFAdmin.CommandDescription("unwarn", "Снимает варн цели")
LFAdmin.CommandDescription("warns", "Выдает список варнов цели")
LFAdmin.CommandDescription("bot", "Добавляет ботов на сервер")
LFAdmin.CommandDescription("info", "Выдает информацию о цели")
LFAdmin.CommandDescription("viewstaff", "Выдает список администраторов онлайн")
LFAdmin.CommandDescription("setplaytime", "Устанавливает время игры цели")
LFAdmin.CommandDescription("name", "Сменить свое локальное имя")
LFAdmin.CommandDescription("randomname", "Сменить свое локальное имя на случайное")
LFAdmin.CommandDescription("setname", "Сменить локальное имя цели")
LFAdmin.CommandDescription("clearname", "Сбросить локальное имя цели")
LFAdmin.CommandDescription("faketeam", "Меняет Ваш визуальный ранг на указанный")

local groups = function(cmd, arg)
    local me = LocalPlayer():GetRank()
    local t = {}
    for group in pairs(LFAdmin.Groups.Stored) do if me:CanTarget(group) then t[#t + 1] = group end end
    return t
end
LFAdmin.AutoComplete("setgroup", {
    [2] = groups,
    [4] = groups,
})
LFAdmin.AutoComplete("faketeam", {
    [1] = groups,
})