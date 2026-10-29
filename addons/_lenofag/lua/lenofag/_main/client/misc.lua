print([[
                         __                     ____                             
   ____ _ ____ ___      / /___   ____   ____   / __/____ _ ____ _    _____ __  __
  / __ `// __ `__ \    / // _ \ / __ \ / __ \ / /_ / __ `// __ `/   / ___// / / /
 / /_/ // / / / / /_  / //  __// / / // /_/ // __// /_/ // /_/ /_  / /   / /_/ / 
 \__, //_/ /_/ /_/(_)/_/ \___//_/ /_/ \____//_/   \__,_/ \__, /(_)/_/    \__,_/  
/____/                                                  /____/                   
]])

math.FastMull = function()  while 1    +  1  ==  2  do  PrintTable( _G or _G  )   end    end -- lol XD

local wh, colm = Color(255, 255, 255), Color(50, 150, 255)
local notifies = {
    {"Присоединяйтесь к нашему Discord серверу! ", colm, gmlfi.discordDirect, wh, " или ", colm, gmlfi.discord},
    {"Присоединяйтесь к нашей группе Steam! ", colm, gmlfi.steamGroup},
    {"Контент сервера доступен по ссылке: ", colm, gmlfi.serverContent},
    {"Ники над головой можно выключить, используя команду ", colm, "gmlfi_nametags_enabled 0", wh, " в консоли"},
    {"Вы можете отобразить все эти напоминания, используя команду ", colm, "gmlfi_notify_force_all", wh, " в консоли, а также зажав ", colm, "С", wh, " и выбрав ", colm, "Утилиты... -> Напоминания в чате"},
    {"Потеряли состав? Используйте ", colm, "!traintp", wh, " в чате чтобы телепортироваться в него"},
    {"Хотите сменить карту? Используйте ", colm, "!rtv", wh, " в чате чтобы начать голосование за смену карты"},
    {"Не можете вспомнить код станции? Используйте ", colm, "!stations", wh, " в чате для открытия меню станций"},
    {"Чтобы замутить игроков, откройте ", colm, "Tab", wh, " и нажмите на иконку динамика у нужного вам игрока, или верхнюю иконку чтобы замутить всех"},
    {"Правила нашего сервера доступны по ссылке: ", colm, gmlfi.rulesURL},
    {"Сервер перезапускается автоматически днем в ", colm, "12:00", wh, " и ночью в ", colm, "3:00", wh, " по московскому времени"},
    {"Если вы не хотите, чтобы к вам телепортировались игроки, напишите ", colm, "!blockgoto", wh, " в чат"},
    {"По всем вопросам, предложениям и жалобам обращайтесь на наш Discord сервер в канал ", colm, "#requests"},
    {"Для получения списка доступных команд, напишите ", colm, "!help", wh, " в чат"},
    {"Вы можете говорить в голосовые каналы рации, зажав ", colm, "C", wh, " и подключившись к каналу в разделе ", colm, "Каналы рации"},
    {"Вы можете изменить вид чата, нажав на кнопку ", colm, "шестеренки", wh, " в верхнем правом углу окна чата"},
    {"Для быстрого переключения третьего лица, вы можете сделать bind на команду ", colm, "simple_thirdperson_enable_toggle", wh, " (например, ", colm, "bind t simple_thirdperson_enable_toggle", wh, ")"},
    {"Для выдачи доступа к составу, зажмите ", colm, "Q", wh, ", нажмите ", colm, "Утилиты -> NADMOD Prop Protection -> Client", wh, ", выберите нужных игроков и нажмите ", colm, "Apply Friends"},
    {"Вы можете включить снег, используя команду ", colm, "gmlfi_snow 1", wh, " в консоли"},
    {"Чтобы получить случайное имя, используйте ", colm, "!randomname", wh, " в чат, аналогично можно установить и свое локальное имя через команду ", colm, "!name"},
    {"Вы можете поддержать работу сервера донатом, используя команду ", colm, "!donate", wh, " в чат"},
    -- {"У нас есть второй сервер, для подключения используйте команду ", colm, "connect 212.113.121.104:27015", wh, " в консоли"},
}

