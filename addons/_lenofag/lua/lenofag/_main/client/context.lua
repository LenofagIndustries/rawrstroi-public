local format = {
    player = function(ply)
        return {
            name = ply:Name(),
            color = team.GetColor(ply:Team()),
        }
    end
}
local fill = {
    players = function(command)
        return function()
            local t = {}
            for k, v in ipairs(player.GetAll()) do
                local a = format.player(v)
                a.command = "lf " .. command .. " \"" .. v:SteamID() .. "\""
                t[#t + 1] = a
            end
            return t
        end
    end,
}

local options = {
    {
        name = "Ссылки...",
        icon = "icon16/script_go.png",
        sub = {
            {
                name = "Правила сервера",
                icon = "icon16/book_go.png",
                url  = gmlfi.rulesURL
            },
            {
                name = "Discord сервер",
                icon = "icon16/comments.png",
                url  = gmlfi.discordDirect
            },
            {
                name = "Группа Steam",
                icon = "icon16/folder_user.png",
                url  = gmlfi.steamGroup
            },
            {
                name = "Контент сервера",
                icon = "icon16/folder_picture.png",
                url  = gmlfi.serverContent
            },
        }
    },
    {
        name = "Команды...",
        icon = "icon16/computer_go.png",
        sub = {
            {
                name = "Открыть список команд",
                icon = "icon16/help.png",
                command = "lf help"
            },
            {
                name = "Открыть меню",
                icon = "icon16/application_home.png",
                command = "lf menu"
            },
            true,
            {
                name = "Metrostroi...",
                icon = "icon16/car.png",
                sub = {
                    {
                        name = "Телепортироваться в свой состав",
                        icon = "icon16/lorry_go.png",
                        command = "lf traintp"
                    },
                    {
                        name = "Телепортироваться на станцию...",
                        icon = "icon16/world_go.png",
                        sub = function()
                            local t = {}
                            for k, v in pairs(Metrostroi.StationConfigurations) do
                                if not v.positions then continue end
                                t[#t + 1] = {
                                    name = string.format("%s: %s", k, v.names and v.names[1] or ""),
                                    command = "lf station " .. k,
                                    _k = tonumber(k) or -1
                                }
                            end
                            table.sort(t, function(a, b) return a._k < b._k end)
                            return t
                        end,
                        should = function() return Metrostroi.StationConfigurations ~= nil end
                    },
                    {
                        name = "Вернуть вагон на рельсы",
                        icon = "icon16/lorry_error.png",
                        command = "metrostroi_rerail"
                    },
                }
            },
            {
                name = "Админские...",
                icon = "icon16/user_gray.png",
                sub = {
                    {
                        name = "Открыть логи",
                        icon = "icon16/page_find.png",
                        command = "lf logs"
                    },
                    {
                        name = "Открыть логи игрока...",
                        icon = "icon16/page_go.png",
                        sub = fill.players("pe")
                    },
                    {
                        name = "Следить...",
                        icon = "icon16/find.png",
                        sub = fill.players("spectate")
                    },
                },
                should = function() return LocalPlayer():IsStaff() end
            },
            {
                name = "Прочие...",
                icon = "icon16/application_go.png",
                sub = {
                    {
                        name = "Телепортироваться к...",
                        icon = "icon16/user_go.png",
                        sub = fill.players("goto")
                    },
                    {
                        name = "Запретить/разрешить телепортацию к себе",
                        icon = "icon16/user_delete.png",
                        command = "lf blockgoto"
                    },
                    {
                        name = "Начать голосование за смену карты",
                        icon = "icon16/map_magnify.png",
                        command = "lf rtv"
                    }
                }
            }
        },
    },
    {
        name = "Каналы рации...",
        icon = "icon16/user_comment.png",
        sub = function()
            local curn = LocalPlayer():GetNWString("LFI:Radio", "default")
            local current = gmlfi.radio.channels[curn] or gmlfi.radio.channels.default
            local t = {
                {
                    name = current.name or "Неизвестный канал",
                    icon = current.icon,
                },
                true,
                {
                    name = "Свои каналы...",
                    icon = "icon16/comments.png",
                    sub = {}
                },
                {
                    name = "Блокпосты...",
                    icon = "icon16/telephone.png",
                    sub = function()
                        local t = {}
                        for k, v in ipairs(MDispatcher.ControlRooms) do
                            t[#t + 1] = {
                                name = v,
                                func = function()
                                    net.Start("LFI:Radio")
                                    net.WriteBool(false)
                                    net.WriteString("blockpost:" .. v)
                                    net.SendToServer()
                                end
                            }
                        end
                        return t
                    end,
                    should = function() return MDispatcher and MDispatcher.ControlRooms end
                },
                true
            }
            local tcustom = t[3].sub
            for id, data in pairs(gmlfi.radio.channels) do
                local t = data.custom and tcustom or t
                if data.access and not LocalPlayer():HasAccess(data.access) then continue end
                t[#t + 1] = data
                data.func = function()
                    net.Start("LFI:Radio")
                    net.WriteBool(false)
                    net.WriteString(id)
                    net.SendToServer()
                end
                if data.custom then
                    data.rfunc = function(dm)
                        gmlfi.radio.channels[id] = nil
                        dm:Remove()
                    end
                end
            end
            tcustom[#tcustom + 1] = true
            tcustom[#tcustom + 1] = {
                name = "Очистить список",
                icon = "icon16/comments_delete.png",
                func = function()
                    for id, data in pairs(gmlfi.radio.channels) do if data.custom then gmlfi.radio.channels[id] = nil end end
                end
            }
            tcustom[#tcustom + 1] = {
                name = "Подключиться...",
                icon = "icon16/comments_add.png",
                func = function()
                    gmlfi.vgui.request.String("Введите идентификатор канала", "Текст, цифры, что угодно... но желательно покороче", function(str)
                        if str then
                            net.Start("LFI:Radio")
                            net.WriteBool(false)
                            net.WriteString(str)
                            net.SendToServer()
                            gmlfi.radio.channels[str] = {
                                name = "Канал \"" .. str .. "\"",
                                custom = true,
                            }
                        end
                    end)
                end
            }
            
            t[#t + 1] = true
            t[#t + 1] = {
                name = "Переключить передачу",
                icon = "icon16/transmit.png",
                func = function()
                    net.Start("LFI:Radio")
                    net.WriteBool(true)
                    net.SendToServer()
                end
            }
            t[#t + 1] = {
                name = "Игроки в канале...",
                icon = "icon16/application_side_list.png",
                sub = function()
                    local t = {}
                    for k, v in ipairs(player.GetAll()) do
                        if v:GetNWString("LFI:Radio", "default") == curn then
                            t[#t + 1] = {
                                name = v:Name(),
                                color = team.GetColor(v:Team()),
                            }
                        end
                    end
                    return t
                end
            }
            t[#t + 1] = {
                name = "Все каналы...",
                icon = "icon16/application_view_list.png",
                sub = function()
                    local t = {}
                    for k, v in ipairs(player.GetAll()) do
                        local c = v:GetNWString("LFI:Radio", "default")
                        local a = t[c]
                        if not a then
                            a = gmlfi.radio.channels[c] and table.Copy(gmlfi.radio.channels[c]) or {
                                name = "Канал \"" .. c .. "\"",
                            }
                            a.func = a.func or function()
                                net.Start("LFI:Radio")
                                net.WriteBool(false)
                                net.WriteString(c)
                                net.SendToServer()
                            end
                            a.rfunc = nil
                            a.sub = {}
                        end
                        t[c], a.sub[#a.sub + 1] = a, format.player(v)
                    end
                    return t
                end,
                should = function() return LocalPlayer():IsStaff() end
            }
            t[#t + 1] = {
                name = "Справка",
                icon = "icon16/help.png",
                sub = {
                    {
                        name = "Для подключения к каналу, выберите его из списка"
                    },
                    {
                        name = "Вы можете подключиться к каналу, нажав Свои каналы -> Подключиться"
                    },
                    {
                        name = "Впишите в появившееся меню название канала"
                    },
                    true,
                    {
                        name = "Вы можете привязать клавишу для переключения передачи, написав в консоли \"bind кнопка gmlfi_radio_toggle\" (нажмите, чтобы скопировать)",
                        icon = "icon16/keyboard.png",
                        func = function() SetClipboardText("bind кнопка gmlfi_radio_toggle") end
                    }
                }
            }
            return t
        end
    },
    {
        name = "Утилиты...",
        icon = "icon16/table_multiple.png",
        sub = {
            {
                name = "Редактор Lua",
                icon = "icon16/page_edit.png",
                command = "gmlfi_editor"
            },
            {
                name = "Напоминания в чате",
                icon = "icon16/help.png",
                sub = function()
                    local t = {}
                    for k, v in ipairs(gmlfi._SendNotifies) do
                        local s = ""
                        for _, vv in ipairs(v) do if isstring(vv) then s = s .. vv end end
                        t[k] = {
                            name = k .. ". " .. s,
                            func = function() gmlfi.SendNotify(k) end
                        }
                    end
                    t[#t + 1] = true
                    t[#t + 1] = {
                        name = "Выписать всех в чат",
                        icon = "icon16/folder_magnify.png",
                        command = "gmlfi_notify_force_all"
                    }
                    return t
                end
            }
        }
    },
    true,
    {
        name = "Донат",
        icon = "icon16/coins.png",
        command = "lf donate"
    },
}

local add add = function(dm, data, main)
    local a, b
    if data == true then return dm:AddSpacer() end
    if data.should and not data.should() then return end
    if data.name then
        a, b = dm[data.sub and "AddSubMenu" or "AddOption"](dm, data.name, data.func or function()
            if data.command then LocalPlayer():ConCommand(data.command) end
            if data.url then gui.OpenURL(string.match(data.url, "^https://") and data.url or ("https://" .. data.url)) end
            if data.func then data.func() end
        end)
    else a = dm end
    if not b then b = a end
    if data.icon then b:SetIcon(data.icon) end
    if data.color then b:SetColor(data.color) end
    if data.sub then for k, v in pairs(isfunction(data.sub) and data.sub() or data.sub) do add(a, v, dm) end end
    if data.rfunc then b.DoRightClick = function() data.rfunc(main) end end
    return a, b
end

hook.Add("ContextMenuOpened", "LFI:Context", function()
    if IsValid(gmlfi.ContextDMenu) then gmlfi.ContextDMenu:Remove() end
    local dmenu = DermaMenu()
    for k, v in pairs(options) do add(dmenu, v, dmenu) end
    dmenu:Open()
    dmenu:SetPos(0, ScrH() / 1.75)
    gmlfi.ContextDMenu = dmenu
end)

hook.Add("ContextMenuClosed", "LFI:Context", function()
    if IsValid(gmlfi.ContextDMenu) then gmlfi.ContextDMenu:Remove() end
end)