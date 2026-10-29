LFAdmin.Commands = LFAdmin.Commands or {}

LFAdmin.Command = function(name, access, args, cb, cc)
    local t = type(name) == "table"
    local n = t and name[1] or name
    local data = {name = n, access = access, callback = cb, client = cc, args = args}
    for k, v in ipairs(t and name or {name}) do LFAdmin.Commands[v] = data end
    return data
end

LFAdmin.CommandDescription = function(name, desc, argsn)
    local cmdt = LFAdmin.Commands[name]
    if cmdt then cmdt.description, cmdt.argsn = desc, cmdt.argsn or argsn end
end

LFAdmin.AutoComplete = function(name, args)
    if LFAdmin.Commands[name] then LFAdmin.Commands[name].autocomplete = args end
end

LFAdmin.CustomAccess = LFAdmin.CustomAccess or {}
LFAdmin.RegisterAccess = function(name, access)
    LFAdmin.CustomAccess[name] = istable(access) and access or {name = name, access = access}
end

LFAdmin.CanAccess = function(ply, cmd)
    local ac = LFAdmin.CustomAccess[cmd]
    local cmd = LFAdmin.Commands[cmd]
    if ac then return ply:HasAccess(ac.access) else
        return not cmd or not IsValid(ply) or not cmd.access or ply:HasAccess(cmd.access)
    end
end

if SERVER then
    util.AddNetworkString("LFAdmin.Command")
end

local times = {
    s  = 1,
    mi = 60,
    h  = 3600,
    d  = 86400,
    w  = 604800,
    mo = 2592000,
    y  = 31540000,
}

times.m = times.mi
times.min = times.mi
times.hours = times.h
times.days = times.d
times.weeks = times.w
times.months = times.mo
times.years = times.y

