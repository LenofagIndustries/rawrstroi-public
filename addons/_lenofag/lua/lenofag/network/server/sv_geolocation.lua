gmlfi.geolocation = nil

gmlfi.geo = gmlfi.geo or {cache = {}}
gmlfi.geo.settings = {
    presets = {
        unknown = {
            city = false,
            country = "Неизвестно",
            flag = "fam"
        },
        localhost = {
            city = false,
            country = "localhost",
            flag = "europeanunion",
        }
    },
    replace = {

    },
    replaceBySteamID = {
        
    },
    alias = {
        
    },
    private = {
        "^127%.",
        "^10%.",
        "^172%.1[6-9]%.",
        "^172%.2[0-9]%.",
        "^172%.3[0-1]%.",
        "^192%.168."
    },
    providers = {
        "rs-media", "host", "myarena", "aeza", "server", "cloud", "cloudflare",
        "network management ltd", "firstbyte", "vds", "vps", "quad9", "google",
        "yandex", "llc vk", "vk services", "mail.ru", "amazon", "ovh", "hetzner",
        "apple technologies", "microsoft", "azure", "ru-center", "netangels",
        "internet-pro", "selectel", "contabo", "chsw", "vdsina", "ddos-guard",
        "vpn", "proton", "proxy", "digitalocean", "zscaler", "firebase",
        "supabase", "heroku", "aws", "lambda", "node", "scaleway", "skolkovo",
        "backend", "linode", "minecraft", "gmod", "garrysmod", "vultr",
        "miglovets egor andreevich", "serveraukr", "adeno solutions",
        "smart ape", "combahton", "ipserver", "dpkgsoft"
    }
}

local c = gmlfi.geo.cache
gmlfi.geo.Set = function(ply, ip, data)
    if IsValid(ply) then ply:SetNetVar("GeoIP", data) end
    if ip then c[ip] = data end
end

local s = gmlfi.geo.settings
local fail = function(ply, ip, err)
    gmlfi.geo.Set(ply, ip, s.presets.unknown)
    print(string.format("Failed to fetch GeoIP of %s [%s] (%s): %s", ply:Name(), ply:SteamID(), ip or ply:IPAddress(), err))
end

local _fields = {
    "isp", "org", "as", "asname"
}
local vpn = function(ply, ip, field, str, data)
    print(string.format("%s [%s]'s IP (%s) seems to be of a hosting provider [%s contains %s] [%s, %s - %s, %s]", ply:Name(), ply:SteamID(), ip, field, str, data.isp, data.org, data.as, data.asname))
end

for k, v in pairs(s.alias) do
    if s.replaceBySteamID[v] then s.replaceBySteamID[k] = s.replaceBySteamID[v] end
    if s.replace[v] then s.replace[k] = s.replace[v] end
end

hook.Add("PlayerInitialSpawn", "LFI:Geolocation", function(ply)
    if ply:IsBot() then return end

    local ip = string.match(ply:IPAddress(), "^([0-9.]+):") if not ip then return fail(ply, nil, "could not match IP") end
    local rbsid = s.replaceBySteamID[ply:SteamID()] or s.replace[ip] if rbsid then c[ip] = rbsid end
    local d = c[ip]
    if d then
        if not d.pending then
            gmlfi.geo.Set(ply, nil, d)
            print(string.format("[cached] %s [%s] joined from %s, %s [%s]", ply:Name(), ply:SteamID(), d.city or "Неизвестно", d.country, d.raw and d.raw.as or "unknown as"))
        end
        return
    end
    for k, pattern in ipairs(s.private) do
        if string.match(ip, pattern) then
            gmlfi.geo.Set(ply, ip, s.presets.localhost)
            return print(string.format("%s [%s]'s IP is in private range (%s)", ply:Name(), ply:SteamID(), ip))
        end
    end
    d = {pending = true} c[ip] = d
    http.Fetch("http://ip-api.com/json/" .. string.Replace(ip, ".", "%2E") .. "?fields=21163551&lang=ru", function(body)
        if not body or body == "" then return fail(ply, ip, "empty body") end
        body = util.JSONToTable(body) if not body then return fail(ply, ip, "JSON parse failure") end

        if body.message == "reserved range" then
            gmlfi.geo.Set(ply, ip, s.presets.localhost)
            return print(string.format("%s [%s]'s IP is in private range (API error) (%s)", ply:Name(), ply:SteamID(), ip))
        end
        if body.status == "fail" then return fail(ply, ip, "API error: " .. (body.message or "(unknown)")) end
        if body.regionName == "Крым" and body.countryCode ~= "RU" then body.countryCode, body.country = "ru", "Россия" end

        gmlfi.geo.Set(ply, ip, {city = body.city, flag = string.lower(body.countryCode), country = body.country, raw = body})
        print(string.format("%s [%s] joined from %s, %s [%s]", ply:Name(), ply:SteamID(), body.city or "Неизвестно", body.country, body.as))

        for _, str in ipairs(s.providers) do
            for _, field in ipairs(_fields) do
                if string.find(string.lower(body[field]), str) then vpn(ply, ip, field, str, body) goto fin end
            end
        end
        ::fin::
    end)
end)

concommand.Add("gmlfi_geo_dumpall", function(ply)
    if not IsValid(ply) then
        for k, v in ipairs(player.GetHumans()) do
            local body = v:GetNetVar("GeoIP")
            if body and body.flag then
                print(string.format("%s [%s] joined from %s, %s [%s]", v:Name(), v:SteamID(), body.city or "Неизвестно", body.country, body.raw and body.raw.as or "unknown as"))
            else print(string.format("%s [%s]'s data not yet fetched or have failed to", v:Name(), v:SteamID())) end
        end
    end
end)