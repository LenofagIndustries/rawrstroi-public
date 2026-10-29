LFAdmin.Logs = LFAdmin.Logs or {}

--     ______   __    __   __       ______  __    
--    /\  ___\ /\ "-./  \ /\ \     /\  ___\/\ \   
--    \ \ \__ \\ \ \-./\ \\ \ \____\ \  __\\ \ \  
--     \ \_____\\ \_\ \ \_\\ \_____\\ \_\   \ \_\ 
--      \/_____/ \/_/  \/_/ \/_____/ \/_/    \/_/ 
--
--    gm.lenofag.ru © 2025
--    complete logs system i made here in shared... well...
--    save this watermark if you are copying our scripts please

-- default page size is 20
-- edit here            vvvv
LFAdmin.Logs.PAGE_SIZE = 19

LFAdmin.Logs.Terms = {
    ["plys"] = "Игроки",
    ["glbl"] = "Сервер",

    ["kills"] = "Убийства",
    ["dmg"] = "Урон",
    ["objs"] = "Объекты",
    ["tools"] = "Инструменты",
    ["physgun"] = "Физган",
    ["dconnects"] = "Подключения",
    ["chat"] = "Чат",
    ["commands"] = "Команды",
    ["actions"] = "Действия",
    ["restarts"] = "Рестарты",

    ["death"] = "? убил ? используя ?",
    ["death.suicide"] = "? совершил самоубийство",
    ["death.entity"] = "? был убит энтити ?",
    ["damage"] = "? нанес ? урона игроку ? используя ?",
    ["spawn.prop"] = "? заспавнил проп ?",
    ["spawn.sent"] = "? заспавнил энтити ?",
    ["spawn.vehicle"] = "? заспавнил транспорт ?",
    ["spawn.advdupe2"] = "? заспавнил дубликат с ? объектами и ? констрейнтами",
    ["spawn.train"] = "? заспавнил или обновил состав ?",
    ["tool"] = "? использовал \"?\" на ? (?)",
    ["physgun.pickup"] = "? взял физганом ?",
    ["physgun.freeze"] = "? заморозил физганом ?",
    ["crazyphysics"] = "? был остановлен системой Crazy Physics",
    ["connect"] = "? подключился на сервер",
    ["disconnect"] = "? отключился от сервера",
    ["say"] = "? написал: \"?\"",
    ["command.lfa"] = "? использовал команду \"?\" ?",
    ["changeteam"] = "? сменил команду на ? (был ?)",
    ["server.start"] = "Сервер запустился",
    ["server.stop"] = "Сервер выключился",

    ["term.player.name"] = "Имя игрока",
    ["term.player.id"] = "SteamID",
}

