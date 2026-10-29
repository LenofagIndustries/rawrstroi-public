local log = function(...)
    chat.AddText(Color(50, 150, 255), "sv_antilag: ", Color(255, 255, 255), ...)
end

local actions = {
    [0] = function() log("resetting lag level...") end,
    -- [3] = function(a) if a == 0 then log("no e2s found, action skipped...") else log("stopping ", Color(200, 50, 50), tostring(a), Color(255, 255, 255), " e2s...") end end,
    -- [5] = function() log("freezing all entities") end,
    -- [7] = function() log("cleaning up map...") end,
    -- [10] = function() log("cleaning up map again...") end,
    [5] = function(a) if a == 0 then log("no e2s found, action skipped...") else log("stopping ", Color(200, 50, 50), tostring(a), Color(255, 255, 255), " e2s...") end end,
    [10] = function() log("freezing all entities") end,
    [15] = function() log("things are very bad, cleaning up map and resetting lag level...") end
}

net.Receive("LFI:Antilag", function()
    local action, opt = net.ReadInt(5), net.ReadInt(13)
    if actions[action] then actions[action](opt) end
end)

net.Receive("LFI:Antilag.Increase", function()
    local level = net.ReadInt(5)
    log("lag level increased, current level is ", Color(200, 50, 50), tostring(level))
end)

net.Receive("LFI:Antilag.BadPlayer", function()
    local ply, props = net.ReadEntity(), net.ReadUInt(14)
    log(team.GetColor(ply:Team()), ply:Name(), Color(255, 255, 255), " props are lagging (", Color(200, 50, 50), tostring(props), Color(255, 255, 255), " props in total)")
end)
