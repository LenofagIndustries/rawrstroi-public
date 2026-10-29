timer.Create("LFI:NETSpamProtection", 1, 0, function()
    for _, ply in ipairs(player.GetHumans()) do
        ply.NETsPerSecond = 0
    end
end)

local MaxNETsPerSecond = 1000

local goodnets = {
    ["editvariable"] = true,
    ["simfphys_mousesteer"] = true,
    ["simfphys_request_ppdata"] = true,
    ["MScoreBoard.ClientInfo"] = true
}

local cvar = CreateConVar("gmlfi_net_log", "0", FCVAR_NONE, "Log all nets", 0, 1)

net.Incoming = function(len, ply)
    if ply.KickForNETSpam then return end -- this can spam with kicks

    local name = util.NetworkIDToString(net.ReadHeader())
    if not name or not goodnets[name] then
        ply.NETsPerSecond = ply.NETsPerSecond ~= nil and ply.NETsPerSecond + 1 or 1
        if cvar:GetBool() and name and not goodnets[name] then print(string.format("[NETLOG] %s [%s] - %s", ply:Name(), ply:IPAddress(), name)) end
        if ply.NETsPerSecond >= MaxNETsPerSecond then
            print(string.format("Kicked %s [%s] for NET spamming%s", ply:Name(), ply:SteamID(), name and string.format(" [%s]", name) or ""))
            ply.KickForNETSpam = true
            --ply:Kick("Kicked for NET spamming" .. (name and string.format(" [%s]", name) or ""))
            gmnetwork.DisconnectClientSilent(ply:UserID()) -- thanks klenya uwu
        return end
    end
    
    if not name then return end

    local func = net.Receivers[string.lower(name)]
    if not func then return end

    len = len - 16 -- net.ReadHeader() = 16 bit
    func(len, ply)
end

hook.Add("PlayerInitialSpawn", "LFI:NETSpamProtection", function(ply)
    ply.NETsPerSecond = 0
    ply.KickForNETSpam = false
end)