--net.Receive("LFI:Status", function() chat.AddText(Color(255, 255, 255), "Your status was successfully changed to ", Color(50, 150, 255), net.ReadString() or "") end)
--net.Receive("LFI:Status.Error", function() chat.AddText(Color(255, 255, 255), "Invalid status text!") end)

local TABBED_OUT    = 1
local IN_EDITOR     = 2
local IN_MENU       = 3
local IN_SCOREBOARD = 4

gmlfi.pstatus = {
    current = {
        [TABBED_OUT]        = false,
        [IN_EDITOR]         = false,
        [IN_MENU]           = false,
        [IN_SCOREBOARD]     = false,
    },
    enums = {
        TABBED_OUT       = TABBED_OUT,
        IN_EDITOR        = IN_EDITOR,
        IN_MENU          = IN_MENU,
        IN_SCOREBOARD    = IN_SCOREBOARD,
    }
}

gmlfi.pstatus.Construct = function()
    local ret = ""
    for k, v in ipairs(gmlfi.pstatus.current) do ret = ret .. (v and "1" or "0") end
    return ret
end

gmlfi.pstatus.Deconstruct = function(s)
    local ret = {}
    for k, v in ipairs(string.Explode("", s)) do ret[k] = v == "1" end
    return ret
end

timer.Create("LFI:PStatus", .5, 0, function()
    gmlfi.pstatus.current = {
        [TABBED_OUT]    = not system.HasFocus(),
        [IN_EDITOR]     = gmlfi.editor and IsValid(gmlfi.editor.panels.frame) and gmlfi.editor.panels.frame:IsVisible(),
        [IN_MENU]       = gui.IsGameUIVisible(),
        [IN_SCOREBOARD] = gmlfi.score and IsValid(gmlfi.score.Frame)
    }

    net.Start("LFI:PStatus")
    net.WriteString(gmlfi.pstatus.Construct())
    net.SendToServer()
end)
