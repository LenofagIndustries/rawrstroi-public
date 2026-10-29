timer.Create("LFI:Timeout", 1, 0, function()
    for k, v in ipairs(player.GetHumans()) do
        if not v._LFITIMEOUT and v:IsTimingOut() then v._LFITIMEOUT = true v:SetNWBool("LFI:Timeout", true) print(string.format("%s is timing out!", v:Name())) end
        if v._LFITIMEOUT and not v:IsTimingOut() then v._LFITIMEOUT = false v:SetNWBool("LFI:Timeout", false) print(string.format("%s resumed connection", v:Name())) end
    end
end)
