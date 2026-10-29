LFAdmin = LFAdmin or {}
LFAdmin.Config = {
    command = {"lf", "lfadmin"},
    defaultUsergroup = "user",
    colors = {
        text = Color(255, 255, 255),
        hide = Color(100, 100, 100),
        main = Color(50, 150, 255),
        admn = Color(255, 50, 50),

        console = Color(200, 200, 255),
        number  = Color(200, 255, 200),
        string  = Color(200, 255, 200),
        steamid = Color(200, 255, 255),
    },
    dir = "lfadmin",
    logfile = os.date("/logs/%d-%m.txt"),
    kickmessage = "%s кикнул Вас с этого сервера с причиной:\n\"%s\"\nВы можете получить помощь на нашем Discord сервере: " .. gmlfi.discordDirect or gmlfi.discord .. "\nПравила доступны по ссылке: " .. gmlfi.rulesURL,
    banmessage = [[
%s заблокировал Вас на этом сервере
- По причине "%s"
- Осталось %s

Вы можете получить помощь на нашем Discord сервере: ]] .. (gmlfi.discordDirect or gmlfi.discord) .. [[ 
Правила доступны по ссылке: ]] .. gmlfi.rulesURL,
}

if not file.IsDir(LFAdmin.Config.dir, "DATA") then file.CreateDir(LFAdmin.Config.dir) end
if not file.IsDir(LFAdmin.Config.dir .. "/logs", "DATA") then file.CreateDir(LFAdmin.Config.dir .. "/logs") end

