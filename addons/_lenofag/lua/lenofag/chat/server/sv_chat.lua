if not gmlfi then return print("sv_chat says gmlfi is nil...") end

gmlfi.chat.next = 1
gmlfi.chat.detourphrase = "!?gmlfi?!"

util.AddNetworkString("LFI:Chat")
util.AddNetworkString("LFI:Chat.Typing")

gmlfi.chat.Say = function(who, text, isteam)
    local isplayer = IsValid(who) and who:IsPlayer()

    if isplayer then
        local no = hook.Run("PlayerSay", who, text, isteam, true)
        if not no or string.Trim(no) == "" then return elseif no and string.Trim(no) ~= "" then text = no end
    end

    hook.Run("player_say", {priority = 1, userid = isplayer and who:UserID() or 0, text = text}, gmlfi.chat.detourphrase) -- gameevent

    print(string.format("[%s]%s: %s", isplayer and who:GetUserGroup() or "Console", isplayer and " " .. who:Name() or "", text))

    net.Start("LFI:Chat")
    net.WriteEntity(isplayer and who or game.GetWorld())
    net.WriteString(text)
    net.WriteBool(isteam or false)
    net.Broadcast()
end

net.Receive("LFI:Chat", function(_, ply)
    if not gmlfi.IsHuman(ply) then return end
    if ply.LFICHATPREV and ply.LFICHATPREV + gmlfi.chat.next > os.time() then return end

    ply.LFICHATPREV = os.time()

    local text, isteam = net.ReadString(), net.ReadBool()
    if not text or string.Trim(text) == "" then return end
    text = utf8.sub(text, 1, gmlfi.chat.max)
    gmlfi.chat.Say(ply, text, isteam)
end)

net.Receive("LFI:Chat.Typing", function(_, ply) ply:SetNWString("LFI:Chat.Typing", net.ReadBool()) end)

hook.Add("PlayerSay", "LFI:Chat", function(a, b, c, lfi)
    if not lfi then gmlfi.chat.Say(a, b, c) return "" end
end)

--[[gameevent.Listen("player_say") -- concommand.Add("say", ...) didn't work ;(
hook.Remove("player_say", "LFI:Chat.Detour", function(data, hilfi)
    if hilfi == gmlfi.chat.detourphrase then return end

    local isconsole, text, ply = data.userid == 0, data.text, NULL
    if not text or string.Trim(text) == "" then return end
    if not isconsole then ply = Player(data.userid) end
    if not isconsole and not gmlfi.IsHuman(ply) then return end
    if ply.LFICHATPREV + gmlfi.chat.next > os.time() then return end

    ply.LFICHATPREV = os.time()
    text = string.sub(text, 1, gmlfi.chat.max)
    gmlfi.chat.Say(ply, text, false)
end)]]
