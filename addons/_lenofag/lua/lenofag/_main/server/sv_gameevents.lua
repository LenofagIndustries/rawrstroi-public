local states = {
    [SIGNONSTATE_NONE] = "SIGNONSTATE_NONE",
    [SIGNONSTATE_CHALLENGE] = "SIGNONSTATE_CHALLENGE",
    [SIGNONSTATE_CONNECTED] = "SIGNONSTATE_CONNECTED",
    [SIGNONSTATE_NEW] = "SIGNONSTATE_NEW",
    [SIGNONSTATE_PRESPAWN] = "SIGNONSTATE_PRESPAWN",
    [SIGNONSTATE_SPAWN] = "SIGNONSTATE_SPAWN",
    [SIGNONSTATE_FULL] = "SIGNONSTATE_FULL",
    [SIGNONSTATE_CHANGELEVEL] = "SIGNONSTATE_CHANGELEVEL"
}
hook.Add("ClientSignOnStateChanged", "LFI:Connect", function(uid, old, new)
    print(string.format("[ClientSignOnStateChanged] %s: %s -> %s", uid, states[old] or "UNKNOWN", states[new] or "UNKNOWN"))
end)

gameevent.Listen("server_cvar")
hook.Add("server_cvar", "LFI:Logs", function(data)
    print(string.format("\"%s\" changed value to \"%s\"", data.cvarname, data.cvarvalue))
end)