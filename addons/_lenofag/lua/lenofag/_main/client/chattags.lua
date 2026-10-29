hook.Add("OnPlayerChat", "LFI:ChatTags", function(ply, text, teamc)
    text = string.Trim(text) if text == "" then return true end
    if ply and IsValid(ply) and ply:IsPlayer() and not ply:GetNWBool("LFI:Hide", false) then
        chat.AddText(
            Color(60, 60, 60), "[", team.GetColor(ply:Team()), team.GetName(ply:Team()), Color(60, 60, 60), "]",
            Color(255, 255, 255), " " .. ply:Name(), ": ", text
        )
    else
        chat.AddText(gmlfi.ChatTag("Консоль", "console"), " ", text)
    end
    chat.PlaySound()
    return true
end)

hook.Add("LFI:Chat.Loaded", "LFI:ChatTags", function()
    local bl = Color(0, 0, 0)
    local tag = function(col, tcol)
        return {
            ["background-color"] = col:ToHex() .. "88",
            ["color"] = tcol and tcol:ToHex(),
            ["text-shadow"] = tcol and "none",
        }
    end
    gmlfi.chat.AddStyle({
        [".chattag"] = {
            ["padding"] = ".1em .25em",
            ["border-radius"] = "0",
            ["line-height"] = "1.4em",
            ["border"] = "1px solid black",
            ["transition"] = ".5s",
        },

        [".connect"] = tag(Color(69, 177, 69), bl),
        [".connect-d"] = tag(Color(174, 68, 68)),

        [".discord"] = tag(Color(88, 101, 242)),
        [".msalert"] = tag(Color(242, 152, 88), bl),
        [".console"] = tag(Color(200, 200, 200), bl),

        [".znotify"] = {
            ["border-radius"] = "50%",
            ["background-color"] = Color(50, 150, 255):ToHex() .. "88",
            ["padding"] = ".1em .5em !important",
        },

        [".invisible"] = {
            ["visibility"] = "hidden"
        }
    })
end)

gmlfi.ChatTag = function(text, class, ...) return {class = {"chattag", class, ...}, text = text, html = ""} end

if gmlfi.chat and IsValid(gmlfi.chat.HTML) then hook.GetTable()["LFI:Chat.Loaded"]["LFI:ChatTags"]() end