local sply = function(ply) return string.format("%s [%s]", ply:Name(), ply:SteamID()) end local clply = sply
local cllog = function(ply, str, ...) if IsValid(ply) then print(clply(ply) .. " " .. string.format(str, ...)) end end
local ignoreTools = {paint = true, inflator = true}
LFAdmin.Logs.Categories = {
    ["plys"] = {
        ["kills"] = {
            ["PlayerDeath"] = function(ply, i, a)
                if ply == a or not IsValid(a) then return "death.suicide", ply end
                if not a:IsPlayer() then return "death.entity", ply, a, a:GetOwner() end
                return "death", a, ply, i ~= a and i or a:GetActiveWeapon()
            end
        },
        ["dmg"] = {
            ["PostEntityTakeDamage"] = function(ply, dmg, t)
                if t and ply:IsPlayer() then
                    local a, i = dmg:GetAttacker(), dmg:GetInflictor()
                    if IsValid(a) and a:IsPlayer() then return "damage", a, dmg:GetDamage(), ply, i ~= a and i or a:GetActiveWeapon() end
                end
            end
        },
        ["objs"] = {
            ["PlayerSpawnedProp"] = function(ply, m)
                cllog(ply, "spawned a prop (%s)", m)
                return "spawn.prop", ply, m
            end,
            ["PlayerSpawnedSENT"] = function(ply, m)
                cllog(ply, "spawned a sent (%s)", m:GetClass())
                return "spawn.sent", ply, m:GetClass()
            end,
            ["PlayerSpawnedVehicle"] = function(ply, m)
                cllog(ply, "spawned a vehicle (%s)", m:GetClass())
                return "spawn.vehicle", ply, m:GetClass()
            end,
            ["AdvDupe_FinishPasting"] = function(data)
                data = data[1] if not data then return end
                local a, b = table.Count(data.CreatedEntities), table.Count(data.CreatedConstraints)
                cllog(data.Player, "spawning a dupe (%s objects, %s constraints)", a, b)
                return "spawn.advdupe2", data.Player, a, b
            end,
            ["OnCrazyPhysics"] = function(ent)
                local owner = ent:CPPIGetOwner()
                print(string.format("%s triggered crazyphysics! (owned by %s)", ent:GetClass(), IsValid(owner) and clply(owner) or owner == Entity(0) and "world" or "null entity"))
                return "crazyphysics", ent
            end,
            ["MetrostroiSpawnerUpdate"] = function(ent)
                if not ent.LFALogsFirstUpdate then
                    ent.LFALogsFirstUpdate = true
                    cllog(ent.Owner, "spawned or updated a train (%s)", ent:GetClass())
                    return "spawn.train", ent.Owner, ent
                end
            end,
        },
        ["tools"] = {
            ["CanTool"] = function(ply, tr, tool, _, b)
                timer.Simple(0, function() cllog(ply, "used tool %s on %s (%s)", tool, IsValid(tr.Entity) and (string.StartsWith(tr.Entity:GetClass(), "prop_") and tr.Entity:GetModel() or tr.Entity:GetClass()) or "world", b == 1 and "LMB" or b == 2 and "RMB" or b == 3 and "R" or (b and "button " .. b or "?")) end)
                return "tool", ply, tool, tr.Entity, b == 1 and "ЛКМ" or b == 2 and "ПКМ" or b == 3 and "R" or (b and "кнопка " .. b or "?")
            end
        },
        ["physgun"] = {
            ["OnPhysgunPickup"] = function(ply, ent)
                return "physgun.pickup", ply, ent
            end,
            ["OnPhysgunFreeze"] = function(_, _, ent, ply)
                return "physgun.freeze", ply, ent
            end,
        },
        ["dconnects"] = {
            ["PlayerAuthed"] = function(ply)
                return "connect", ply
            end,
            ["PlayerDisconnected"] = function(ply)
                return "disconnect", ply
            end,
        },
        ["chat"] = {
            ["PlayerSay"] = function(ply, str)
                return "say", ply, str
            end,
        },
        ["commands"] = {
            ["LFAdmin.Command"] = function(ply, cmd, args)
                return "command.lfa", ply, cmd, args
            end,
        },
        -- ["actions"] = {
            
        -- },
    },
    ["glbl"] = {
        ["restarts"] = {
            ["InitPostEntity"] = function() return "server.start" end,
            ["ShutDown"] = function() return "server.stop" end,
        }
    }
}

