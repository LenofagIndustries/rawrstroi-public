if not gmlfi then return print("timeout.lua says gmlfi is nil...") end
gmlfi.timeout = {is = false, time = 0}

local wowalive = false
local IsAliveCheck = function()
    if string.find(game.GetIPAddress(), "0.0.0.0") then return print("Server is not authenticated on Steam, disconnecting"), RunConsoleCommand("disconnect") end
    http.Fetch(string.format("https://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=%s", game.GetIPAddress()), function(body)
        if not body then return end
        local data = util.JSONToTable(body) if not data or not data.response or not data.response.servers then return end
        if #data.response.servers >= 1 then print("Server was found on Steam, attempting to reconnect...") wowalive = true end
    end)
end

surface.CreateFont("LFI:Timeout.Title", {
    font = "Roboto",
    extended = true,
    size = 52,
    weight = 600,
    blursize = .5,
    shadow = true
})

surface.CreateFont("LFI:Timeout.Subtitle", {
    font = "Roboto",
    extended = true,
    size = 38,
    weight = 400,
    blursize = .5,
    shadow = true
})

surface.CreateFont("LFI:Timeout", {
    font = "Roboto",
    extended = true,
    size = 20,
    weight = 400,
    blursize = .5,
    shadow = true
})

local lasttime = false
local nexttime = CurTime()
hook.Add("Think", "LFI:Timeout", function()
    if nexttime > CurTime() then return end
    nexttime = CurTime() + 1 -- thanks yamirka uwu

    local is, time = GetTimeoutInfo()
    gmlfi.timeout = {is = is, time = time}

    if wowalive then RunConsoleCommand("retry") return end -- wait a few seconds before reconnecting

    if not lasttime and is then print("Client is timing out!") lasttime = true end
    if lasttime and not is then print("Connection to server restored!") lasttime = false end
    if time >= 30 then IsAliveCheck() end
end)

local blur = Material("pp/blurscreen")

hook.Add("HUDPaint", "LFI:Timeout", function()
    if not gmlfi.timeout.is or gmlfi.timeout.time < 10 then return end

    DisableClipping(true)
    surface.SetMaterial(blur)
    surface.SetDrawColor(255, 255, 255, 255)

    for i = 0.33, 1, 0.33 do
        blur:SetFloat("$blur", 5 * i)
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end

    surface.SetDrawColor(10, 10, 10, 250)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    DisableClipping(false)

    local time = math.abs(gmlfi.timeout.time)

    draw.SimpleText("Соединение потеряно", "LFI:Timeout.Title", ScrW() / 2, ScrH() / 2, Color(200, 200, 200, 200), TEXT_ALIGN_CENTER)
    draw.SimpleText(wowalive and "переподключаемся..." or string.format("%01d:%02d:%02d", math.floor(time / 3600), math.floor(time / 60) % 60, math.floor(time) % 60), "LFI:Timeout.Subtitle", ScrW() / 2, ScrH() / 1.8, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText(string.format("Присоединяйтесь к нашему Discord серверу: %s", gmlfi.discordDirect or gmlfi.discord), "LFI:Timeout", ScrW() / 2, ScrH() / 1.5, Color(200, 200, 200, 200), TEXT_ALIGN_CENTER)
end)