local badarg = function(ply, k, exp) LFAdmin.LogPlayer(ply, string.format("Неверный аргумент #%i, ", k), "требуется ", "#" .. exp) end
local handle = {
    player = function(arg, ply)
        if arg == "^" then return ply end
        if arg == "@" then local t = ply:GetEyeTrace().Entity return t:IsPlayer() and t end
        local ret = {}
        for k, v in ipairs(player.GetAll()) do
            if v:SteamID() == arg or v:SteamID64() == arg or arg == v:Name() or (v:Name() and string.find(string.lower(v:Name()), string.lower(arg), 1, true)) then ret[#ret + 1] = v end
        end
        if #ret > 1 then return false, LFAdmin.LogPlayer(ply, "Найдено несколько игроков: ", ret) end
        return ret[1]
    end,
    players = function(arg, ply)
        if arg == "^" then return {ply} end
        if arg == "@" then local t = ply:GetEyeTrace().Entity return t:IsPlayer() and {t} end
        if arg == "*" then return player.GetAll() end
        local ret = {}
        for k, v in ipairs(player.GetAll()) do
            if v:SteamID() == arg or v:SteamID64() == arg then return {v} end
            if string.find(string.lower(v:Name()), string.lower(arg)) then ret[#ret + 1] = v end
        end if next(ret) then return ret end
    end,
    number = function(n) return tonumber(n) end,
    -- string = function(s, _, args, k, cmd)
    --     if #cmd.args == k then return table.concat(args, " ", k)
    --     else return s end
    -- end,

    time = function(n)
        if n == "0" then return {time = 0, raw = n} end
        if tonumber(n) then return {time = n, raw = n .. "s"} end
        local time, i = 0, 0
        for v, m in string.gmatch(string.lower(n), "([0-9]+)([a-z]+)") do i = i + 1
            local t = times[m]
            if t then time = time + v * t end
        end
        if i == 0 then return end
        return {time = time, raw = n}
    end,
    steamid = function(arg, ply) -- returns player entity if target is on server, superior servers like (wtf sup pasting??? on my derivedrp server?!1)
        if arg == "^" then return ply end
        if arg == "@" then local t = ply:GetEyeTrace().Entity return t:IsPlayer() and t end
        local ret = {}
        for k, v in ipairs(player.GetAll()) do
            if v:SteamID() == arg or v:SteamID64() == arg or arg == v:Name() or (v:Name() and string.find(string.lower(v:Name()), string.lower(arg), 1, true)) then ret[#ret + 1] = v end
        end
        if #ret > 1 then return false, LFAdmin.LogPlayer(ply, "Найдено несколько игроков: ", ret) end
        return ret[1] or LFAdmin.GetSteamID(arg)
    end
}

local pargs = {
    player = true,
    players = true,
    steamid = true
}

local explode = function(str) -- sup pasting my beloved
	str = ' ' .. str .. ' '
	local res = {}
	local ind = 1
	while true do
		local sInd, start = str:find('[^%s]', ind)
		if not sInd then break end
		ind = sInd + 1
		local quoted = str:sub(sInd, sInd):match('["\']') and true or false
		local fInd, finish = str:find(quoted and '["\']' or '[%s]', ind)
		if not fInd then break end
		ind = fInd + 1
		res[#res + 1] = str:sub(quoted and sInd + 1 or sInd, fInd - 1)
	end
	return res
end

-- local fparse = function(str) local match = string.match(str, "(%p+)$") return match and string.Explode("", match) or {} end
local parse = function(ply, _, _args, arg, ischat)
    if not arg then arg = table.concat(_args, " ") end args = explode(arg)
    if ply.LFACCD and ply.LFACCD > CurTime() then return LFAdmin.LogPlayer(ply, "Не спамьте командами...") end ply.LFACCD = CurTime() + 1
    if not args or not args[1] then return end args[1] = string.lower(args[1])
    local cmd, cm = LFAdmin.Commands[args[1]] or LFAdmin.Commands[gmlfi.ЙЦУКЕНToQWERTY(args[1])], args[1] if not cmd then return true, not ischat and LFAdmin.LogPlayer(ply, "Неизвестная команда \"", string.format("#%s", cm), "\"") end
    if not LFAdmin.CanAccess(ply, cm) then return LFAdmin.LogPlayer(ply, "Вам нужен флаг \"", "#" .. cmd.access, "\" для использования этой команды") end
    if SERVER then table.remove(args, 1)
        local nar, skip = {}
        for k, v in ipairs(cmd.args) do
            local optional = string.sub(v, -1) == "?" local tp = optional and string.sub(v, 1, -2) or v
            if not args[k] and not optional then return badarg(ply, k, v) elseif not args[k] and optional then continue end
            if k == #cmd.args then args[k], skip = table.concat(args, " ", k), true for kk = k + 1, #args do args[kk] = nil end end
            if handle[tp] then
                local h = handle[tp](args[k], ply, args, k, cmd)
                if h == false then return end
                if (not h or type(h) == "table" and not next(h)) and not optional then return badarg(ply, k, v)
                elseif h then
                    if not cmd.SkipAccessCheck and IsValid(ply) and pargs[tp] then
                        for _, target in ipairs(type(h) == "table" and h or {h}) do
                            local online = IsValid(target)
                            local group = not online and (LFAdmin.GetDBUser(target) or "user")
                            local ok
                            if online then bad = not ply:CanTarget(target) else bad = group and not ply:GetRank():CanTarget(group) end -- fucking Either() doesn't work
                            if bad then
                                if online then LFAdmin.LogPlayer(target, ply, " попытался использовать \"", "#" .. cm, "\" на вас") end
                                LFAdmin.LogPlayer(NULL, ply, " попытался использовать \"", "#" .. cm, "\" на ", target)
                                local im = online and target:GetImmunity() or (LFAdmin.Groups.Stored[group] or {Immunity = 0}).Immunity
                                return LFAdmin.LogPlayer(ply, online and target or ("#" .. target), " имеет иммунитет выше, чем ваш (", im == 0 and "*" or im, " > ", ply:GetImmunity(), ")")
                            end
                        end
                    end
                    nar[k] = h
                end
            elseif args[k] then nar[k] = args[k] end
            if skip then break end
        end
        if cmd.callback then cmd.callback(ply, unpack(nar)) end
        if cmd.client then net.Start("LFAdmin.Command") net.WriteString(cm) net.Send(ply) end
        hook.Run("LFAdmin.Command", ply, cm, args)
    end
end

local actypes = {
    player = function(cmd, arg)
        local me = LocalPlayer()
        local t = {}
        for k, v in ipairs(player.GetAll()) do if cmd.SkipAccessCheck or me:CanTarget(v) and (not arg or v:SteamID() == arg or v:SteamID64() == arg or arg == v:Name() or (v:Name() and string.find(string.lower(v:Name()), string.lower(arg), 1, true))) then t[#t + 1] = v:Name() end end
        return t
    end,
    time = function(cmd, arg)
        local t = {}
        for k in pairs(times) do
            if not arg or string.match(arg, "^%d+$") then t[#t + 1] = (arg or "1") .. k end
        end
        return t
    end
}

actypes.players, actypes.steamid = actypes.player, actypes.player

local autocomplete = CLIENT and function(cmd, args, argst)
    argst = explode(args)
    local lp = LocalPlayer()
    local na, tbl = #argst, {}
    local sn = args[#args] == " " and na >= 1
    if na <= 1 and not sn then
        for k, v in pairs(LFAdmin.Commands) do
            if not v.SkipHelp and ((not argst[1] or argst[1] == k or string.find(string.lower(k), string.lower(argst[1]), 1, true)) and LFAdmin.CanAccess(lp, v.name)) then
                tbl[#tbl + 1] = cmd .. " " .. k
            end
        end
        return tbl
    end

    local cmdt = argst[1] and LFAdmin.Commands[argst[1]]
    if cmdt then
        table.remove(argst, 1)
        cmd = cmd .. " " .. cmdt.name
        for k, v in ipairs(cmdt.args) do
            if not argst[1] and not sn or k > na then break end
            local ac = cmdt.autocomplete and cmdt.autocomplete[k] or actypes[string.sub(v, -1) == "?" and string.sub(v, 1, -2) or v]
            local prefix = (tbl[1] or cmd) .. " "
            if ac then
                for k, v in ipairs(ac(cmdt, argst[1])) do
                    tbl[#tbl + 1] = prefix .. "\"" .. v .. "\""
                end
            end
            table.remove(argst, 1)
        end
    end
    return tbl
end or function() end

for k, cm in ipairs(LFAdmin.Config.command) do
    if SERVER then concommand.Add("_" .. cm, parse) end
    concommand.Add(cm, SERVER and parse or function(p, _, _, arg) p:ConCommand("_" .. cm .. (arg and " " .. arg or "")) end, autocomplete)
end

local prefixes = {["!"] = true, ["/"] = true}
hook.Add("PlayerSay", "LFAdmin.Commands", function(ply, text)
    if prefixes[string.sub(text, 1, 1)] then local a = parse(ply, nil, nil, string.sub(text, 2), true) if not a then return "" end end -- can return false i guess (would stop next playersay hooks)
    local muted = LFAdmin.GetSteamIDTimedVar(ply, "LFAMUTED")
    if muted and (muted == true or muted > CurTime()) then return "" end
end)

LFAdmin.Command("help", "u", {}, nil, function()
    local sw, sh = ScrW(), ScrH()
    local ww = function(w) return w / 1920 * sw end
    local hh = function(h) return h / 1080 * sh end
    local wh, bl = Color(255, 255, 255), Color(0, 0, 0)

    local frame = vgui.Create("LFI:Frame")
    frame:SetSize(ww(504), hh(700))
    frame:Center()
    frame:MakePopup()
    frame:SetText("Список команд")

    local list = vgui.Create("LFI:Panel", frame)
    list:SetPos(ww(20), hh(71))
    list:SetSize(ww(464), hh(608))
    list:DockPadding(ww(5), hh(5), ww(5), hh(5))

    local cats = {}
    for name, command in pairs(LFAdmin.Commands) do
        if command.SkipHelp or name ~= command.name or not LFAdmin.CanAccess(LocalPlayer(), name) then continue end -- aliases
        local cfun = command.callback or command.client
        local cname = cfun and string.GetFileFromFilename(debug.getinfo(cfun).short_src) or "other" local oc = cats[cname]
        cats[cname] = oc or {} oc = cats[cname]
        oc[#oc + 1] = name
        table.sort(oc, function(a, b) return string.byte(a) < string.byte(b) end)
    end

    local i = 0
    for cat, kittens in pairs(cats) do -- meow family
        i = i + 1
        local label = vgui.Create("DLabel", list)
        label:Dock(TOP)
        label:DockMargin(5, 5, 5, 0)
        label:SetText("")
        label:SetTextColor(wh)
        label:SetZPos(i)
        label.PaintOver = function(self, w, h)
            draw.SimpleText(cat, "LFI:VGUI.ButtonTitle", 0, 0, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2)
            draw.RoundedBox(0, 0, h - 1, w, 1, wh)
        end

        for k, name in ipairs(kittens) do i = i + 1
            local command = LFAdmin.Commands[name]
            local item = vgui.Create("LFI:ButtonDesc", list)
            item:Dock(TOP)
            item:SetZPos(i)
    
            local args = {}
            for k, v in ipairs(command.args or {}) do args[#args + 1] = "<" .. v .. ">" end
            item:SetTitleText(string.format("%s%s", name, args and " " .. table.concat(args, " ") or ""))
            item:SetDescriptionText((command.description and (utf8.len(command.description) > 64 and utf8.sub(command.description, 1, 63) .. "…" or command.description) or "Описание отсутствует") .. ".")
        end
    end
end)

LFAdmin.Command("test", "*", {"steamid?"}, function(ply, target)
    LFAdmin.LogPlayer(true, ply, " выполняет тестовую команду с целью ", target or "#(без цели)", "; Цифры: ", math.random(100000), "; Строка с хайлайтом: ", "#" .. gmlfi.RandomString(15), "; Стимайди: ", "STEAM_0:1:158640106", "; Все игроки: ", player.GetAll(), "; Несколько игроков: ", {ply, target})
    LFAdmin.LogPlayerPrefixed(true, "test", ply, " выполняет тестовую команду (тест префиксов)")
    LFAdmin.LogPlayer(false, ply, " выполняет тестовую команду (это видят только IsStaff)")
    LFAdmin.LogPlayer(NULL, ply, " выполняет тестовую команду (это видит только консоль и канал #logs)")
    LFAdmin.LogPlayer(ply, ply, " выполняет тестовую команду (это видите только вы)")
end)

if CLIENT then
    net.Receive("LFAdmin.Command", function()
        local cm = LFAdmin.Commands[net.ReadString()]
        if cm and cm.client then cm.client() end
    end)
end