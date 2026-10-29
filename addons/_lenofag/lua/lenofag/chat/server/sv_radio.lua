util.AddNetworkString("LFI:Radio")

local secrets = {
    ["lenofag"] = "*",
}

local setRadio = function(ply, old, channel)
    ply.LFRadio = channel
    ply:SetNWString("LFI:Radio", channel)
    ply:EmitSound("ambient/levels/prison/radio_random" .. math.random(11, 15) .. ".wav")
    LFAdmin.LogPlayerPrefixed(ply, "radio", "Вы подключились к каналу \"", "#" .. channel, "\"")
    if not secrets[channel] then LFAdmin.LogPlayerPrefixed(NULL, "radio", ply, " подключился к каналу рации \"", "#" .. channel, "\"") end
    print(string.format("%s [%s] joined channel \"%s\"", ply:Name(), ply:SteamID(), channel))
    if not ply.LFRadioNext or ply.LFRadioNext < CurTime() then
        ply.LFRadioNext = CurTime() + 2
        local t = {}
        local t2 = {}
        for k, v in ipairs(player.GetAll()) do
            if v == ply then continue end
            if not gmlfi.radio.channels[channel] and v.LFRadio == channel then t[#t + 1] = v end
            if old and not gmlfi.radio.channels[old] and v.LFRadio == old then t2[#t2 + 1] = v end
        end
        LFAdmin.LogPlayerPrefixed(t, "radio", ply, " подключился к вашему каналу")
        LFAdmin.LogPlayerPrefixed(t2, "radio", ply, " отключился от вашего канала")
    end
end

net.Receive("LFI:Radio", function(_, ply)
    if net.ReadBool() then
        ply.LFRadioNoTalk = not ply.LFRadioNoTalk
        ply:EmitSound("ambient/levels/prison/radio_random" .. math.random(7, 10) .. ".wav")
        LFAdmin.LogPlayerPrefixed(ply, "radio", "Вы ", "#" .. (ply.LFRadioNoTalk and "выключили" or "включили"), " передачу рации")
    return end
    local old = ply.LFRadio
    local channel = net.ReadString()
    if old == channel then return end
    local ch = gmlfi.radio.channels[channel]
    if ch and ch.access and not ply:HasAccess(ch.access) then return LFAdmin.LogPlayerPrefixed(ply, "radio", "Доступ к каналу разрешен с флагом \"", "#" .. ch.access, "\"") end
    if secrets[channel] and not ply:HasAccess(secrets[channel]) then return LFAdmin.LogPlayerPrefixed(ply, "radio", "Загадочные помехи мешают подключиться к каналу") end
    setRadio(ply, old, channel)
end)

local TALK_NEAR = 500 ^ 2

hook.Add("PlayerCanHearPlayersVoice", "LFI:Radio", function(to, from)
    if LFAdmin then
        local gagged = LFAdmin.GetSteamIDTimedVar(from, "LFAGAGGED")
        if gagged and (gagged == true or gagged > CurTime()) then return false, false end
    end

    local cf, ct = from.LFRadio or "default", to.LFRadio or "default"
    local near = (cf ~= ct or from.LFRadioNoTalk) and from:GetPos():DistToSqr(to:GetPos()) <= TALK_NEAR
    return (not from.LFRadioNoTalk and cf == ct) or near, near
end)

gmlfi.radio.GetMembers = function(r)
    local p = {}
    for k, v in ipairs(player.GetAll()) do
        if (v.LFRadio or "default") == r then p[#p + 1] = v end
    end
    return p
end

gmlfi.radio.ChangeChannel = function(ply, ch) setRadio(ply, ply.LFRadio, ch) end
gmlfi.radio.secrets = secrets