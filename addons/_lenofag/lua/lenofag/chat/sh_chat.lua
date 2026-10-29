if not gmlfi then return error("sh_chat says gmlfi is nil...") end

gmlfi.chat = gmlfi.chat or {}
gmlfi.chat.max = 600

local meta = FindMetaTable("Player")
function meta:IsTyping() return self:GetNWBool("LFI:Chat.Typing") end

gmlfi.radio = gmlfi.radio or {}
gmlfi.radio.channels = {
    ["default"] = {
        name = "Общий",
        icon = "icon16/world.png",
    },
    ["dispatch"] = {
        name = "Диспетчерская",
        icon = "icon16/user_suit.png",
    },
    ["admin"] = {
        name = "Админский",
        icon = "icon16/user_gray.png",
        access = "m",
    },
}

if CLIENT then
    concommand.Add("gmlfi_radio_toggle", function()
        net.Start("LFI:Radio")
        net.WriteBool(true)
        net.SendToServer()
    end)
end
