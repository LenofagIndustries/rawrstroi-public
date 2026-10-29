LFAdmin.Command("spectate", "t", {"player?"}, function(activator, target)
    if not IsValid(activator) then return end
    activator.LFAdminSpectate = target or true
    activator.LFAdminSpectatePos = (target or activator):GetPos()
    net.Start("LFAdmin.Spectate")
        net.WriteBool(true)
        if target then net.WriteEntity(target) end
    net.Send(activator)
    LFAdmin.LogPlayer(activator, "Вы вошли в режим слежки ", target and "за " or "", target or "")
end)

local NEAR_DIST = 500 ^ 2
LFAdmin.Command("near", "s", {}, function(activator)
    if LFAdmin.IsConsole(activator) then return end
    local pos, found = activator:GetPos()
    for k, v in ipairs(player.GetAll()) do
        if v == activator then continue end
        local s = v.LFAdminSpectate
        local d1, d2 = s and v.LFAdminSpectatePos:DistToSqr(pos), v:InAdminMode() and v:GetPos():DistToSqr(pos)
        local m1, m2, m3 = s and v.LFAdminSpectate == activator, d1 and d1 <= NEAR_DIST, d2 and d2 <= NEAR_DIST
        if m1 or m2 or m3 then
            if not found then found = true LFAdmin.LogPlayer(activator, "Игроки поблизости:") end
            LFAdmin.LogPlayer(activator, v)
            if m1 then LFAdmin.LogPlayer(activator, " - следит за Вами") end
            if m2 and not m1 then LFAdmin.LogPlayer(activator, " - в режиме слежки на расстоянии ", math.floor(math.sqrt(d1)), " юнитов") end
            if m3 then LFAdmin.LogPlayer(activator, " - в режиме администратора на расстоянии ", math.floor(math.sqrt(d2)), " юнитов") end
        end
    end
    if not found then LFAdmin.LogPlayer(activator, "Игроков поблизости не найдено") end
end)

LFAdmin.CommandDescription("spectate", "Вход в режим слежки")
LFAdmin.CommandDescription("near", "Показывает игроков в режиме администратора и слежки в области " .. math.sqrt(NEAR_DIST) .. " юнитов")

if SERVER then
    util.AddNetworkString("LFAdmin.Spectate")
    net.Receive("LFAdmin.Spectate", function(_, ply)
        if not ply.LFAdminSpectate then return end
        if net.ReadBool() then
            ply.LFAdminSpectate = nil
            if net.ReadBool() then
                if not ply:Alive() then ply:Spawn() end
                ply:SetPos(ply.LFAdminSpectatePos)
                ply:SetVelocity(net.ReadVector())
            end
            net.Start("LFAdmin.Spectate")
                net.WriteBool(false)
            net.Send(ply)
        else
            local t = net.ReadBool() and net.ReadEntity() or net.ReadVector()
            if isentity(t) and not IsValid(t) then ply.LFAdminSpectate = true
            elseif IsValid(t) then ply.LFAdminSpectate = t
            else ply.LFAdminSpectatePos = t end
        end
    end)

    hook.Add("SetupPlayerVisibility", "LFAdmin.Spectate", function(ply)
        local target = ply.LFAdminSpectate
        if target then
            local ie = target ~= true
            if ie and not IsValid(target) then ply.LFAdminSpectate, target, ie = true, true, false end -- best place for it :100:
            AddOriginToPVS(ie and target:GetPos() or ply.LFAdminSpectatePos or ply:GetPos())
        end
    end)

    -- metrostroi server currently doesn't have radio or anything
    -- hook.Remove("PlayerCanHearPlayersVoice", "LFAdmin.Spectate", function(ply, talker)
    --     if ply.LFAdminSpectate and talker:GetPos():DistToSqr(ply.LFAdminSpectatePos) <= 150000 then
    --         return true, true
    --     end
    -- end)
