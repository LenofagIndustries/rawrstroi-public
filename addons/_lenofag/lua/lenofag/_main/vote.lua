gmlfi.votes = gmlfi.votes or {}
gmlfi.votes.time = 120

if SERVER then
    util.AddNetworkString("LFI:Vote")

    gmlfi.votes.Start = function(name, who, variants, cb)
        if gmlfi.votes.active then return false end

        local vars, original, valid = {}, {}, IsValid(who)
        for k, v in ipairs(variants) do vars[k] = 0 original[k] = v end

        gmlfi.votes.active = {
            name = name,
            who = who,
            author = valid and who:Name() or "Console",
            variants = vars,
            original = original,
			callback = cb,
        }
        
        net.Start("LFI:Vote")
            net.WriteString("new")
            net.WriteString(name)
            net.WriteEntity(who)
            net.WriteUInt(#variants, 3)
            for k, v in ipairs(variants) do net.WriteString(v) end
        net.Broadcast()

        print(string.format("%s started a vote \"%s\" with variants: %s", valid and string.format("%s [%s]", who:Name(), who:SteamID()), name, table.concat(variants, ", ")))
        timer.Create("LFI:Vote", gmlfi.votes.time, 1, function()
            gmlfi.votes.Stop(true)
        end)
    end

    gmlfi.votes.Stop = function(ok)
        if not gmlfi.votes.active then return false end

        local vote, winner = gmlfi.votes.active
        net.Start("LFI:Vote")
            net.WriteString("stop")
            net.WriteBool(ok or false)
            if ok then
                winner = table.GetWinningKey(vote.variants)
                if vote.variants[winner] == 0 then winner = nil
                else
                    net.WriteUInt(vote.variants[winner], 8)
                    net.WriteUInt(winner, 3)
                end
            end
        net.Broadcast()

        print(string.format("Vote \"%s\" by %s finished%s", vote.name, vote.author, ok and (winner and string.format(", \"%s\" has won", winner) or ", neither of variants won") or " forcefully"))
        if vote.callback then vote.callback(ok, winner and vote.original[winner]) end

        for _, v in ipairs(player.GetAll()) do v.LFIVOTE = nil end
        gmlfi.votes.active = nil
    end

    gmlfi.votes.Update = function(num, ply, notify)
        net.Start("LFI:Vote")
            net.WriteString("update")
            net.WriteUInt(num, 3)
            net.WriteUInt(gmlfi.votes.active.variants[num], 8)
            net.WriteEntity(ply)
            net.WriteBool(notify or false)
        net.Broadcast()
    end

    hook.Add("PlayerDisconnected", "LFI:Vote", function(ply)
        if gmlfi.votes.active and gmlfi.votes.active.who == ply then
            print(string.format("Deleting %s [%s] vote...", ply:Name(), ply:SteamID()))
            gmlfi.votes.Stop()
        end
    end)

    hook.Add("PlayerSay", "LFI:Vote", function(ply, text)
        if gmlfi.votes.active then
            local vote, num = gmlfi.votes.active, tonumber(text)
            if vote.variants[num] then
				if ply.LFIVOTE == num then return end
                if ply.LFIVOTE then vote.variants[ply.LFIVOTE] = vote.variants[ply.LFIVOTE] - 1 gmlfi.votes.Update(ply.LFIVOTE, ply) end
                ply.LFIVOTE, vote.variants[num] = num, vote.variants[num] + 1
                print(string.format("%s [%s] voted for \"%s\" in \"%s\"", ply:Name(), ply:SteamID(), vote.original[num], vote.name))

                gmlfi.votes.Update(num, ply, true)
            return "" end
        end
    end)

	concommand.Add("gmlfi_votes_start", function(ply, _, args)
		if IsValid(ply) and ply:IsPlayer() and not ply:IsRamzi() then return end
		local n = args[1] table.remove(args, 1)
		gmlfi.votes.Start(n, ply, {unpack(args)})
	end)

    concommand.Add("gmlfi_votes_stop", function(ply, _, args)
		if IsValid(ply) and ply:IsPlayer() and not ply:IsRamzi() then return end
		gmlfi.votes.Stop()
	end)
else
    local gradient = Material("gui/gradient_down")

    local tx = Color(255, 255, 255)
    local col = Color(110, 0, 255)
    local bg = Color(0, 0, 0)

    local posx, posy = 30, 30
    local sizew, sizeh = 648, 270

    local font = "Roboto"
    local make = function(name, size, width)
        surface.CreateFont("LFI:Vote" .. name, {
            font = font,
            size = size,
            weight = width,
            extended = true,
            antialias = true,
        })
    end

    make("", 24, 800)
    make(".Title", 30, 800)
    make(".Small", 12, 800)

    local _titles = {"голос", "голоса", "голосов"}
    local declOfNum = function(n)
        return _titles[n % 10 == 1 and n % 100 ~= 11 and 1 or n % 10 >= 2 and n % 10 <= 4 and (n % 100 < 10 or n % 100 >= 20) and 2 or 3];
    end

    hook.Add("HUDPaint", "LFI:Vote", function()
        if not gmlfi.votes.active then return end
        local x, y, v = posx, posy, gmlfi.votes.active
        local col = v.author.color or col

        surface.SetDrawColor(col.r, col.g, col.b, col.a)
        surface.DrawRect(x, y, sizew, 3)

        surface.SetDrawColor(bg.r, bg.g, bg.b, bg.a)
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(x, y + 3, sizew, sizeh)

        local _, __y = draw.SimpleText("Для голосования пишите цифру ответа в чат", "LFI:Vote.Small", x + (sizew - 5), y + 5, tx, TEXT_ALIGN_RIGHT)
        draw.SimpleText(gmlfi.FormatTime(v.endtime - os.time()), "LFI:Vote.Small", x + (sizew - 5), y + __y + 5, tx, TEXT_ALIGN_RIGHT)

        draw.SimpleText(v.name, "LFI:Vote.Title", x + 15, y + 15, tx)
        local __w = draw.SimpleText("от ", "LFI:Vote", x + 15, y + 50, tx)
        draw.SimpleTextOutlined(v.author.name or "Неизвестно", "LFI:Vote", x + 15 + __w, y + 50, v.author.color or tx, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, bg)

        local i = 0
        for d, vv in pairs(v.variants) do i = i + 1
            draw.SimpleText(string.format("%s: %s - %s %s", d, v.original[d], vv, declOfNum(vv)), "LFI:Vote", x + 15, y + 80 + (25 * i), tx)
        end
    end)

    local antispam = {}
    local events = {
        new = function()
            local name, who, num, vars, original = net.ReadString(), net.ReadEntity(), net.ReadUInt(3), {}, {}
            for k = 1, num do vars[k] = 0 original[k] = net.ReadString() end

            local valid = IsValid(who)
            gmlfi.votes.active = {
                name = name,
                author = {name = valid and who:Name() or "Консоль", color = valid and team.GetColor(who:Team()) or tx},
                variants = vars,
                original = original,
                endtime = os.time() + gmlfi.votes.time,
            }

            local vote = gmlfi.votes.active
            chat.AddText(vote.author.color, vote.author.name, tx, " начал голосование \"", col, vote.name, tx, "\"")
            chat.AddText("Для голосования пишите цифру ответа в чат")
        end,
        update = function()
            if not gmlfi.votes.active then return end
            local id, sum = net.ReadUInt(3), net.ReadUInt(8)
            local ply = net.ReadEntity() local valid = IsValid(ply)

            gmlfi.votes.active.variants[id] = sum
            if net.ReadBool() and (antispam[ply] or 0) <= os.time() then antispam[ply] = os.time() + 5 chat.AddText(valid and team.GetColor(ply:Team()) or col, valid and ply:Name() or "Неизвестно", tx, " проголосовал за \"", col, gmlfi.votes.active.original[id], tx, "\"") end
        end,
        stop = function()
            if not gmlfi.votes.active then return end

            local vote, ok = gmlfi.votes.active, net.ReadBool()
            if ok then -- looks very bad to me
                local num, winner = net.ReadUInt(8), net.ReadUInt(3)
                if num > 0 then chat.AddText(tx, "Голосование \"", col, vote.name, tx, "\" игрока ", vote.author.color, vote.author.name, tx, " завершено, итог: ", col, vote.original[winner], tx, string.format(" (%s %s)", num, declOfNum(num)))
                else chat.AddText(tx, "Голосование \"", col, vote.name, tx, "\" игрока ", vote.author.color, vote.author.name, tx, " завершено, никакой из вариантов не выиграл") end
            else chat.AddText(tx, "Голосование \"", col, vote.name, tx, "\" игрока ", vote.author.color, vote.author.name, tx, " было отменено") end
            gmlfi.votes.active = nil
        end
    }

    net.Receive("LFI:Vote", function()
        local event = net.ReadString()
        if events[event] then events[event]() end
    end)
end
