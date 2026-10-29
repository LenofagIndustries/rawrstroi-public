AddCSLuaFile()
ENT.Type = "anim"

ENT.PrintName = "Clock test"
ENT.Category = "gm.lenofag.ru"
ENT.Spawnable = true

if CLIENT then
    local wh, bl, st, gr = Color(255, 255, 255), Color(0, 0, 0), Color(255, 0, 0), Color(255, 255, 255, 50)
    local poly = {} do
        local x, y = 180, 180
        for angle = 1, 360 do
            local rad = math.rad(angle)
            local cos = math.cos(rad) * y
            local sin = math.sin(rad) * y
            poly[#poly + 1] = {
                x = x + cos,
                y = y + sin
            }
        end
    end

    local poly2 = {} do
        local ox, oy = 164, 164
        local x, y = 16, 16
        for angle = 1, 360 do
            local rad = math.rad(angle)
            local cos = math.cos(rad) * y
            local sin = math.sin(rad) * y
            poly2[#poly2 + 1] = {
                x = ox + x + cos,
                y = oy + y + sin
            }
        end
    end

    surface.CreateFont("gmlfi_clock", {
        font = "Roboto",
        size = 24
    })

    surface.CreateFont("gmlfi_clock.Small", {
        font = "Roboto",
        size = 16
    })

    local t, td = os.time(), os.date("*t")
    function ENT:Draw()
        self:DrawModel()
        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), -90)
        cam.Start3D2D(self:GetPos() - ang:Right() * 18 - ang:Forward() * 18 - ang:Up() * .8, ang, .1)
            -- draw.SimpleText(os.date("%X"), "gmlfi_clock", 180, 300, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- render.ClearStencil()
            -- render.SetStencilEnable(true)
            --     render.SetStencilWriteMask(1)
            --     render.SetStencilTestMask(1)
            --     render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
            --     render.SetStencilPassOperation(STENCILOPERATION_ZERO)
            --     render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
            --     render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
            --     render.SetStencilReferenceValue(1)
                    draw.NoTexture()
                    surface.SetDrawColor(0, 0, 0, 200)
                    surface.DrawPoly(poly)
                -- render.SetStencilFailOperation(STENCILOPERATION_ZERO)
                -- render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
                -- render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
                -- render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
                -- render.SetStencilReferenceValue(1)
                    -- surface.DrawRect(0, 0, 360, 360)
                    -- surface.DrawTexturedRect(0, 0, 360, 360)
                    -- draw.RoundedBox(16, sth * 188, cth * 188, 16, 16, wh)
            -- render.SetStencilEnable(false)
            -- render.ClearStencil()

            surface.SetDrawColor(255, 0, 0)
            -- local t = os.time()
            do
                local r = t / 60 * 360 - 90
                local th = math.rad(r)
                local sth, cth = math.cos(th), math.sin(th)
                -- surface.DrawLine(180, 180, 180 + sth * 180, 180 + cth * 180)
                -- surface.DrawCircle(180 + sth * 180, 180 + cth * 180, 4, 255, 0, 0)
                surface.DrawTexturedRectRotated(180 + sth * 90, 180 + cth * 90, 180, 1, -r % 360)
                draw.SimpleTextOutlined(td.sec, "gmlfi_clock", 180 + sth * 208, 180 + cth * 208, st, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, bl)
            end
            surface.SetDrawColor(255, 255, 255)
            do
                local r = t / 3600 * 360 - 90
                local th = math.rad(r)
                local sth, cth = math.cos(th), math.sin(th)
                -- surface.DrawLine(180, 180, 180 + sth * 180, 180 + cth * 180)
                -- surface.DrawCircle(180 + sth * 180, 180 + cth * 180, 4, 255, 255, 255)
                surface.DrawTexturedRectRotated(180 + sth * 90, 180 + cth * 90, 180, 3, -r % 360)
                draw.SimpleTextOutlined(td.min, "gmlfi_clock", 180 + sth * 208, 180 + cth * 208, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, bl)
            end
            do
                local r = t / 43200 * 360
                local th = math.rad(r)
                local sth, cth = math.cos(th), math.sin(th)
                -- surface.DrawLine(180, 180, 180 + sth * 90, 180 + cth * 90)
                -- surface.DrawCircle(180 + sth * 90, 180 + cth * 90, 4, 255, 255, 255)
                surface.DrawTexturedRectRotated(180 + sth * 45, 180 + cth * 45, 90, 6, -r % 360)
                draw.SimpleTextOutlined(td.hour, "gmlfi_clock", 180 + sth * 118, 180 + cth * 118, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, bl)
            end

            surface.DrawCircle(180, 180, 17, 255, 255, 255, 50)
            surface.DrawCircle(180, 180, 90, 255, 255, 255, 50)
            surface.DrawCircle(180, 180, 180, 255, 255, 255, 50)

            for k = 1, 12 do
                local th = math.rad(k * 30 - 90)
                local sth, cth = math.cos(th), math.sin(th)
                surface.DrawLine(180 + sth * 160, 180 + cth * 160, 180 + sth * 180, 180 + cth * 180)
                draw.SimpleText(k, "gmlfi_clock.Small", 180 + sth * 150, 180 + cth * 145, gr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            for k = 1, 60 do
                if k % 5 == 0 then continue end
                local th = math.rad(k * 6)
                local sth, cth = math.cos(th), math.sin(th)
                surface.DrawLine(180 + sth * 173, 180 + cth * 173, 180 + sth * 180, 180 + cth * 180)
            end

            -- render.SetStencilEnable(true)
            --     render.SetStencilWriteMask(1)
            --     render.SetStencilTestMask(1)
            --     render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
            --     render.SetStencilPassOperation(STENCILOPERATION_ZERO)
            --     render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
            --     render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
            --     render.SetStencilReferenceValue(1)
                    draw.NoTexture()
                    surface.SetDrawColor(50, 50, 50)
                    surface.DrawPoly(poly2)
                -- render.SetStencilFailOperation(STENCILOPERATION_ZERO)
                -- render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
                -- render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
                -- render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
                -- render.SetStencilReferenceValue(1)
                    -- surface.DrawRect(164, 164, 32, 32)
                    -- draw.RoundedBox(16, sth * 188, cth * 188, 16, 16, wh)
            -- render.SetStencilEnable(false)
            -- render.ClearStencil()
        cam.End3D2D()
    end

    function ENT:Think()
        if not self.ThinkNext or self.ThinkNext < CurTime() then
            self.ThinkNext, t, td =
                CurTime() + 1,
                os.time(),
                {hour = os.date("%I"), min = os.date("%M"), sec = os.date("%S")}
            self:EmitSound("buttons/lightswitch2.wav", 50, 125, td.sec == "00" and 1 or .5)
            if td.min == "00" and td.sec == "00" then self:EmitSound("hl1/fvox/bell.wav") end
        end
    end
else
    function ENT:Initialize()
        self:SetModel("models/props_trainstation/trainstation_clock001.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
    end
end