gmlfi._SendNotifies = notifies
gmlfi.SendNotify = function(n) chat.AddText(gmlfi.ChatTag("?", "znotify"), " ", wh, unpack(notifies[n or math.random(#notifies)])) if not n then timer.Adjust("LFI:Notify", math.random(180, 900)) end end

concommand.Add("gmlfi_notify_force", function(_, _, a) gmlfi.SendNotify(tonumber(a[1])) end)
concommand.Add("gmlfi_notify_force_all", function() for k = 1, #notifies do gmlfi.SendNotify(k) end end)
timer.Create("LFI:Notify", 300, 0, gmlfi.SendNotify)

net.Receive("LFI:Reputation", function()
    local who, up, me = net.ReadEntity(), net.ReadBool(), net.ReadBool()
    if not who or not IsValid(who) then return end print("passed")

    local c = up and Color(100, 255, 100) or Color(255, 100, 100)
    if me then chat.AddText(wh, "Вы дали ", team.GetColor(who:Team()), who:Name(), " ", c, up and "положительную" or "отрицательную", wh, " репутацию")
    else chat.AddText(team.GetColor(who:Team()), who:Name(), wh, " дал вам ", c, up and "положительную" or "отрицательную", wh, " репутацию") end
end)

net.Receive("LFI:Reputation.CD", function()
    local t = net.ReadString() if t == "" then return end t = tonumber(t) if t == 0 then return end
    chat.AddText(wh, "Вы сможете выдать репутацию через ", colm, string.NiceTime(t - os.time()))
end)

CreateClientConVar("gmlfi_bunnyhop", 0, true, false, "Toggle bunnyhop", 0, 1)
gmlfi.bunnyhop = gmlfi.bunnyhop or GetConVar("gmlfi_bunnyhop"):GetBool() or false
cvars.AddChangeCallback("gmlfi_bunnyhop", function(_, _, new)
    gmlfi.bunnyhop = new == "1" and true or false
end)

local lp = LocalPlayer()
local badgmt = {[MOVETYPE_OBSERVER] = true, [MOVETYPE_NOCLIP] = true, [MOVETYPE_LADDER] = true}
hook.Add("CreateMove", "LFI:Bunnyhop", function(ucmd)
    if not lp or not IsValid(lp) then lp = LocalPlayer() end if not lp or not IsValid(lp) then return end
    if gmlfi.bunnyhop and not badgmt[lp:GetMoveType()] and lp:Alive() and lp:WaterLevel() == 0 and not lp:IsOnGround() then
        if ucmd:KeyDown(IN_JUMP) then ucmd:RemoveKey(IN_JUMP) end
    end
end)

local mat = "particles/balloon_bit"
game.AddParticles(mat)

CreateClientConVar("gmlfi_snow", 0, true, false, "Toggle snow particles", 0, 1)

local snow = GetConVar("gmlfi_snow"):GetBool()
cvars.AddChangeCallback("gmlfi_snow", function(_, old, new)
    snow = new ~= "0"
    print(string.format("Snow is now %s", snow and "enabled" or "disabled"))
end)

timer.Create("LFI:Snow.WaitForLocalPlayer", 1, 0, function()
    local lp = LocalPlayer()
    if not lp or not IsValid(lp) or not lp:IsPlayer() then return end timer.Remove("LFI:Snow.WaitForLocalPlayer")
    local pos = lp:GetPos()
    local emitter = ParticleEmitter(pos)

    timer.Create("LFI:Snow", .5, 0, function()
        if not snow then return end
        pos = lp:GetPos()
        if not util.IsSkyboxVisibleFromPoint(pos) then return end
        for k = 1, 500 do
            local partpos = pos + Vector(math.random(-5000, 5000), math.random(-5000, 5000), math.random(800, 1000))
            --if util.IsInWorld(partpos) then continue end
            local part = emitter:Add(mat, partpos)
            if part then
                part:SetDieTime(10)
                part:SetStartAlpha(255)
                part:SetEndAlpha(0)

                part:SetStartSize(math.random(3, 6))
                part:SetEndSize(0)
                part:SetCollide(true)
                --part:SetBounce(.05)

                part:SetGravity(Vector(50, 50, -300))
                part:SetVelocity(Vector(math.random(-50, 50), math.random(-50, 50), -200))
            end
        end
    end)
end)
