if SERVER then
    util.AddNetworkString("LFI:Metro.Alert")

    hook.Add("MetrostroiPlombBroken", "LFI:Metro.Alert", function(ent, name, ply)
        net.Start("LFI:Metro.Alert")
            net.WriteString("seal")
            net.WriteString(name)
            net.WriteEntity(ply)
        net.Broadcast()
        gmlfi.metro.Log("%s broke seal on %s!", tostring(ply), name or "[unknown]")
        return true
    end)

    hook.Add("MetrostroiPassedRed", "LFI:Metro.Alert", function(ent, ply, _, ars)
        if ply:IsSuperAdmin() then return true end
        net.Start("LFI:Metro.Alert")
            net.WriteString("red")
            net.WriteString(ars.Name or "[неизвестно]")
            net.WriteEntity(ply)
            if ars.InvationSignal and type(ars.InvationSignal) == "string" and ars.InvationSignal ~= "" then net.WriteString(ars.InvationSignal) end
        net.Broadcast()
        gmlfi.metro.Log("%s passed prohibited%ssignal [%s]!", tostring(ply), ars.InvationSignal and ars.InvationSignal ~= "" and ars.InvationSignal or " ", ars.Name or "[unknown]")
        return true
    end)

    hook.Add("MetrostroiPowerSwitched", "LFI:Metro.Alert", function(switch, ply)
        net.Start("LFI:Metro.Alert")
            net.WriteString("power")
            net.WriteBool(switch)
            net.WriteEntity(ply)
        net.Broadcast()
        gmlfi.metro.Log("%s switched power %s!", tostring(ply), switch and "on" or "off")
    end)
end

if CLIENT then
    local color_white, color_default = Color(255, 255, 255), Color(50, 150, 255)
    local alerts = {
        ["seal"] = function()
            local name, ply = net.ReadString(), net.ReadEntity()
            if not IsValid(ply) or not ply:IsPlayer() then return end
            chat.AddText(gmlfi.ChatTag("Metrostroi", "msalert"), " ", team.GetColor(ply:Team()), ply:Name(), color_white, " сорвал пломбу с ", color_default, name or "[неизвестно]", color_white, "!")
        end,
        ["red"] = function()
            local name, ply = net.ReadString(), net.ReadEntity(), net.ReadString()
            if not IsValid(ply) or not ply:IsPlayer() then return end
            chat.AddText(gmlfi.ChatTag("Metrostroi", "msalert"), " ", team.GetColor(ply:Team()), ply:Name(), color_white, " проехал на запрещающий", color_default, inv and inv ~= "" and " " .. inv or "", color_white, " сигнал [", color_default, name, color_white, "]!")
        end,
        ["power"] = function()
            local switch, ply = net.ReadBool(), net.ReadEntity()
            if not IsValid(ply) or not ply:IsPlayer() then return end
            chat.AddText(gmlfi.ChatTag("Metrostroi", "msalert"), " ", team.GetColor(ply:Team()), ply:Name(), color_white, " в", switch and "" or "ы", "ключил напряжение!")
        end
    }
    net.Receive("LFI:Metro.Alert", function()
        local alert = net.ReadString()
        if alerts[alert] then alerts[alert]() end
    end)
end
