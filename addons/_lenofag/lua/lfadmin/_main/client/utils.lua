local types = {
    Entity = "Entity",
    Player = "Entity",
    number = {"Int", 32},
    string = "String",
}

net.Receive("LFAdmin.Log", function()
    LFAdmin.LOG_TIME = net.ReadUInt(32)
    if net.ReadBool() then LFAdmin.CHAT_PREFIX = net.ReadString() end
    LFAdmin.ADMIN_ONLY = net.ReadBool()
    if net.ReadBool() then
        local tbl, ty = {}, string.Explode(",", net.ReadString())
        for k = 1, #ty do
            local v = ty[k]
            if string.sub(v, 1, 1) == "#" then
                local t = {} for i = 1, tonumber(string.sub(v, 2)) do t[i] = net.ReadEntity() end
                tbl[k] = t
            else
                local tt = types[v]
                tbl[k] = net["Read" .. (tt and (type(tt) == "table" and tt[1] or tt) or "String")](type(tt) == "table" and tt[2])
            end
        end
        
        LFAdmin.LogFormat(unpack(tbl))
    else LFAdmin.Log(net.ReadString()) end
    LFAdmin.ADMIN_ONLY, LFAdmin.CHAT_PREFIX, LFAdmin.LOG_TIME, LFAdmin.CHAT_PREFIX_LAST, LFAdmin.LOG_TIME_LAST = nil, nil, nil, LFAdmin.CHAT_PREFIX, LFAdmin.LOG_TIME
end)
