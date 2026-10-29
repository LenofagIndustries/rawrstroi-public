util.AddNetworkString("LFI:PStatus")

gmlfi.pstatus = {}

--[[gmlfi.pstatus.es = {
    TABBED_OUT = 1,
    IN_EDITOR  = 2,
    IN_MENU    = 4,
}]]

gmlfi.pstatus.IsValid = function(s)
    --for k, v in pairs(gmlfi.pstatus.es) do if v == k then return true end end
    --return false
    return string.match(s, "^[0-1]+$") ~= nil
end

gmlfi.pstatus.SetStatus = function(ply, s) ply:SetNWString("LFI:PStatus", s) end

net.Receive("LFI:PStatus", function(_, ply)
    if not IsValid(ply) then return end
    local status = net.ReadString() if status == "" or not gmlfi.pstatus.IsValid(status) then return end
    gmlfi.pstatus.SetStatus(ply, status)
end)

-- user status cuz i don't want to restart and to make a new file

util.AddNetworkString("LFI:UserStatus")
sql.Query("CREATE TABLE IF NOT EXISTS gmlfi_UserStatus (SteamID TEXT NOT NULL PRIMARY KEY, `Text` TEXT NOT NULL)")

gmlfi.status = {}
gmlfi.status.Set = function(ply, text, silent)
    text = text and text ~= "" and utf8.sub(text, 1, 32)
    ply:SetNetVar("UserStatus", text)
    if not silent then
        print(string.format("%s [%s] changed their status to \"%s\"", ply:Name(), ply:SteamID(), text))
        if text then sql.QueryTyped("REPLACE INTO gmlfi_UserStatus (SteamID, `Text`) VALUES (?, ?)", ply:SteamID64(), text)
        else sql.QueryTyped("DELETE FROM gmlfi_UserStatus WHERE SteamID = ?", ply:SteamID64()) end
    end 
end

net.Receive("LFI:UserStatus", function(_, ply)
    local str = string.Trim(text)
    gmlfi.status.Set(str, true)
end)

hook.Add("PlayerAuthed", "LFI:UserStatus", function(ply)
    local d = sql.QueryTyped("SELECT `Text` FROM gmlfi_UserStatus WHERE SteamID = ?", ply:SteamID64())
    if d and next(d) then gmlfi.status.Set(ply, d[1].Text, true) end
end)