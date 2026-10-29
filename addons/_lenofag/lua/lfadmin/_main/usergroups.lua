LFAdmin.Groups = LFAdmin.Groups or {Stored = {}}

-- teams

local _t = 0
local t = function(...) _t = _t + 1 return _t, team.SetUp(_t, ...) end
TEAM_SUPERADMIN = t("superadmin", Color(100, 0, 255))
TEAM_HEADADMIN = t("Куратор", Color(173, 20, 87))
TEAM_TRUBOSTROI = t("Трубострой", Color(130, 100, 0))
TEAM_ADMINISTRATOR = t("Администратор", Color(255, 10, 0))
TEAM_DISPATCHER = t("Диспетчер", Color(255, 162, 56))
TEAM_MODERATOR = t("Модератор", Color(255, 150, 0))
TEAM_HELPER = t("Хелпер", Color(200, 163, 0))
TEAM_TRAINEE = t("Стажер", Color(186, 200, 0))
TEAM_EVENTER = t("Ивентер", Color(0, 200, 177))
TEAM_DEFAULTPLUS = t("Игрок+", Color(140, 255, 0))
TEAM_DEFAULT = t("Игрок", Color(50, 150, 255))
TEAM_MINGE = t("Минг", Color(238, 0, 0))
TEAM_RAWR = t("акул", Color(133, 54, 255))
TEAM_MEOW = t("крол",Color(253, 122, 255))
TEAM_LICEN = t("лисеннегры",Color(0, 255, 0))
TEAM_CUSTOM = t("Куколд",Color(172, 31, 19))
TEAM_CUSTOM2 = t("Команда но без юзергруппы для теста", Color(255, 255, 255))
-- group meta

local GROUP = {}

function GROUP:__tostring() return self:GetName() end
function GROUP:GetName() return self.Name end
function GROUP:GetImmunity() return self.Immunity end
function GROUP:HasAccess(flag) return self.Flags[flag] or self.Ramzi end
function GROUP:CanTarget(group)
    group = LFAdmin.Groups.Stored[group]
    return group and self.Name == group.Name or self:GetImmunity() >= group:GetImmunity()
end

function GROUP:SetImmunity(i) self.Immunity = i return self end
function GROUP:SetMaxBan(t) self.MaxBan = t return self end
function GROUP:AddAccess(flag) self.Flags[flag] = true end
function GROUP:SetAccess(flags)
    for k = 1, #flags do self.Flags[flags[k]] = true end
return self end

function GROUP:SetVIP(b) self.VIP = b return self end
function GROUP:SetAdmin(b) self.Admin = b return self end
function GROUP:SetSuperAdmin(b) self.SuperAdmin = b return self end
function GROUP:SetRamzi(b) self.Ramzi = b return self end

function GROUP:SetTeam(t) self.Team = t return self end

function GROUP:IsVIP() return self.VIP or self:IsAdmin() end
function GROUP:IsStaff() return self.Staff or self:IsAdmin() end
function GROUP:IsAdmin() return self.Admin or self:IsSuperAdmin() end
function GROUP:IsSuperAdmin() return self.SuperAdmin or self:IsRamzi() end
function GROUP:IsRamzi() return self.Ramzi or false end

LFAdmin.CreateGroup = function(name)
    local group = {Name = name, Flags = {}, Immunity = 0, Team = TEAM_DEFAULT}
    setmetatable(group, {__index = GROUP})
    LFAdmin.Groups.Stored[name] = group
    return group
end

-- player meta

local meta = FindMetaTable("Player")

function meta:GetRank() return LFAdmin.Groups.Stored[self:GetUserGroup()] or GROUP end
function meta:GetImmunity() return self:GetRank().Immunity end

function meta:HasAccess(...) return self:GetRank():HasAccess(...) ~= nil end
function meta:CanTarget(target) return self == target or self:GetRank().Immunity >= target:GetRank().Immunity end

function meta:IsVIP() return self:GetRank():IsVIP() end
function meta:IsStaff() return self:GetRank():IsStaff() end
function meta:IsAdmin() return self:GetRank():IsAdmin() end
function meta:IsSuperAdmin() return self:GetRank():IsSuperAdmin() end
function meta:IsRamzi() return self:GetRank():IsRamzi() end