LFAdmin.IsConsole = function(ply) return not IsValid(ply) or not ply:IsPlayer() or ply:GetNWBool("LFI:Hide",false) end
LFAdmin.GetStaff = function() local r = {} for k, v in ipairs(player.GetAll()) do if v:IsStaff() then r[#r + 1] = v end end return r end

LFAdmin.GetSteamID = function(v, s) -- s - steamid64
    if IsValid(v) and v:IsPlayer() then return s and v:SteamID64() or v:SteamID() end v = tostring(v)
    if string.match(v, "^STEAM_%d:%d:%d+$") then return s and util.SteamIDTo64(v) or v end
    if string.match(v, "^7656119%d%d%d%d%d%d%d%d%d%d$") then return s and v or util.SteamIDFrom64(v) end
end

LFAdmin._GetPlayerCache = {}
LFAdmin.GetPlayer = function(arg)
    if arg.IsPlayer and arg:IsPlayer() then return arg end
    local c = LFAdmin._GetPlayerCache[arg]
    if c then
        if c[2] > CurTime() and IsValid(c[1]) then return c[1]
        else LFAdmin._GetPlayerCache[arg] = nil end
    end
    for k, v in ipairs(player.GetAll()) do
        if v:SteamID() == arg or v:SteamID64() == arg or arg == v:Name() or (v:Name() and string.find(string.lower(v:Name()), string.lower(arg), 1, true)) then
            LFAdmin._GetPlayerCache[arg] = {v, CurTime() + 300}
            return v
        end
    end
end

timer.Create("LFAdmin:ClearPlayerCache", 300, 0, function()
    for k, c in pairs(LFAdmin._GetPlayerCache) do
        if c[2] < CurTime() or not IsValid(c[1]) then LFAdmin._GetPlayerCache[k] = nil end
    end
end)

local units = {
    {86400*365, "л"},
    {86400*30, "мес"},
    {86400*7, "нед"},
    {86400, "д"},
    {3600, "ч"},
    {60, "мин"},
    {1, "сек"}
}

LFAdmin.FormatTime = function(num, limit)
    local ret = {}
    local count = limit or 7

    for i, unit in ipairs(units) do
        if count == 0 then break end
        if num >= unit[1] or (limit and limit < 0 and -limit <= i) then
            local c = math.floor(num / unit[1])
            ret[#ret + 1] = c .. " " .. unit[2]
            num = num - unit[1] * c
            count = limit and (limit > 0 and count - 1 or count + 1) or count
        end
    end

    local str = ""
    for i, v in ipairs(ret) do
        str = str .. (i == 1 and "" or i == #ret and " и " or " ") .. v .. "."
    end

    return str
end

local insert = function(t, ...) for k, v in ipairs({...}) do t[#t + 1] = v end end
local types types = {
    string = function(v, tbl)
        -- v = string.gsub(v, "\t", "   ")
        if v[1] == "#" and #v > 1 then insert(tbl, LFAdmin.Config.colors.string, string.sub(v, 2), LFAdmin.Config.colors.text)
        else
            local s = LFAdmin.GetSteamID(v)
            if s then insert(tbl, LFAdmin.Config.colors.steamid, s, LFAdmin.Config.colors.text) else insert(tbl, v) end
        end
    end,
    Entity = function(v, tbl)
        if not IsValid(v) then return types.Player(v, tbl)
        else insert(tbl, LFAdmin.Config.colors.console, v:GetClass(), LFAdmin.Config.colors.text) end
    end,
    Player = function(v, tbl)
        if LFAdmin.IsConsole(v) then insert(tbl, LFAdmin.Config.colors.console, (SERVER or v == Entity(0)) and "(Консоль)" or "(Неизвестно)", LFAdmin.Config.colors.text)
        else insert(tbl, team.GetColor(v:Team()), v:Name(), LFAdmin.Config.colors.hide, " (" .. v:SteamID() .. ")", LFAdmin.Config.colors.text) end
    end,
    table = function(v, tbl)
        if #v == player.GetCount() and player.GetCount() > 1 then return insert(tbl, LFAdmin.Config.colors.console, "(всех)", LFAdmin.Config.colors.text)
        elseif not next(v) then return insert(tbl, LFAdmin.Config.colors.console, "(никого)", LFAdmin.Config.colors.text) end
        for k, p in ipairs(v) do types.Player(p, tbl) if k < #v then insert(tbl, ", ") end end
    end,
    number = function(v, tbl) insert(tbl, LFAdmin.Config.colors.number, tostring(v), LFAdmin.Config.colors.text) end
}

local sm = function(str)
    return tostring(str)
    :gsub("%[", "\\["):gsub("%]", "\\]"):gsub("*", "\\*")
    :gsub("_", "\\_"):gsub("`", "\\`"):gsub("|", "\\|")
    :gsub("~", "\\~"):gsub(">", "\\>"):gsub("@", "\\@")
end
local smc = function(str) return tostring(str):gsub("`", "\\`") end
local typesd typesd = {
    string = function(v, tbl)
        if v[1] == "#" and #v > 1 then insert(tbl, "`", smc(string.sub(v, 2)), "`")
        else
            local s = LFAdmin.GetSteamID(v)
            if s then insert(tbl, "[`", smc(s), "`](<https://steamcommunity.com/profiles/", LFAdmin.GetSteamID(s, true), ">)") else insert(tbl, v) end
        end
    end,
    Entity = function(v, tbl)
        if not IsValid(v) then return typesd.Player(v, tbl)
        else insert(tbl, "`", smc(v:GetClass()), "`") end
    end,
    Player = function(v, tbl)
        if LFAdmin.IsConsole(v) then insert(tbl, (SERVER or v == Entity(0)) and "**(Консоль)**" or "**(Неизвестно)**")
        else insert(tbl, "[**", sm(v:Name()), "**](<https://steamcommunity.com/profiles/", v:SteamID64(), ">) (`", v:SteamID() .. "`)") end
    end,
    table = function(v, tbl)
        if #v == player.GetCount() and player.GetCount() > 1 then insert(tbl, "**(всех)**") return end
        for k, p in ipairs(v) do typesd.Player(p, tbl) if k < #v then insert(tbl, ", ") end end
    end,
    number = function(v, tbl) insert(tbl, "`", tostring(v), "`") end
}
LFAdmin.LogFormat = function(str, ...)
    if not ... then return LFAdmin.Log(str) end
    local tbl = {}
    for k, v in ipairs({str, ...}) do if types[type(v)] then types[type(v)](v, tbl) else tbl[#tbl + 1] = tostring(v) end end
    if SERVER then
        local tbld = {}
        for k, v in ipairs({str, ...}) do if typesd[type(v)] then typesd[type(v)](v, tbld) else tbld[#tbld + 1] = tostring(v) end end
        if not LFAdmin.DONT_SEND and LFAdmin.SendToLogs and not LFAdmin.TO_CONSOLE then LFAdmin.SendToLogs((LFAdmin.ADMIN_ONLY and "📌 " or "") .. table.concat(tbld, "")) end
    end
    LFAdmin.DONT_SEND = true
    LFAdmin.Log(unpack(tbl))
    LFAdmin.DONT_SEND = nil
end

local prefixes = {
    asay = "Админ-чат",
    ["local"] = "Локально",
    radio = "Рация",
    pm = "PM",
    me = "Действие",
    test = "Тест",
    donate = "Донат",
}

LFAdmin.Log = function(...)
    -- "¦ "
    MsgC(LFAdmin.ADMIN_ONLY and LFAdmin.Config.colors.admn or LFAdmin.Config.colors.main, "lfadmin // ", LFAdmin.Config.colors.text, LFAdmin.CHAT_PREFIX and ("[" .. LFAdmin.CHAT_PREFIX .. "] ") or "", ...) if SERVER then MsgN() else chat.PlaySound() end
    
    if SERVER then
        local l = LFAdmin.CHAT_PREFIX and ("[" .. LFAdmin.CHAT_PREFIX .. "] ") or "" for k, v in ipairs({...}) do if type(v) ~= "table" then l = l .. tostring(v) end end
        file.Append(LFAdmin.Config.dir .. LFAdmin.Config.logfile, string.format("%s | %s\n", os.date("%X"), l))
        if not LFAdmin.DONT_SEND and LFAdmin.SendToLogs and not LFAdmin.TO_CONSOLE then LFAdmin.SendToLogs((LFAdmin.ADMIN_ONLY and "📌 " or "") .. l) end
    elseif gmlfi.chat and IsValid(gmlfi.chat.HTML) then
        chat.AddText(gmlfi.ChatTag(LFAdmin.CHAT_PREFIX and (prefixes[LFAdmin.CHAT_PREFIX] or LFAdmin.CHAT_PREFIX) or "LFAdmin", "lfa" .. (LFAdmin.CHAT_PREFIX and ("-" .. LFAdmin.CHAT_PREFIX) or LFAdmin.ADMIN_ONLY and "-admn" or ""), LFAdmin.LOG_TIME_LAST and LFAdmin.LOG_TIME == LFAdmin.LOG_TIME_LAST and LFAdmin.CHAT_PREFIX == LFAdmin.CHAT_PREFIX_LAST and "invisible"), " ", ...)
    end
end

if CLIENT then
    local bl = Color(0, 0, 0)
    local tag = function(col, tcol)
        return {
            ["background-color"] = col:ToHex() .. "88",
            ["color"] = tcol and tcol:ToHex(),
            ["text-shadow"] = tcol and "none",
        }
    end
    gmlfi.chat.AddStyle({
        [".lfa"] = tag(LFAdmin.Config.colors.main),
        [".lfa-admn"] = tag(LFAdmin.Config.colors.admn),
        [".lfa-test"] = tag(Color(255, 95, 250)),
        
        [".lfa-asay"] = tag(LFAdmin.Config.colors.admn),
        [".lfa-local"] = tag(Color(104, 156, 1)),
        [".lfa-radio"] = tag(Color(1, 156, 156)),
        [".lfa-pm"] = tag(Color(156, 143, 1)),
        [".lfa-me"] = tag(Color(1, 156, 68)),
        [".lfa-donate"] = tag(Color(183, 242, 88), bl),
    })
end

if not LFAdmin.Loaded then LFAdmin.Log("initialized...") LFAdmin.Loaded = true end
