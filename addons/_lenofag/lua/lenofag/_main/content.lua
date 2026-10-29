local addons = {
    ["2616057103"] = "81-540.1 Боинг",
    ["2173467125"] = "81-540.2K",
    ["2342454093"] = "81-540.8 Саблезуб",
    ["2011236060"] = "81-717.5М",
    ["1951736991"] = "81-717.5П Аквариум",
    ["2202131609"] = "81-717.6",
    ["2202131609"] = "81-717.6",
    ["1917660349"] = "81-722",
    ["1929211625"] = "81-722.3",
    ["1919516717"] = "81-760 Ока 1/2",
    ["2064409061"] = "81-717 Грузовой",
    ["1996675367"] = "81-720.1",
    ["1939067371"] = "81-717.5А",
    -- ["1354789122"] = "Еж3РУ1",
    ["2257845652"] = "81-720А",
    ["2988892939"] = "ГВМУ",
    ["3414584374"] = "81-700 Ам/Ап",
    ["1938454480"] = "81-540.2",
    ["3168412356"] = "81-540.8 Головастик",
    ["2839342377"] = "Еж3 Грузовой",
    ["3488479660"] = "Ретросостав Ема-Е-Е-Емх",
    ["3483029483"] = "Еж3РУ1 (получше)",
    ["1968873792"] = "81-722.1",
    ["3616718916"] = "Motodepo Project",
    ["3316480153"] = "81-717.5Л",
    ["3664991304"] = "81-760Э Чура",
    ["2931910022"] = "81-717 СПб Custom",

    ["302370120"]  = "Garrygrad 1/5",
    ["674649096"]  = "Garrygrad 2/5",
    ["1123150860"] = "Garrygrad 3/5",
    ["1122422169"] = "Garrygrad 4/5",
    ["1563918075"] = "Garrygrad 5/5",

    ["1605301295"] = "ProSt Toolgun",
    ["2579263629"] = "Metrostroi Clock Arrive",
    ["2099854766"] = "Metrostroi Whistle",
    ["2855798473"] = "Metrostroi Info Screens",
    ["2240199465"] = "Metrostroi Extensions",
    ["1221360215"] = "Metrostroi Mezhvag System",
    ["1633937636"] = "Metrostroi alTerr-native Announcements",
    ["1766573646"] = "Metrostroi Map Thumbs",
    ["1925235871"] = "Metrostroi 81-760 Devices",
    ["3547499082"] = "Metrostroi АРМ-А",
    ["2636295274"] = "Metrostroi New Signal Models",
    ["3220281110"] = "Metrostroi Signalling",
    ["3414844751"] = "Metrostroi 81-760 Scripts",
    -- ["3401843254"] = "Metrostroi Extensions Library",
    ["3277267789"] = "\"Новый\" информатор для Некрасовской линии",
    ["2049156989"] = "Модели работников метро",

    ["1594558334"] = "Скин 81-556 для 81-722",
    ["1408177138"] = "Скин 81-765 для 81-722",
    ["1702058197"] = "Скин Northbound Downtown Railway для 81-722",
    ["1519651418"] = "Скин Rockport Transit \"Phase 2\" для 81-720",
    ["2702435245"] = "Скин Moscow New Year для Еж3 и Ем508т",
    ["1701360128"] = "Скин 001 для 81-720",
    ["2000204009"] = "Скин NSK для 81-717",
    ["2250224718"] = "Скин Красная Стрела для 81-502",
    ["2620185830"] = "Парадный скин для 81-720.1",
    ["1881014386"] = "Маска Mos Brand 1-4-1",
    ["1952566958"] = "Маска 81-540.7",
    -- ["2126449917"] = "Маска ЕКБ для 81-717",
    -- ["2126846128"] = "Маска 1-4-1 LED для 81-717",
    -- ["3069842606"] = "Маска 2-2 LED для 81-717",
    ["1552982796"] = "Пак скинов от Чарли Фрая",
    ["3143015640"] = "Пак скинов для 81-760",
    ["1517985769"] = "Пак скинов от Artery",
    ["2508521806"] = "Пак скинов Moscow Colors",
    ["3359407936"] = "Пак скинов 81-71M",
    -- ["3397163967"] = "Новогодний поезд 2025", -- disabled (NY)

    ["1487830611"] = "Пульт Kolhoz для 81-717",
    ["1745210841"] = "Пак пультов для 81-717",
    ["1554401015"] = "Интерьеры для 81-717",
    ["2343471757"] = "Интерьеры для 81-717 (More Interiors)",
    -- ["2152040472"] = "Круглые вольтметры 81-717",

    ["245482078"]  = "Empty Hands SWEP",
    ["1678408548"] = "VRMod",
    ["3319892423"] = "Div Foliage And Props", -- reuploaded
    ["673698301"]  = "Vape SWEP",
    ["2422567023"] = "Cigarette SWEP",
    ["2509672855"] = "License to Kiss",
    ["109643223"]  = "3D2D Textscreens STool",
    ["104815552"]  = "SmartSnap",
    ["3709421533"] = "Trainfitter",
    ["3544093735"] = "Spade SWEP",
    ["2825347854"] = "GPoker",
    ["1784911999"] = "LED панели",
}