else
    net.Receive("LFAdmin.Spectate", function()
        if not net.ReadBool() then LFAdmin.Spectating = nil return end
        local t = net.ReadEntity()
        LFAdmin.Spectating = IsValid(t) and t or true
        LFAdmin.SpectateData = {origin = EyePos(), angles = RenderAngles(), drawviewer = true}
        LFAdmin.SpectateOriginal = RenderAngles()
    end)

    local CAM_SPEED, CAM_UPDATE_RATE, CAM_DISTANCE = 1000, .5, 100
    local CAM_UPDATE_NEXT = CurTime()

    hook.Add("CalcView", "LFAdmin.Spectate", function(ply, o, a)
        local target = LFAdmin.Spectating
        if target then
            local data = LFAdmin.SpectateData
            if target ~= true and IsValid(target) then
                if data.UseFirstPerson and target:IsPlayer() then data.angles = target:EyeAngles() end
                data.origin = (target:IsPlayer() and target:EyePos() or target:LocalToWorld(target:OBBCenter())) - LFAdmin.SpectateData.angles:Forward() * CAM_DISTANCE
            elseif target ~= true then LFAdmin.Spectating = true end
            return data
        end
    end)

    local vz, velocity = Vector()
    hook.Add("CreateMove", "LFAdmin.Spectate", function(ucmd)
        if LFAdmin.Spectating then
            local ww, data = ucmd:KeyDown(IN_WALK), LFAdmin.SpectateData
            data.angles = data.angles + Angle(math.Clamp(ucmd:GetMouseY() * .023, -89, 89), math.NormalizeAngle(ucmd:GetMouseX() * -.023), 0)

            local target = LFAdmin.Spectating velocity = vz
            if target == true then
                local speed = CAM_SPEED * (ucmd:KeyDown(IN_SPEED) and (ww and 4 or 2) or (ucmd:KeyDown(IN_DUCK) and (ww and .25 or .5) or 1))
                if ucmd:GetForwardMove() ~= 0 then velocity = velocity + data.angles:Forward() * speed * (ucmd:GetForwardMove() > 0 and 1 or -1) end
                if ucmd:GetSideMove() ~= 0 then velocity = velocity + data.angles:Right() * speed * (ucmd:GetSideMove() > 0 and 1 or -1) end
                if velocity then data.origin = data.origin + velocity * RealFrameTime() end
            else
                local s = ucmd:GetMouseWheel()
                if s ~= 0 then CAM_DISTANCE = CAM_DISTANCE + (s * -10) end
            end

            if CAM_UPDATE_NEXT <= CurTime() then CAM_UPDATE_NEXT = CurTime() + CAM_UPDATE_RATE net.Start("LFAdmin.Spectate") net.WriteBool(false) net.WriteBool(false) net.WriteVector(LFAdmin.SpectateData.origin) net.SendToServer() end
            if ucmd:KeyDown(IN_JUMP) then LFAdmin.Spectating = nil net.Start("LFAdmin.Spectate") net.WriteBool(true) net.WriteBool(false) net.SendToServer() end
            ucmd:ClearMovement() ucmd:SetViewAngles(LFAdmin.SpectateOriginal) ucmd:RemoveKey(IN_JUMP) ucmd:RemoveKey(IN_DUCK)
        end
    end)

    hook.Add("KeyPress", "LFAdmin.Spectate", function(ply, key)
        if IsFirstTimePredicted() and LFAdmin.Spectating then
            if key == IN_RELOAD then net.Start("LFAdmin.Spectate") net.WriteBool(true) net.WriteBool(true) net.WriteVector(velocity) net.SendToServer() end
            if key == IN_ATTACK then
                if LFAdmin.Spectating ~= true then
                    LFAdmin.Spectating = true
                    net.Start("LFAdmin.Spectate")
                        net.WriteBool(false)
                        net.WriteBool(true)
                        net.WriteEntity(NULL)
                    net.SendToServer()
                return end

                local data = LFAdmin.SpectateData
                local tr = util.TraceLine({start = data.origin, endpos = data.origin + data.angles:Forward() * 1000})
                if IsValid(tr.Entity) then
                    LFAdmin.Spectating = tr.Entity
                    net.Start("LFAdmin.Spectate")
                        net.WriteBool(false)
                        net.WriteBool(true)
                        net.WriteEntity(tr.Entity)
                    net.SendToServer()
                end
            end
            if key == IN_ATTACK2 then
                local data = LFAdmin.SpectateData
                if LFAdmin.Spectating ~= true then
                    data.UseFirstPerson = not data.UseFirstPerson
                else
                    data.origin = data.origin + data.angles:Forward() * 500
                end
            end
        end
    end)

    surface.CreateFont("LFAdmin:Spectate", {
        font	 = "Roboto",
        size	 = 15,
        weight	 = 800,
        extended = true,
    })

    local wh, bl = Color(255, 255, 255), Color(0, 0, 0)
    local sw, sh = ScrW() / 2, ScrH() / 1.1
    hook.Add("HUDPaint", "LFAdmin.Spectate", function()
        if LFAdmin.Spectating then
            for k, v in ipairs(player.GetAll()) do
                if not v:IsDormant() then
                    local data = v:EyePos():ToScreen()
                    if data.visible then
                        draw.SimpleTextOutlined(v:Name(), "LFAdmin:Spectate", data.x, data.y, team.GetColor(v:Team()), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, bl)
                        draw.SimpleTextOutlined(team.GetName(v:Team()), "LFAdmin:Spectate", data.x, data.y + 20, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, bl)
                    end
                end
            end
        end
    end)

    hook.Add("PostDrawTranslucentRenderables", "LFAdmin.Spectate", function()
        if LFAdmin.Spectating then
            local tr = LFAdmin.Spectating == true and util.TraceLine({start = LFAdmin.SpectateData.origin, endpos = LFAdmin.SpectateData.origin + LFAdmin.SpectateData.angles:Forward() * 1000})
            if tr and IsValid(tr.Entity) then
                cam.IgnoreZ(true)
                render.SuppressEngineLighting(true)
                tr.Entity:DrawModel()
                cam.IgnoreZ(false)
                render.SuppressEngineLighting(false)
            end

            for k, v in ipairs(player.GetAll()) do
                v:DrawModel()
                -- render.SetBlend(1)
                if not v:IsDormant() then
                    local tr = v:GetEyeTrace()
                    render.DrawLine(v:EyePos(), tr.HitPos, team.GetColor(v:Team()))
                end
            end
        end
    end)

    local me = LocalPlayer()
    hook.Add("RenderScene", "LFAdmin.Spectate", function()
        if not IsValid(me) then me = LocalPlayer() if not IsValid(me) then return end end
        if LFAdmin.Spectating and me:FlashlightIsOn() then render.SetLightingMode(1) end
    end)

    hook.Add("PreDrawEffects", "LFAdmin.Spectate", function()
        if IsValid(me) and LFAdmin.Spectating and me:FlashlightIsOn() then render.SetLightingMode(0) end
    end)

    hook.Add("PrePlayerDraw", "LFAdmin.Spectate", function(ply)
        if LFAdmin.Spectating == ply and LFAdmin.SpectateData.UseFirstPerson then
            -- render.OverrideColorWriteEnable(true, false)
            return true
        end
    end)

    -- hook.Add("PostPlayerDraw", "LFAdmin.Spectate", function(ply)
    --     if LFAdmin.Spectating == ply and LFAdmin.SpectateData.UseFirstPerson then
    --         render.OverrideColorWriteEnable(false, false)
    --         render.SetBlend(.75)
    --     end
    -- end)
end