if SERVER then
    local plaincats = {}
    for _, v in pairs(LFAdmin.Logs.Categories) do
        for k, vv in pairs(v) do plaincats[k] = vv end
    end
    
    sql.Query("CREATE TABLE IF NOT EXISTS lfadmin_logs (Category TEXT NOT NULL, Event TEXT NOT NULL, FormatArgs TEXT, Time INT NOT NULL)")
    util.AddNetworkString("LFAdmin.Logs")
    util.AddNetworkString("LFAdmin.Logs.Menu")
    
    net.Receive("LFAdmin.Logs", function(_, ply)
        if not LFAdmin.CanAccess(ply, "logs") then return end -- baddie
        if ply.LFAWait and ply.LFAWait > CurTime() then net.Start("LFAdmin.Logs") net.WriteBool(false) net.WriteBool(true) net.Send(ply) return print(sply(ply) .. " log spam detected") end
        ply.LFAWait = CurTime() + .5
        local kittens = {} for k = 1, net.ReadUInt(8) do
            local cat = net.ReadString()
            if not plaincats[cat] then return end -- bad cat (not dragon)
            kittens[k] = string.format("Category = %s", SQLStr(cat))
        end --if not next(kittens) then return end
    
        local page, search, date = (net.ReadUInt(13) - 1) * 20, string.Trim(net.ReadString()), net.ReadUInt(32)
        local sid = LFAdmin.GetSteamID(search, true) if sid then search = sid end
        local d = sql.Query(string.format("SELECT Category, Event, FormatArgs, Time FROM lfadmin_logs WHERE %sTime >= %s AND Time <= %s ORDER BY Time DESC LIMIT %s, %s", (next(kittens) or search ~= "") and string.format("(%s)%s AND ", next(kittens) and table.concat(kittens, " OR ") or 1, search ~= "" and (" AND FormatArgs LIKE " .. SQLStr("%" .. search .. "%")) or "") or "", date, date + 86400, page, LFAdmin.Logs.PAGE_SIZE))
        if d then
            local dc = (sql.QueryRow(string.format("SELECT COUNT(Time) AS c FROM lfadmin_logs WHERE %sTime >= %s AND Time <= %s", (next(kittens) or search ~= "") and string.format("(%s)%s AND ", next(kittens) and table.concat(kittens, " OR ") or 1, search ~= "" and (" AND FormatArgs LIKE " .. SQLStr("%" .. search .. "%")) or "") or "", date, date + 86400)) or {}).c or 0
            net.Start("LFAdmin.Logs")
                net.WriteBool(true)
                net.WriteUInt(math.ceil(dc / LFAdmin.Logs.PAGE_SIZE), 16)
                net.WriteUInt(#d, 16) -- i'm quite sure you will not change page size to numbers more than hundred
                for k, v in ipairs(d) do
                    net.WriteString(v.Category)
                    net.WriteString(v.Event)
                    net.WriteBool(v.FormatArgs ~= nil)
                    if v.FormatArgs then net.WriteString(v.FormatArgs) end
                    net.WriteUInt(v.Time, 31)
                end
            net.Send(ply)
        else net.Start("LFAdmin.Logs") net.WriteBool(false) net.WriteBool(false) net.Send(ply) end
        print(string.format("%s requested logs: %s [#%s, %s] (%s)", sply(ply), search or "", page / 20 + 1, date, next(kittens) and table.concat(kittens, ", ") or "all"))
    end)
    
    local _t2se = function(s) return s:gsub("ρ", "p"):gsub("τ", "t") end
    local _t2s = {
        Player = function(ply) return string.format("ρ{%s}%s{%s}", _t2se(ply:Name()), ply:Team(), ply:SteamID64()) end,
        Weapon = function(wep) return wep:GetClass() end,
        Entity = function(ent)
            local owner = ent:CPPIGetOwner()
            local name = IsValid(ent) and (not ent:IsScripted() and string.StartsWith(ent:GetClass(), "prop_") and ent:GetModel() or ent:GetClass())
            return IsValid(ent) and (IsValid(owner) and string.format("%s (%s [%s])", name, owner:Name(), owner:SteamID()) or name) or ent:IsWorld() and "[Мир]" or "[NULL]"
        end,
        table  = function(tbl) if not next(tbl) then return "" end local a = {} for k, v in ipairs(tbl) do a[k] = tostring(v) end return "τ{" .. _t2se(table.concat(a, ", ")) .. "}" end,
        number = function(num) return tostring(math.floor(num)) end
    }

    _t2s.Vehicle, _t2s.NPC = _t2s.Entity, _t2s.Entity
    
    LFAdmin.Logs.Save = function(kitty, event, data)
        local d = {} for k, v in ipairs(data) do
            if k == 1 then continue end
            local t = _t2s[type(v)]
            d[k - 1] = (t and t(v) or tostring(v)):gsub(";", "")
        end
    
        sql.Query(string.format("INSERT INTO lfadmin_logs VALUES (%s, %s, %s, %s)", SQLStr(kitty), SQLStr(event), next(d) ~= nil and SQLStr(table.concat(d, ";")) or "NULL", os.time()))
    end
    
    for name, hooks in pairs(plaincats) do
        for hn, func in pairs(hooks) do
            hook.Add(hn, "LFAdmin.Logs:" .. name, function(...)
                local d = {func(...)} if d and next(d) ~= nil then
                    LFAdmin.Logs.Save(name, d[1], d)
                end
            end)
        end
    end    
end

LFAdmin.Command("logs", "t", {}, function(ply)
    net.Start("LFAdmin.Logs.Menu")
        net.WriteBool(false)
    net.Send(ply)
end)

-- superior server style (this log system was added to VastRP (a sup paste server where i work) and was improved there by me)
LFAdmin.Command({"pe", "playerevents"}, "t", {"steamid"}, function(ply, target)
    net.Start("LFAdmin.Logs.Menu")
        net.WriteBool(true)
        net.WriteString(LFAdmin.GetSteamID(target))
    net.Send(ply)
end).SkipAccessCheck = true

if CLIENT then
    local FONT_LOG, FONT_SEARCH = gmlfi.vgui.Font("LogDefault", 15, 700), gmlfi.vgui.Font("LogSearch", 15, 700)

    gmlfi.vgui.DownloadMaterial("navigate_left", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/logs/navigate_left.png")
    gmlfi.vgui.DownloadMaterial("navigate_right", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/logs/navigate_right.png")
    gmlfi.vgui.DownloadMaterial("navigate_manual", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/logs/navigate_manual.png")

    local calcDay = function(d)
        local dd = string.Explode(".", d)
        return os.time({day = dd[1], month = dd[2], year = dd[3], hour = 0, min = 0, sec = 0})
    end

    local sw, sh = ScrW(), ScrH()
    local ww = function(w) return w / 1920 * sw end
    local hh = function(h) return h / 1080 * sh end
    local wh, bl, gr = Color(255, 255, 255), Color(0, 0, 0), Color(100, 100, 100)
    local bs, bh, bi, bn = Color(74, 74, 74), Color(50, 50, 50), Color(31, 31, 31), Color(45, 45, 45)
    local ml, cbd = Color(50, 50, 50, 100), Color(50, 50, 50, 200)
    local th, tc = Color(60, 0, 180), Color(105, 0, 255)

    net.Receive("LFAdmin.Logs.Menu", function()
        local frame = vgui.Create("LFI:Frame")
        frame:SetSize(ww(1379), hh(578))
        frame:Center()
        frame:MakePopup()
        frame:SetText("Логи")
    
        local list = vgui.Create("LFI:Panel", frame)
        list:SetPos(ww(20), hh(71))
        list:SetSize(ww(252), hh(487))
    
        local main
        local selected, page, __i, sh, stxt, sdate = {}, 1, 0, hh(6), net.ReadBool() and net.ReadString() or "", calcDay(os.date("%d.%m.%Y"))
        local navigate = function(s) stxt = s or stxt
            if main then main.Logs404, main.LogsLoading = false, true end
            timer.Create("LFAdmin.RequestLogs", .5, 1, function()
                net.Start("LFAdmin.Logs")
                    net.WriteUInt(table.Count(selected), 8)
                    for k in pairs(selected) do
                        net.WriteString(k)
                    end
                    net.WriteUInt(page, 13)
                    net.WriteString(stxt or "")
                    net.WriteUInt(sdate, 32)
                net.SendToServer()
            end)
        end
    
        for name, sc --[[previously: scats 0_o (subcategories)]] in pairs(LFAdmin.Logs.Categories) do
            name = LFAdmin.Logs.Terms[name] or name
            local cat = vgui.Create("DPanel", list)
            cat:SetPos(ww(6), sh)
            cat:SetSize(ww(240), hh(21))
            cat.Paint = function(self, w, h)
                draw.SimpleText(name, "LFI:VGUI.ButtonTitle", 0, 0, wh)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawRect(0, h - hh(2), w, hh(2))
            end
    
            sh = sh + hh(26)
            for cname in pairs(sc) do __i = __i + 1 local ___i = __i
                local cat = vgui.Create("DButton", list)
                cat:SetPos(ww(6), sh)
                cat:SetSize(ww(240), hh(34))
                cat:SetText("")
                local rcname = LFAdmin.Logs.Terms[cname] or cname
                cat.Paint = function(self, w, h)
                    surface.SetDrawColor(selected[cname] and bs or self:IsHovered() and bh or bi)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(HSVToColor(((CurTime() * 100) + (__i + ___i) * 10) % 360, 1, 1))
                    surface.DrawRect(0, 0, ww(1), h)
                    
                    draw.SimpleText(rcname, "LFI:VGUI.ButtonTitle", ww(8), h / 2, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
    
                cat.DoClick = function(self)
                    if selected[cname] then selected[cname] = nil else selected[cname] = true end
                    -- if table.Count(selected) == 0 then
                    --     local main = LFAdmin.Logs.CurrentLogsPanel
                    --     for k, v in ipairs(main.LogsChildren or {}) do v:Remove() end
                    --     main.SEARCH.PAGES_COUNT = 0
                    -- return end
                    page = 1
                    navigate()
                end
    
                sh = sh + hh(39)
            end
        end
    
        main = vgui.Create("LFI:Panel", frame)
        main:SetPos(ww(278), hh(71))
        main:SetSize(ww(1081), hh(487))
        main:DockPadding(ww(6), hh(6), ww(6), hh(6))
        main.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, cbd)
            if self.Logs404 then
                local spam = self.Logs404 == 1
                draw.SimpleText(spam and "Не спамьте, пожалуйста!" or "Ничего не найдено", "LFI:VGUI.ButtonTitle", w / 2, h / 2 - hh(10), wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                if spam then draw.SimpleText("Когда нибудь, мы переделаем логи под MySQL...", "LFI:VGUI.ButtonTitle", w / 2, h / 2 + hh(10), gr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            end
        end
        main.PaintOver = function(self, w, h)
            if self.LogsLoading then
                draw.RoundedBox(0, 0, 0, w, h - hh(25), ml)
                draw.SimpleText("Поиск...", "LFI:VGUI.ButtonTitle", w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        LFAdmin.Logs.CurrentLogsPanel = main
    
        local search = vgui.Create("DPanel", main)
        search:SetPos(0, hh(462))
        search:SetSize(ww(1081), hh(25))
        search:SetZPos(1000)
        search.PAGES_COUNT = 0
        search.Paint = function(self, w, h)
            surface.SetDrawColor(bi)
            surface.DrawRect(0, 0, w, h)
    
            if self.PAGES_COUNT ~= 0 then draw.SimpleText("Страница " .. page .. " из " .. self.PAGES_COUNT, FONT_LOG, ww(8), h / 2, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
        end

        local date = vgui.Create("DButton", search)
        date:SetPos(ww(690), hh(3))
        date:SetSize(ww(74), hh(19))
        date:SetText("")
        date.SelectedDate = os.date("%d.%m.%Y")
        date.Paint = function(self, w, h)
            -- if search.PAGES_COUNT == 0 then return end
            surface.SetDrawColor(self:IsHovered() and bs or bh)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText(self.SelectedDate, FONT_SEARCH, w / 2, h / 2, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        date.DoClick = function()
            --calcDay(os.date("%d.%m.%Y"))
            local d = DermaMenu()
            for k = 0, 6 do
                local dt = os.date("%d.%m.%Y", os.time() - 86400 * k)
                d:AddOption(dt, function() sdate = calcDay(dt) date.SelectedDate = dt navigate() end)
            end
            d:Open()
        end
    
        local inp = vgui.Create("DTextEntry", search)
        inp:SetPos(ww(768), hh(3))
        inp:SetSize(ww(238), hh(19))
        inp:SetPlaceholderText("Введите запрос...")
        inp:SetTextColor(wh)
        inp:SetFont(FONT_SEARCH)
        inp:SetValue(stxt)
        inp.Paint = function(self, w, h)
            -- if search.PAGES_COUNT == 0 then return end
            surface.SetDrawColor(bh)
            surface.DrawRect(0, 0, w, h)
    
            if self:GetValue() ~= "" then self:DrawTextEntryText(wh, th, tc)
            elseif self:GetPlaceholderText() and self:GetPlaceholderText() ~= "" then
                local old = self:GetText()
                self:SetText(self:GetPlaceholderText())
                self:DrawTextEntryText(gr, th, tc)
                self:SetText(old)
            end
        end
    
        inp.OnEnter = function(self, val)
            navigate(val)
        end
    
        local webmats = gmlfi.vgui.webmats
        local nleft = vgui.Create("DButton", search)
        nleft:SetPos(ww(1010), hh(3))
        nleft:SetSize(ww(19), hh(19))
        nleft:SetText("")
        nleft.Paint = function(self, w, h)
            -- if search.PAGES_COUNT == 0 then return end
            local empty = search.PAGES_COUNT == 1
            surface.SetDrawColor(empty and bn or self:IsHovered() and bs or bh)
            surface.DrawRect(0, 0, w, h)
    
            surface.SetDrawColor(empty and gr or wh)
            surface.SetMaterial(webmats.navigate_left)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    
        nleft.DoClick = function()
            page = math.max(page - 1, 1)
            navigate()
        end
    
        local nmanual = vgui.Create("DButton", search)
        nmanual:SetPos(ww(1033), hh(3))
        nmanual:SetSize(ww(19), hh(19))
        nmanual:SetText("")
        nmanual.Paint = function(self, w, h)
            -- if search.PAGES_COUNT == 0 then return end
            local empty = search.PAGES_COUNT == 1
            surface.SetDrawColor(empty and bn or self:IsHovered() and bs or bh)
            surface.DrawRect(0, 0, w, h)
    
            surface.SetDrawColor(empty and gr or wh)
            surface.SetMaterial(webmats.navigate_manual)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    
        nmanual.DoClick = function()
            local d = DermaMenu()
            for k = 1, search.PAGES_COUNT do
                d:AddOption("#" .. tostring(k), function() page = k navigate() end)
            end
            d:Open()
        end
    
        local nright = vgui.Create("DButton", search)
        nright:SetPos(ww(1056), hh(3))
        nright:SetSize(ww(19), hh(19))
        nright:SetText("")
        nright.Paint = function(self, w, h)
            -- if search.PAGES_COUNT == 0 then return end
            local empty = search.PAGES_COUNT == 1
            surface.SetDrawColor(empty and bn or self:IsHovered() and bs or bh)
            surface.DrawRect(0, 0, w, h)
    
            surface.SetDrawColor(empty and gr or wh)
            surface.SetMaterial(webmats.navigate_right)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    
        nright.DoClick = function()
            page = math.min(page + 1, search.PAGES_COUNT)
            navigate()
        end
    
        navigate()
        main.SEARCH = search
    end)
    
    local _s2t = {
        ["ρ{(.+)}([0-9]+){([0-9]+)}"] = function(m) return string.format("%s [%s]", m[1], LFAdmin.GetSteamID(m[3]) or m[3]), {["term.player.name"] = m[1], ["term.player.id"] = LFAdmin.GetSteamID(m[3])} end,
        ["τ{(.+)}"] = function(m) return "[" .. m[1] .. "]" end,
    }
    
    net.Receive("LFAdmin.Logs", function()
        local main = LFAdmin.Logs.CurrentLogsPanel
        if not IsValid(main) then
            main = LFAdmin.Logs.CurrentLogsPanel
            if not IsValid(main) then return print("lmao currentlogspanel is nil") end
        end
    
        main.LogsChildren = main.LogsChildren or {}
        main.LogsLoading = false
        for k, v in ipairs(main.LogsChildren) do v:Remove() end
        if not net.ReadBool() then main.Logs404, main.SEARCH.PAGES_COUNT = net.ReadBool() and 1 or true, 0 return end
        
        local times, timed, kk, kh = {}, os.date("%d.%m.%Y"), 1, hh(6)
        main.SEARCH.PAGES_COUNT = net.ReadUInt(16)
        for k = 1, net.ReadUInt(16) do if kk > LFAdmin.Logs.PAGE_SIZE then break end kk = kk + 1
            local kitty, event, args, time = net.ReadString(), net.ReadString(), net.ReadBool() and net.ReadString() or "", net.ReadUInt(31)
            local term = LFAdmin.Logs.Terms[event] or string.format("WARNING: term \"%s\" does not exist! Please report this bug", event)
    
            local aargs, argsc, copy = {}, {}, {}
            for k, v in ipairs(string.Explode(";", args)) do
                local s = false
                for pattern, func in pairs(_s2t) do
                    local m = {string.match(v, pattern)}
                    if next(m) ~= nil then
                        local a, b = func(m)
                        aargs[k] = a
                        if b and next(b) ~= nil then copy[#copy + 1] = b end
                        s = true break
                    end
                end
                if not s then aargs[k] = v end
            end
    
            local _i = 0
            term = term:gsub("?", function(v)
                _i = _i + 1
                return aargs[_i]
            end)
    
            local tmd = os.date("%d.%m.%Y", time)
            if tmd ~= timed and not times[tmd] then
                local date = vgui.Create("DPanel", main)
                date:SetPos(ww(6), kh)
                date:SetSize(ww(1069), hh(19))
                date.Paint = function(self, w, h)
                    draw.SimpleText(tmd, FONT_LOG, ww(8), h / 2, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                kk, times[tmd], main.LogsChildren[#main.LogsChildren + 1] = kk + 1, true, date
                kh = kh + hh(24)
            end
    
            local pan--[[sexual]] = vgui.Create("DButton", main)
            pan:SetPos(ww(6), kh)
            pan:SetSize(ww(1069), hh(19))
            pan:SetText("")
            kh = kh + hh(24)
    
            local stime = os.date("%X", time)
            pan.Paint = function(self, w, h)
                surface.SetDrawColor(self:IsHovered() and bh or bi)
                surface.DrawRect(0, 0, w, h)
    
                draw.SimpleText(stime, FONT_LOG, ww(8), h / 2, gr, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(term, FONT_LOG, ww(72), h / 2, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
    
            pan.DoClick = function()
                local d = DermaMenu()
                d:AddOption(term, function() SetClipboardText("[" .. os.date("%H:%M:%S", time) .. "] " .. term) end):SetIcon("icon16/script_edit.png")
                d:AddOption(os.date("%X %d.%m.%Y")):SetIcon("icon16/time.png")
                d:AddSpacer()
                if next(copy) ~= nil then
                    local a, b = d:AddSubMenu("Копировать...")
                    b:SetIcon("icon16/page.png")
                    for kk, v in ipairs(copy) do
                        for term, val in pairs(v) do
                            a:AddOption((LFAdmin.Logs.Terms[term] or term) .. " #" .. kk .. ": " .. val, function() SetClipboardText(val) end):SetIcon("icon16/page_copy.png")
                        end
                    end
                end
                d:Open()
            end
    
            main.LogsChildren[#main.LogsChildren + 1] = pan
        end
    end)
end

LFAdmin.CommandDescription("logs", "Открывает логи сервера")
LFAdmin.CommandDescription("pe", "Открывает логи цели")