timer.Create("LFI:Content", 1, 1, function() -- like Zvbhrf said, WinSCP uploads file twice (or autorefresh thinks so)
    if SERVER then
        for id, name in pairs(addons) do
            resource.AddWorkshop(id)
            print(string.format("[%s] %s added to downloading list!", id, name))
        end
    
        local maplist = {
            ["gm_metronvl"] = {id = "782009017"},
            ["gm_metro_nekrasovskaya_line_v6"] = {id = {"2091799900", "2033749116"}},
            ["gm_infmap_metrostroi"] = {id = "2917249160"},
            ["gm_simplemetro_map"] = {id = "1952018413"},
            ["gm_metro_mosldl_v1"] = {id = {"2000470033", "2000471324"}},
            ["gm_budapest_m5"] = {id = "1616288469"},
            ["gm_metro_kalinin_v3"] = {id = {"2269381092", "2269384297", "2269396238", "2000471324"}},
            ["gm_metro_crossline_c4"] = {id = {"3340000198", "631510717"}},
            ["gm_metro_jar_imagine_line_v4"] = {id = {"1371670909", "1269056775", "1119320252"}},
            ["gm_metro_minsk_1984"] = {id = {"2660435966", "2659727375", "2659747013"}}, -- 2660570042 deleted, replaced with 2659727375
            ["gm_metro_nsk_line_2_v6"] = {id = {"2033749116", "2038462052", "1783737376", "2269381092", "2269384297", "2269396238", "2000471324"}},
            ["gm_metro_mpl_v1"] = {id = {"3397095808", "3396416198", "3396417666", "3396438989", "2660435966", "2659727375", "2659747013"}},
            ["gm_jar_pll_remastered_v13"] = {id = {"843936402", "824935150", "2033749116", "2091799900"}},
            ["gm_metro_pink_line_redux_v1"] = {id = "2669321105"},
            ["gm_metro_kaluzhskaya_line6"] = {id = {"3170905226", "2660435966", "2659727375", "2659747013"}},
            ["gm_metro_sunnytown_v2"] = {id = {"2953456726", "672126440", "1133391863", "3313876544"}},
            ["gm_metro_chapaevskaya_line_redux"] = {id = "2944509317"},
            ["gm_zamoscvorescya_line_do_orehovo"] = {id = {"3472975074", "2091799900", "3170905226", "2659747013", "2659727375"}},
            ["gm_metro_pink_line_metromart_v2"] = {id = "3546302252"},
            ["gm_metro_prizmaaline_v4"] = {id = {"2823192268", "2660435966"}},
            ["gm_metrostroi_b50"] = {id = "306834272"},
            ["gm_metrostroi_b46_lite"] = {id = "306834272"},
            ["gm_smr_first_line_v3"] = {id = {"1522403484", "1371670909", "1269056775", "824935150", "824935150"}},
            ["gm_metro_m3_new"] = {id = {"2291107858", "2291119827", "1616288469"}},
            ["gm_dnipro"] = {id = {"3714089828", "3429872670"}},
            ["gm_mus_loopline_r"] = {id = {"3685455599", "3536801478"}},
            ["gm_metro_surfacemetro_w"] = {id = {"1676720559", "1900955414"}},
        }

        local curmap = game.GetMap()
        local map = maplist[curmap]
        if map then
            local t = type(map.id) == "table"
            print(string.format("Current map is %s, adding %s to workshop downloading list", curmap, t and table.concat(map.id, ", ") or map.id))
            if t then for _, v in ipairs(map.id) do resource.AddWorkshop(v) end else resource.AddWorkshop(map.id) end
        else print(string.format("Current map (%s) is not in map downloading list, clients won't download it!", curmap)) end
    end
    
    if CLIENT then
        local m = MsgC
        local MsgC = function(...) m(...) MsgN() end -- lazy
        local loadedcount  = 0
    local addtoloading = function()
        loadedcount = loadedcount + 1
        if loadedcount >= table.Count(addons) then MsgC(Color(255, 255, 255), "Content loading has finished!") end
    end
    for id, name in pairs(addons) do
        if steamworks.IsSubscribed(id) then MsgC(Color(255, 150, 50), name, Color(255, 255, 255), " already subscribed...") addtoloading() continue end
        steamworks.DownloadUGC(id, function(path)
            if not path then addtoloading() return MsgC(Color(255, 150, 50), name, Color(255, 0, 0), " failed", Color(255, 255, 255), " to download!")
            else MsgC(Color(255, 150, 50), name, Color(255, 255, 0), " downloaded", Color(255, 255, 255), ", mounting...") end

            local success = game.MountGMA(path)
            if success then MsgC(Color(255, 150, 50), name, Color(0, 255, 0), " mounted successfully!")
            else MsgC(Color(255, 150, 50), name, Color(255, 0, 0), " failed", Color(255, 255, 255), " to mount!") end
            addtoloading()
        end)
    end
    end
end)
