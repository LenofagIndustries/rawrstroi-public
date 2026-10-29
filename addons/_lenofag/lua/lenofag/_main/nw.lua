gmlfi.nw = gmlfi.nw or {s = {_G = {}}, r = {}}
-- maybe pasted a little from superior servers (plib/dash nw.lua)
-- but mostly ideas

local ENTITY = FindMetaTable("Entity")
function ENTITY:GetNetVar(name, def)
    local e = gmlfi.nw.s[self:EntIndex()]
    if e and e[name] ~= nil then return e[name] end
    return def
end

gmlfi.nw.Get = function(name, def)
    local g = gmlfi.nw.s._G[name]
    if g ~= nil then return g end
    return def
end

gmlfi.nw.Register = function(name, write, read, filter)
    gmlfi.nw.r[name] = {Write = write, Read = read, Filter = filter}
end

if SERVER then
    util.AddNetworkString("LFI:NW")

    gmlfi.nw.Send = function(ply, name, val, self) local iv = IsValid(self)
        local reg = gmlfi.nw.r[name]
        net.Start("LFI:NW")
            net.WriteBool(iv)
            if iv then net.WriteUInt(self:EntIndex(), 13) net.WriteBool(false) end
            net.WriteString(name)
            net.WriteBool(val == nil)
            if val ~= nil then if reg and reg.Write then reg.Write(val) else net.WriteType(val) end end -- bad syntax ig idc
        if reg and reg.Filter then net.Send(reg.Filter(self))
        else net[ply and "Send" or "Broadcast"](ply) end
    end

    gmlfi.nw.Set = function(name, val)
        gmlfi.nw.s._G[name] = val
        gmlfi.nw.Send(nil, name, val)
    end

    function ENTITY:SetNetVar(name, val)
        local target = gmlfi.nw.s[self:EntIndex()] or {}
        gmlfi.nw.s[self:EntIndex()] = target
        target[name] = val
        if next(target) == nil then gmlfi.nw.s[self:EntIndex()] = nil end

        gmlfi.nw.Send(nil, name, val, self)
    end

    hook.Add("PlayerAuthed", "LFI:NW", function(ply)
        for entx, vars in pairs(gmlfi.nw.s) do
            local ent = isnumber(entx) and Entity(entx) or entx
            for var, v in pairs(vars) do
                gmlfi.nw.Send(ply, var, v, ent)
            end
        end
    end)

    hook.Add("EntityRemoved", "LFI:NW", function(ent)
        gmlfi.nw.s[ent:EntIndex()] = nil
        net.Start("LFI:NW")
            net.WriteBool(true)
            net.WriteUInt(ent:EntIndex(), 13)
            net.WriteBool(true)
        net.Broadcast()
    end)
else
    net.Receive("LFI:NW", function()
        local e = net.ReadBool() and net.ReadUInt(13) or "_G"
        if e ~= "_G" and net.ReadBool() then gmlfi.nw.s[e] = nil return end
        gmlfi.nw.s[e] = gmlfi.nw.s[e] or {}
        local sn, isnil = net.ReadString(), net.ReadBool()
        if isnil then gmlfi.nw.s[e][sn] = nil
        else local reg = gmlfi.nw.r[sn] gmlfi.nw.s[e][sn] = reg and reg.Read and reg.Read() or net.ReadType() end
    end) 
end
