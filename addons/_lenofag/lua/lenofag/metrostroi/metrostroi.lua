if not gmlfi then return print("metrostroi says gmlfi is nil...") end

gmlfi.metro = gmlfi.metro or {}
gmlfi.metro.Log = function(...) print(string.format("gmlfi.Metrostroi: %s", string.format(...))) end
local waw={
    ["76561198433374055"]=59,
    ["76561198435290913"]=999,
    ["76561198233014472"]=228, --smile
	["76561198146987048"]=54
}

if SERVER then
    hook.Add("PlayerLoadout", "LFI:Metro", function(ply) 
        local sid64=ply:SteamID64()
        ply:Give("weapon_physcannon")
        ply:Give("weapon_empty_hands")
        if waw[sid64] then
            ply:Give("train_kv_wrench_gold")
            local wep=ply:GetWeapon("train_kv_wrench_gold")
            wep:SetCode(waw[sid64])
        else
            ply:Give("train_kv_wrench") 
        end
    end)

	local bad = {
		["nekrasovskaya/depot_gate.wav"] = true
	}
	hook.Add("EntityEmitSound", "LFI:Metro", function(data)
		if bad[data.OriginalSoundName] then
			data.Volume = .1
			return true
		end
	end)
end
--prikoluha

timer.Simple(0, function()
	local SWEP = weapons.GetStored("train_kv_wrench_gold")
	SWEP.oldswep = SWEP.oldswep or weapons.Get("train_kv_wrench_gold") --antirefresh
	if not SWEP then return end
	SWEP.Force = 59
	SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

	function SWEP:Initialize()
		local base=scripted_ents.Get("gmod_subway_base")
		self:SetHoldType("melee")
		if SERVER then
			if not self.Code then
				Metrostroi.GetReverserID(self.Owner,function(code)
					if not IsValid(self) then return end
					self:SetCode(code)
				end,true)
			end
			self.LastCheck = CurTime()
		end

	end
	local time=CurTime()
	function SWEP:Think()
		SWEP.oldswep.Think(self)
	end
	function SWEP:SecondaryAttack()
		
	end

	local bullet = {}
	bullet.Num    = 1

	bullet.Spread = Vector(0, 0, 0)
	bullet.Tracer = 0
	bullet.Force  = 1
	bullet.Damage = 0--15
	bullet.Distance = 145
	bullet.HullSize = 20
	local blacklist={
		["gmod_train_couple"] = true
	}
	local function dmg(ent)
		local data = DamageInfo()
		data:SetDamage(50)
		data:SetDamageType(DMG_DISSOLVE)
		data:SetAmmoType(game.GetAmmoID('AR2'))
		ent:TakeDamageInfo(data)
	end

	function SWEP:Reload()
		if self.NextReloadAttack and self.NextReloadAttack > CurTime() then return end self.NextReloadAttack = CurTime() + 0.2

		local trace = self.Owner:GetEyeTrace()

		bullet.Src  = self.Owner:GetShootPos()
		bullet.Dir  = self.Owner:GetAimVector()

		local ent = trace.Entity
		for _,v in ipairs(ents.FindInCone(self.Owner:GetShootPos(),self.Owner:GetAimVector(),145,math.cos(math.rad(20)))) do
			if v~=self.Owner and v:IsPlayer() then
				ent = v
				bullet.Dir = v:GetShootPos()-self.Owner:GetShootPos()
			end
		end
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:SendWeaponAnim(ACT_VM_DRYFIRE)

		if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 145 or self.Owner:GetShootPos():Distance(ent:GetPos()) <= 145 then
			self.Owner:FireBullets(bullet)
			self:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(3,5)..".wav")
			if SERVER and not blacklist[ent:GetClass()] then
				dmg(ent)
				ent:Fire("UnLock")
				ent:Fire("Toggle")
				local old = ent:GetKeyValues()["speed"]
				ent:SetKeyValue("speed",59)
				ent:Use(self.Owner)
				ent:SetKeyValue("speed",old)
			end
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then phys:ApplyForceOffset(self.Owner:GetAimVector() * self.Force * phys:GetMass(), trace.HitPos) end
		else
			self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
			self.Owner:SetAnimation(PLAYER_ATTACK1)
		end
	end
end)--arret