if SERVER then
    function meta:IsPlayerFrozen() return self.LFAFREEZE or self.LFAJAILED end
end

local times = {
    s  = 1,
    mi = 60,
    h  = 3600,
    d  = 86400,
    w  = 604800,
    mo = 2592000,
    y  = 31540000,
}

-- config

LFAdmin.CreateGroup("user")
    :SetAccess("u")

LFAdmin.CreateGroup("minge")
    :SetAccess("u")
    :SetTeam(TEAM_MINGE)

LFAdmin.CreateGroup("user+")
    :SetAccess("uv")
    :SetVIP(true)
    :SetTeam(TEAM_DEFAULTPLUS)

LFAdmin.CreateGroup("eventer")
    :SetAccess("uvm")
    :SetImmunity(250)
    :SetMaxBan(1 * times.w)
    :SetAdmin(true)
    :SetTeam(TEAM_EVENTER)

LFAdmin.CreateGroup("trainee")
    :SetAccess("utm")
    :SetImmunity(250)
    :SetMaxBan(1 * times.w)
    :SetAdmin(true)
    :SetTeam(TEAM_TRAINEE)

LFAdmin.CreateGroup("helper")
    :SetAccess("uvtm")
    :SetImmunity(350)
    :SetMaxBan(2 * times.w)
    :SetAdmin(true)
    :SetTeam(TEAM_HELPER)

LFAdmin.CreateGroup("moderator")
    :SetAccess("uvtm")
    :SetImmunity(500)
    :SetMaxBan(6 * times.mo)
    :SetAdmin(true)
    :SetTeam(TEAM_MODERATOR)

-- LFAdmin.CreateGroup("dispatcher")
--     :SetAccess("uvm")
--     :SetImmunity(500)
--     :SetMaxBan(6 * times.mo)
--     :SetAdmin(true)
--     :SetTeam(TEAM_DISPATCHER)

LFAdmin.CreateGroup("administrator")
    :SetAccess("uvtma")
    :SetImmunity(1000)
    :SetAdmin(true)
    :SetTeam(TEAM_ADMINISTRATOR)

LFAdmin.CreateGroup("trubostroi")
    :SetAccess("uvtma")
    :SetImmunity(1000)
    :SetMaxBan(4 * times.w)
    :SetAdmin(true)
    :SetTeam(TEAM_DEFAULTPLUS)

LFAdmin.CreateGroup("curator")
    :SetAccess("uvtmas")
    :SetImmunity(2000)
    :SetAdmin(true)
    -- :SetSuperAdmin(true)
    :SetTeam(TEAM_HEADADMIN)

LFAdmin.CreateGroup("admin")
    :SetAccess("uvtmas*")
    --:SetImmunity(2500) потому что ахуел блять
    :SetSuperAdmin(true)
    :SetTeam(TEAM_MINGE)

LFAdmin.CreateGroup("superadmin")
    :SetAccess("uvtmas*")
    :SetImmunity(3000)
    :SetSuperAdmin(true)
    :SetTeam(TEAM_SUPERADMIN)

LFAdmin.CreateGroup("ramzi")
    :SetRamzi(true)
    :SetImmunity(3500)

LFAdmin.CreateGroup("meow")
    :SetRamzi(true)
    :SetImmunity(3500)
    :SetTeam(TEAM_MEOW)

LFAdmin.CreateGroup("rawr")
    :SetRamzi(true)
    :SetImmunity(3500)
    :SetTeam(TEAM_RAWR)

LFAdmin.CreateGroup("licen")
    :SetRamzi(true)
    :SetImmunity(3500)
    :SetTeam(TEAM_LICEN)

LFAdmin.CreateGroup("custom")
    :SetAccess("u")
    :SetTeam(TEAM_CUSTOM) --4 da lulz

hook.Add("PhysgunPickup", "LFAdmin:Pickup", function(ply, target)
    if not IsValid(target) then return end
    local p = target:IsPlayer()
    if p and ply:IsStaff() and ply:CanTarget(target) and not target.LFAJAILED then return true
    elseif target:MapCreationID() ~= -1 then return false end
end)

if SERVER then
    for k, v in ipairs(player.GetAll()) do
        v:SetTeam(v:GetRank().Team or TEAM_DEFAULT)
    end
end