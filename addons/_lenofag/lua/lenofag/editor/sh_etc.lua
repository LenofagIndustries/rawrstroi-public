local blocked = {
    drive = true,
    extinguish = true,
    ignite = true,
    motioncontrol_ragdoll = true,
    statue = true,
    statue_stop = true,
}

hook.Add("CanProperty", "LFI:Properties", function(ply, pr)
    if blocked[pr] then return false end
end)

-- ./server/sv_geolocation.lua
gmlfi.nw.Register("GeoIP",
    function(data)
        local c = tobool(data.city)
        net.WriteBool(c)
        if c then net.WriteString(data.city) end
        net.WriteString(data.country)
        net.WriteString(data.flag)
    end,
    function()
        return {
            city = net.ReadBool() and net.ReadString(),
            country = net.ReadString(),
            flag = net.ReadString()
        }
    end
)

do -- stolen from scuroinside once again
    jit.off()
    jit.flush()
    jit.on()

    -- local function InitPhysics()
    --     local vars = {
    --         LookAheadTimeObjectsVsObject = .5,
    --         LookAheadTimeObjectsVsWorld = 1,
    --         MaxCollisionChecksPerTimestep = 50000,
    --         MaxCollisionsPerObjectPerTimestep = 10,
    --         MaxFrictionMass = 2500,
    --         MinFrictionMass = 10,
    --         MaxAngularVelocity = 7272.7280273438,
    --         MaxVelocity = 4000,
    --         -- AirDensity = 0,
    --         -- Gravity = Vector(0, 0, -600),
    --     }
    --     physenv.SetPerformanceSettings(vars)
    --     -- physenv.SetAirDensity(vars.AirDensity)
    --     -- physenv.SetGravity(vars.Gravity)
    -- end

    local run do
        local gc = collectgarbage
        local limit, rate = 1 / 300, 1 / 33

        gc'stop'
        local function _gc(co)
            local kb = gc'count'
            if kb < 512 then return end
            if kb > 1e+6 then return gc() end
            while gc('step', 1) and gc'count' ~= 0 do co:limit(limit) end
        end

        local yield = coroutine.yield
        local create = coroutine.create
        local resume = coroutine.resume
        local status = coroutine.status
        local call = hook.Run
        local format, wait, unpack, start =
            string.format, coroutine.wait, unpack, 0
        local mt = {
            __index = {
            name = 'NULL', id = -1, fn = function() end,
            Remove = function(self) timer.Remove(self.id) end,
            wait = function(self, c) wait(c) end,
            yield = function(self, ...) yield(...) end,
            limit = function(self, c, ...)
                if CurTime() - start >= c then return yield(...) end
            end,
            status = function(self) return status(self.thread) end,
            wrap = function(self)
                self.thread = create(self.fn)
                return function()
                    if status(self.thread) == 'dead' then
                        self:Remove()
                        return call('ThreadEnded', self.name)
                    end
                    start = CurTime()
                    
                    local succ, err = resume(self.thread, self, unpack(self))
                    if succ == false then Error(err) end
                end
            end}}

        local function NewThread(name, rate, fn, ...)
            if call('ThreadRunning', name) ~= false then
                local id = format('ThreadObject::%s', name)
                local obj = setmetatable({fn = fn, name = name, id = id, start = CurTime(), ...}, mt)
                timer.Create(id, rate, 0, obj:wrap())
                return obj
            end
        end

        function run()
            NewThread('CollectGarbage', rate, _gc)
        end

        concommand.Add('gc', run)
    end

    timer.Create('CollectGarbage::Passive', 30, 0, run)
    timer.Create('CollectGarbage::Full', 3600, 0, collectgarbage)
    -- timer.Simple(1, InitPhysics)
end