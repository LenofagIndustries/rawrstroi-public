local sw, sh = ScrW(), ScrH()
local ww = function(w) return w / 1920 * sw end
local hh = function(h) return h / 1080 * sh end

local FONT_TITLE, FONT_CAT, FONT_SETTINGS = gmlfi.vgui.Font("ChatTitle", 20, 800), gmlfi.vgui.Font("ChatCat", 16, 700), gmlfi.vgui.Font("ChatSettings", 16, 700)
local wh, bl, gr = Color(255, 255, 255), Color(0, 0, 0), Color(80, 80, 80)
local bg, ts = Color(0, 0, 0, 99), Color(110, 0, 255)
local bs, bh, bi = Color(0, 0, 0, 99), Color(0, 0, 0, 76), Color(0, 0, 0, 51)
local gradient, gradientd = Material("vgui/gradient-l"), Material("vgui/gradient-u")
local blur = Material("pp/blurscreen")

--     ______   __    __   __       ______  __    
--    /\  ___\ /\ "-./  \ /\ \     /\  ___\/\ \   
--    \ \ \__ \\ \ \-./\ \\ \ \____\ \  __\\ \ \  
--     \ \_____\\ \_\ \ \_\\ \_____\\ \_\   \ \_\ 
--      \/_____/ \/_/  \/_/ \/_____/ \/_/    \/_/ 
--
--    gm.lenofag.ru © 2025
--    save this watermark if you are copying our scripts please

gmlfi.vgui.DownloadMaterial("chat_send", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/image_2025-07-30_02-59-04.png")
gmlfi.vgui.DownloadMaterial("chat_settings", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/image_2025-07-30_03-01-18.png")
gmlfi.vgui.DownloadMaterial("chat_refresh", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/refresh_48dp_FFFFFF_FILL1_wght700_GRAD200_opsz48.png")
gmlfi.vgui.DownloadMaterial("gmlfi_logo", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/image_2025-09-10_16-45-28.png")
gmlfi.vgui.DownloadMaterial("checked", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/image_2025-09-13_21-02-59.png")
gmlfi.vgui.DownloadMaterial("collapse_arrow", "https://raw.githubusercontent.com/gerrustalker/gerrustalker/refs/heads/fastdl/gmlfi/shared/image_2025-10-05_17-13-13.png")

local HTML_SCRIPT = [=[
<head>
    <meta charset="utf-8">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,100..700;1,100..700&family=Roboto:ital,wght@0,100..900;1,100..900&display=swap');
        body {
            font-family: Roboto, Verdana, Geneva, Tahoma, sans-serif;
            color: white;
            display: flex;
            flex-direction: column-reverse;
            justify-content: flex-end;
            flex-wrap: wrap-reverse;
            margin: 0; padding: 0;
            min-height: 100vh;
        }
        
        body:not(.active) { overflow: hidden }

        div {
            flex: 1 1 auto;
        }

        span.message {
            font-size: 16px;
            font-weight: 500;
            background: linear-gradient(90deg, rgba(0, 0, 0, 0.2) 0%, rgba(0, 0, 0, 0) 100%);
            padding: 2px 3px;
            margin-bottom: auto;
            word-break: break-word;
            overflow-wrap: anywhere;
            text-shadow: rgb(0, 0, 0) 1px 0px 0px, rgb(0, 0, 0) 0.540302px 0.841471px 0px, rgb(0, 0, 0) -0.416147px 0.909297px 0px, rgb(0, 0, 0) -0.989992px 0.14112px 0px, rgb(0, 0, 0) -0.653644px -0.756802px 0px, rgb(0, 0, 0) 0.283662px -0.958924px 0px, rgb(0, 0, 0) 0.96017px -0.279415px 0px;
            transition: .1s;
        }

        span.message p {
            display: inline;
            margin: 0;
        }

        body.active span.message:hover {
            background-color: rgba(25, 25, 25, 0.5);
        }

        b { font-weight: bolder; }
        pre { white-space: pre-wrap; margin: 0; }
        code {
            font-family: "Roboto Mono", Consolas, 'Courier New', Courier, monospace;
            display: inline-block;
            background-color: rgba(50, 50, 50, 0.5);
            border-radius: 8px;
            padding: 0 4px;
        }
        a { text-decoration: none; color: rgb(180, 160, 255) }
        a.img-url { color: rgb(252, 160, 255) }
        a.img-shown { color: rgb(253, 201, 255) }
        a:hover { color: rgb(200, 180, 255) }
        img {
            display: block;
            max-width: 400px;
            cursor: pointer;
        }

        .counter {
            font-size: .75em;
        }

        .anim-show {
            animation: show .5s both;
        }

        body:not(.active) .anim-disappear {
            animation: disappear 5s both;
            transition: .1s;
        }

        body:not(.active) .disappear {
            /* display: none; */
            visibility: hidden;
            opacity: 0;
        }

        .anim-change {
            animation: change .5s both;
        }

        @keyframes show {
            from { opacity: 0; transform: translateX(-100%); }
            to { opacity: 1; transform: translateX(0%); }
        }

        @keyframes disappear {
            from { opacity: 1; }
            to { opacity: 0; }
        }

        @keyframes change {
            from { color: green; }
            to { color: white; }
        }
        
        ::-webkit-scrollbar { width: 5px; height: 5px; }
        ::-webkit-scrollbar-track { background-color: rgba(0, 0, 0, .5) }
        ::-webkit-scrollbar-thumb { background-color: rgba(110, 0, 255, .5) }
        ::-webkit-scrollbar-thumb:hover { background-color: rgba(110, 0, 255, .75) }
        ::selection { background-color: rgb(110, 0, 255) }
    </style>
    <style id="stylecustom"></style>
    <script src="https://cdn.jsdelivr.net/npm/markdown-it@14.1.0/dist/markdown-it.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/markdown-it-emoji@3.0.0/dist/markdown-it-emoji.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/highlight.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/languages/javascript.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/languages/lua.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/languages/cpp.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/languages/objectivec.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/styles/github-dark.min.css">
</head>
<body><div></div></body>
<script>
    var md
    var mdlox = true
    if(typeof markdownit != "undefined") {
        mdlox = false
        md = markdownit({
            html: false,
            breaks: true,
            linkify: true,
            highlight: typeof hljs != "undefined" ? (str, lang) => {
                if(lang && hljs.getLanguage(lang)) {
                    try {
                        return hljs.highlight(str, { language: lang }).value;
                    } catch(e) {}
                }
                return ""
            } : null,
        })
        .disable(["image", "list", "blockquote"])
        .use(markdownitEmoji)
        .use(md => {
            function tokenize(state, silent) {
                const start = state.pos
                const max = state.posMax

                if (state.src.charCodeAt(start) !== 0x3C) return false

                const match = state.src.slice(start).match(/^<color=(\d{1,3}),(\d{1,3}),(\d{1,3})>/)
                if (!match) return false

                if (silent) return true

                const r = match[1]
                const g = match[2]
                const b = match[3]

                const contentStart = start + match[0].length
                const contentEnd = state.src.indexOf("</color>", contentStart)
                
                if (contentEnd === -1) return false

                const tokenOpen = state.push("color_open", "span", 1)
                tokenOpen.attrs = [["style", `color:rgb(${r},${g},${b})`]]

                const oldPos = state.pos
                const oldMax = state.posMax
                
                state.pos = contentStart
                state.posMax = contentEnd
                state.md.inline.tokenize(state)
                
                state.pos = contentEnd
                state.posMax = oldMax

                state.push("color_close", "span", -1)

                state.pos = contentEnd + 8
                
                return true
            }

            md.inline.ruler.before("html_inline", "color", tokenize)
        })
        .use(md => {
            function tokenize(state, silent) {
                const start = state.pos
                const max = state.posMax

                if (state.src.charCodeAt(start) !== 0x3C) return false

                const match = state.src.slice(start).match(/^<font=([])>/)
                if (!match) return false

                if (silent) return true

                const r = match[1]
                const g = match[2]
                const b = match[3]

                const contentStart = start + match[0].length
                const contentEnd = state.src.indexOf("</color>", contentStart)
                
                if (contentEnd === -1) return false

                const tokenOpen = state.push("color_open", "span", 1)
                tokenOpen.attrs = [["style", `color:rgb(${r},${g},${b})`]]

                const oldPos = state.pos
                const oldMax = state.posMax
                
                state.pos = contentStart
                state.posMax = contentEnd
                state.md.inline.tokenize(state)
                
                state.pos = contentEnd
                state.posMax = oldMax

                state.push("color_close", "span", -1)

                state.pos = contentEnd + 8
                
                return true
            }

            md.inline.ruler.before("html_inline", "color", tokenize)
        })
        .use(md => {
            function tokenize(state, silent) {
                const start = state.pos;
                const max = state.posMax;

                if (state.src.charCodeAt(start) !== 0x3C) return false

                const match = state.src.slice(start).match(/^<font=([^>;]+)(?:;(\d+))?>/);
                if (!match) return false

                if (silent) return true

                let fontFamily = match[1];
                const fontSize = match[2] ? parseInt(match[2]) : null;

                fontFamily = fontFamily.replace(/\\([\\;>])/g, "$1");

                let styleAttr = `font-family:${fontFamily}`;
                if (fontSize) styleAttr += `;font-size:${Math.min(Math.max(fontSize, 1), 100)}px`

                const contentStart = start + match[0].length;
                const contentEnd = state.src.indexOf("</font>", contentStart);
                
                if (contentEnd === -1) return false

                const tokenOpen = state.push("font_open", "span", 1);
                tokenOpen.attrs = [["style", styleAttr]];

                const oldPos = state.pos;
                const oldMax = state.posMax;
                
                state.pos = contentStart;
                state.posMax = contentEnd;
                state.md.inline.tokenize(state);
                
                state.pos = contentEnd;
                state.posMax = oldMax;

                state.push("font_close", "span", -1);

                state.pos = contentEnd + 7;
                
                return true;
            }

            md.inline.ruler.before("html_inline", "font", tokenize);
        })
    } else { md = {renderInline: e => e} }

    var imgwhite = [
        /^https?:\/\/i\.imgur\.com\/([A-Za-z0-9_-]+)\.[A-Za-z0-9]+$/,
        /^https?:\/\/www\.dropbox\.com\/([A-Za-z0-9_%\/-]+)$/,

        /^https:\/\/[A-Za-z0-9_.-]*discordapp\.net\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]*discordapp\.com\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]*githubassets\.com\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]*githubusercontent\.com\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]+wikimedia\.org\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]+wikipedia\.org\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]+wikinews\.org\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]+wikidata\.org\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]*ibb\.co\.com\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]*ibb\.co\/([A-Za-z0-9_%\/.\-?&=]+)$/,

        /^https?:\/\/[A-Za-z0-9_.-]+rawr\.party\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https?:\/\/cdn\.lenofag\.ru\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https?:\/\/[A-Za-z0-9_.-]*gml\.fish\/([A-Za-z0-9_%\/.\-?&=]+)\.[A-Za-z0-9]+$/,
        /^https?:\/\/[A-Za-z0-9_.-]+c0nfuse\.ru\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https?:\/\/[A-Za-z0-9_.-]+rekt\.party\/([A-Za-z0-9_%\/.\-?&=]+)$/,

        /^https:\/\/[A-Za-z0-9_.-]*e621\.net\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]*e926\.net\/([A-Za-z0-9_%\/.\-?&=]+)$/,
        /^https:\/\/[A-Za-z0-9_.-]*gelbooru\.com\/([A-Za-z0-9_%\/.\-?&=]+)$/,
    ]

    var le = /[ ]+$/
    var le2 = /^[ ]+/
    var scb, settings = {}
    var OpenLink = a => gmlfi.OpenLink(a)
    var MakeMessage = () => document.createElement("span")
    var PREL_TIMEOUT
    var AddText = data => {
        scb = Math.abs(document.body.scrollHeight - document.body.scrollTop - document.body.clientHeight)
        const oldd = typeof data == "string" ? data : false
        if(oldd) {
            const prel = document.body.firstChild
            if(prel && prel.JSON_DATA == oldd) {
                const cntr = prel.querySelector(".counter")
                if(cntr) {
                    cntr.textContent = ` x${Number(cntr.textContent.match(/^ x(\d+)$/)?.[1] ?? 0) + 1}`
                    cntr.classList.remove("anim-change")
                    cntr.classList.add("anim-change")
                } else {
                    let cn = document.createElement("span")
                        cn.textContent = " x2"
                        cn.classList.add("counter")
                        cn.classList.add("anim-change")
                    prel.appendChild(cn)
                    prel.addEventListener("animationend", () => {
                        cn.classList.remove("anim-change")
                    })
                }
                prel.classList.remove("disappear")
                if(PREL_TIMEOUT) clearTimeout(PREL_TIMEOUT)
                PREL_TIMEOUT = setTimeout(() => {
                    PREL_TIMEOUT = null
                    prel.classList.add("anim-disappear")
                    prel.addEventListener("animationend", () => {
                        prel.classList.remove("anim-disappear")
                        prel.classList.add("disappear")
                    })
                }, settings.animhide * 1000)
                return
            }
        }
        var c = MakeMessage()
        c.classList.add("message", "anim-show")
        if(oldd) c.JSON_DATA = oldd
        var cc = MakeMessage()
        data = typeof data == "object" ? data : JSON.parse(data);
        data.forEach(el => {
            if(typeof el == "object") {
                if(el.r != null) cc.style.color = `rgb(${el.r}, ${el.g}, ${el.b})`
                if(el.html != null || el.text != null) {
                    cc.innerHTML = el.html
                    if(el.text) cc.textContent = el.text
                    if(el.style) cc.style = el.style;
                    if(el.class) typeof el.class == "object" ? cc.classList.add(...el.class) : cc.classList.add(el.class);
                    c.appendChild(cc)
                    cc = MakeMessage()
                }
            } else {
                var t = el.toString()
                cc.innerHTML = md.render(t).replace(/<\/?p>\n?/gm, "")
                var m = t.match(le); if(m) cc.innerHTML += m;
                    m = t.match(le2); if(m) cc.innerHTML = m + cc.innerHTML;
                c.appendChild(cc)
                cc = MakeMessage()
            }
        })
        if(cc && cc.textContent != "") c.appendChild(cc)
        c.querySelectorAll("a").forEach(el => {
            var isimg
            imgwhite.forEach(r => {
                if(r.test(el.href)) {isimg = true; el.classList.add("img-url")}
            })
            el.addEventListener("click", e => {
                e.preventDefault();
                if(isimg && !el.classList.contains("img-shown")) {
                    el.classList.add("img-shown")
                    var img = document.createElement("img")
                        img.src = e.target.href
                        img.addEventListener("click", e => OpenLink(e.target.src))
                        el.imagePreviewElement = img
                    c.appendChild(img)
                }
                else if(el.classList.contains("img-shown") && el.imagePreviewElement) {el.imagePreviewElement.remove(); el.classList.remove("img-shown")}
                else OpenLink(e.target.href)
            })
        })
        document.body.insertBefore(c, document.body.firstChild)
        setTimeout(() => {
            c.classList.remove("anim-show");
            c.classList.add("anim-disappear")
            c.addEventListener("animationend", () => {
                c.classList.remove("anim-disappear")
                c.classList.add("disappear")
            })
        }, settings.animhide * 1000)
        var spans = document.body.querySelectorAll("span.message")
        if(spans.length > settings.maxhistory) spans[spans.length - 1].remove()
    }
    var SetActive = a => {
        if(a) document.body.classList.add("active"); else document.body.classList.remove("active")
        ScrollToBottom(true)
    }
    var ScrollToBottom = f => {
        if(f || !document.body.classList.contains("active") || scb < 1) window.scrollTo(0, document.body.scrollHeight)
    }
    var UpdateStyle = data => {
        data = typeof data == "object" ? data : JSON.parse(data);
        var arr = []
        Object.entries(data).forEach(el => {
            if(typeof el[1] != "object") settings[el[0]] = el[1]
            else arr[el[0]] = Object.entries(el[1]).map(e => `${e[0]}: ${e[1]}`)
        })
        stylecustom.textContent = Object.entries(arr).map(el => `${el[0]} {${el[1].join(";")}}`).join("\n")
    }

    if(mdlox) {
        console.log("markdownit haven't loaded, disabling")
        AddText(["Похоже, что у Вас не получилось подключиться к CDN JSDelivr, Markdown парсер отключен"])
    }
</script>
]=]

local settings = { -- second argument changes css when deactivated
    {"blur", "Эффект Blur для фона", nil, true},
    {"outline", "Черная обводка текста", {["span.message"] = {["text-shadow"] = "none"}}, true},
    {"anim-show", "Анимация появления сообщения", {[".anim-show"] = {["animation"] = "none"}}, true},
    true,
    {"fontfamily", "Шрифт текста в чате", {["span.message"] = {["font-family"] = "\"%s\", Verdana, Geneva, Tahoma, sans-serif"}}, {"Roboto", "Consolas", "Segue UI", true}},
    {"fontsize", "Размер текста в чате", {["span.message"] = {["font-size"] = "%spx"}}, 16},
    {"fontweight", "Жирность текста в чате", {["span.message"] = {["font-weight"] = "%s"}}, 500, {100, 900}},
    {"textalign", "Позиция текста в чате", {["span.message"] = {["text-align"] = "%s"}}, {"start", "end", "center", "justify"}},
    true,
    {"anim-disappear", "Длительность исчезания сообщения", {["body:not(.active) .anim-disappear"] = {["animation"] = "disappear %ss both"}}, 5, {0, 10}},
    {"anim-hide", "Время до исчезания сообщения", "animhide", 10, {1, 30}},
    {"img-maxwidth", "Максимальный размер изображений", {["img"] = {["max-width"] = "%spx"}}, 400, {50, 1000}},
    true,
    {"maxhistory-html", "Максимальное количество сообщений", "maxhistory", 200, {50, 500}},
    {"maxhistory-entry", "Размер истории ваших сообщений", nil, 200, {50, 500}},
    true,
    {"chattags-show", "Показывать чат-теги", {[".chattag"] = {["display"] = "none"}}, true},
    {"chattags-outline", "Черная обводка чат-тегов", {[".chattag"] = {["border"] = "none"}}, true},
    {"chattags-radius", "Округление чат-тегов", {[".chattag"] = {["border-radius"] = "%spx"}}, 0, {0, 128}},
    true,
    {"bgcolor", "Цвет фона чата", nil, bg},
    {"messagebgcolor", "Цвет фона сообщения", {["span.message"] = {["background"] = "linear-gradient(90deg, %s 0%%, rgba(0, 0, 0, 0) 100%%)"}}, bg},
}

gmlfi.chat = gmlfi.chat or {}
gmlfi.chat.Styles = gmlfi.chat.Styles or {}
gmlfi.chat.AddStyle = function(data)
    local s = gmlfi.chat.Styles
    for k, v in pairs(data) do
        local t = s[k] or {}
        if not s[k] then s[k] = t end
        for kk, vv in pairs(v) do t[kk] = vv end
    end
    gmlfi.chat.UpdateSettings()
end

gmlfi.chat.settings = gmlfi.chat.settings or {}
gmlfi.chat.SaveSettings = function()
    timer.Create("LFI:Chat.Settings", 5, 1, function()
        gmlfi.file.Write("chat_settings.json", util.TableToJSON(gmlfi.chat.settings))
    end)
end

gmlfi.chat.UpdateSettings = function()
    if IsValid(gmlfi.chat.HTML) then
        local data, sets = table.Copy(gmlfi.chat.Styles), gmlfi.chat.settings
        for _, v in ipairs(settings) do
            if v == true then continue end
            local k = v[1]
            if v[3] and (type(v[4]) ~= "boolean" or not sets[k]) then
                if type(v[3]) == "string" then
                    data[v[3]] = sets[k]
                else
                    for kk, vv in pairs(v[3]) do
                        if data[kk] then
                            for kkk, vvv in pairs(vv) do data[kk][kkk] = vvv end
                        end
                        data[kk] = data[kk] or table.Copy(vv)
                        for kkk, vvv in pairs(data[kk]) do data[kk][kkk] = string.format(vvv, sets[k]) end
                    end
                end
            end
        end
        gmlfi.chat.HTML:QueueJavascript("UpdateStyle('" .. string.JavascriptSafe(util.TableToJSON(data)) .. "')")
    end
    gmlfi.chat.SaveSettings()
end

if not next(gmlfi.chat.settings) then local data = gmlfi.file.Read("chat_settings.json") if data then gmlfi.chat.settings = util.JSONToTable(data) or {} end end
for _, v in ipairs(settings) do
    if v == true then continue end
    local k = v[1]
    if gmlfi.chat.settings[k] == nil then gmlfi.chat.settings[k] = v[4] and (type(v[4]) == "table" and v[4][1] or v[4]) or false end
end

gmlfi.chat.Load = function()
    if IsValid(gmlfi.chat.Frame) then gmlfi.chat.Frame:Remove() gmlfi.chat.Frame = nil end
    local webmats, sets = gmlfi.vgui.webmats, gmlfi.chat.settings

    local fwo, fho = ww(700), hh(360)
    local fw, fh = unpack(gmlfi.chat.settings.size or {fwo, fho})
    local fr = vgui.Create("DFrame")
    fr:SetPos(unpack(gmlfi.chat.settings.pos or {ww(50), hh(680)}))
    fr:SetSize(fw, fh)
    fr:SetTitle("")
    fr:ShowCloseButton(false)
    local fx, fy = fr:GetPos()
    fr.Paint = function(self, w, h)
        if not gmlfi.chat.Opened then return end
        
        if gmlfi.chat.settings.blur then
            surface.SetMaterial(blur)
            surface.SetDrawColor(255, 255, 255, 255)

            local x, y = self:LocalToScreen( 0, 0 )
            for i = 0.33, 1, 0.33 do
                blur:SetFloat("$blur", 5 * i)
                blur:Recompute()

                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
            end
        end
        
        draw.RoundedBox(0, 0, 0, w, h, sets.bgcolor or bg)
        surface.SetDrawColor(0, 0, 0, 165)
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(0, 0, w, h)

        draw.SimpleText("Чат", FONT_TITLE, ww(11), hh(5), wh)
        surface.SetDrawColor(255, 255, 255)
        surface.DrawLine(ww(58), hh(4), ww(58), hh(27))

        do
            if self.NextThink and self.NextThink > CurTime() then return end
            self.NextThink = CurTime() + 5
            local x, y = self:GetPos()
            if x ~= fx or y ~= fy then gmlfi.chat.settings.pos, fx, fy = {x, y}, x, y gmlfi.chat.SaveSettings() end
        end
    end
    fr.PaintOver = function(self, w, h)
        if gmlfi.chat.Opened then
            surface.SetDrawColor(255, 255, 255)
            surface.DrawLine(ww(7), hh(29), w - ww(7), hh(29))
        end
    end

    fr.Open = function(self)
        self:MakePopup()
        gmlfi.chat.Opened = true
        gmlfi.chat.Entry.HistoryPos = 0
        gmlfi.chat.Entry:RequestFocus()
        gmlfi.chat.HTML:QueueJavascript("SetActive(true)")
        gmlfi.chat.SetTyping(true)
        chat.Close()
    end

    fr.Close = function(self)
        gmlfi.chat.Opened = false
        self:SetMouseInputEnabled(false)
        self:SetKeyboardInputEnabled(false)
        self:KillFocus()
        gmlfi.chat.HTML:QueueJavascript("SetActive(false)")
        gmlfi.chat.SetTyping(false)
        if IsValid(self.SettingsPanel) then return self.SettingsPanel:Remove() end
        chat.Close() -- sometimes an invisible default chat opens and blocks menu opening
    end

    fr.OnRemove = function(self)
        if IsValid(self.SettingsPanel) then self.SettingsPanel:Remove() end
    end

    gmlfi.chat.Frame = fr

    local html = vgui.Create("DHTML", fr)
    html:SetPos(ww(7), hh(30))
    html:SetAllowLua(false)
    html:SetHTML(HTML_SCRIPT)
    html:AddFunction("gmlfi", "OpenLink", function(a) gui.OpenURL(a) end)

    html.PaintOver = function(self, w, h)
        if gmlfi.chat.Opened then
            surface.SetDrawColor(0, 0, 0)
            surface.SetMaterial(gradientd)
            surface.DrawTexturedRect(0, 0, w, hh(19))
        end
        if not self.HTMLReady then
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(webmats.gmlfi_logo)
            surface.DrawTexturedRect(ww(251) / fwo * fw, ww(37) / fho * fh, hh(184) / fwo * fw, hh(184) / fwo * fw)
            surface.SetDrawColor(0, 0, 0, 127)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("Чат загружается...", FONT_TITLE, w / 2, hh(229) / fho * fh, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif self.HTMLReadyWhen and self.HTMLReadyWhen > CurTime() then
            local l = Lerp((self.HTMLReadyWhen - CurTime()) / 1, 0, 255)
            surface.SetDrawColor(255, 255, 255, l)
            surface.SetMaterial(webmats.gmlfi_logo)
            surface.DrawTexturedRect(ww(251) / fwo * fw, ww(37) / fho * fh, hh(184) / fwo * fw, hh(184) / fwo * fw)
            surface.SetDrawColor(0, 0, 0, l / 2)
            surface.DrawRect(0, 0, w, h)
            local wh = Color(wh.r, wh.g, wh.b, l)
            draw.SimpleText("Чат загружен!", FONT_TITLE, w / 2, hh(229) / fho * fh, wh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif self.HTMLReadyWhen then self.HTMLReadyWhen = nil end
    end

    html.OnBeginLoadingDocument = function(self) self.HTMLReady = false end
    html.OnDocumentReady = function(self) self.HTMLReady, self.HTMLReadyWhen = true, CurTime() + 1 end

    html.ScrollToBottom = function(self) self:QueueJavascript("ScrollToBottom()") end
    html.AddText = function(self, data) self:QueueJavascript("AddText('" .. string.JavascriptSafe(util.TableToJSON(data)) .. "')") end

    gmlfi.chat.HTML = html

    local tb = vgui.Create("DPanel", fr)
    tb.Paint = function(self, w, h) if gmlfi.chat.Opened then draw.RoundedBox(0, 0, 0, w, h, sets.bgcolor or bg) end end

    local te = vgui.Create("DTextEntry", tb)
    te:Dock(FILL)
    te:DockMargin(ww(18), 0, 0, 0)
    te:RequestFocus()
    te:SetAllowNonAsciiCharacters(true)
    te:SetHistoryEnabled(true)
    te:SetTabbingDisabled(true)
    te:SetPlaceholderText("Напишите сообщение...")
    te:SetFont(FONT_CAT)
    te:SetDrawLanguageID(false)
    te.Paint = function(self, w, h)
        if gmlfi.chat.Opened then
            if self:GetValue() ~= "" then self:DrawTextEntryText(wh, ts, wh)
            elseif self:GetPlaceholderText() and self:GetPlaceholderText() ~= "" then
                local old = self:GetText()
                self:SetText(self:GetPlaceholderText())
                self:DrawTextEntryText(gr, ts, wh)
                self:SetText(old)
            end
        end
    end

    te.OnKeyCodeTyped = function(self, code)
        -- if code == KEY_ESCAPE then
        --     fr:Close()
        --     gui.HideGameUI()
        -- end

        if code == KEY_ENTER then
            self:Send()
        end

        -- history functionality restoration - https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/vgui/dtextentry.lua#L84-L98
        if code == KEY_UP then
            self.HistoryPos = self.HistoryPos - 1
            self:UpdateFromHistory()
        end

        if code == KEY_DOWN or code == KEY_TAB then
            self.HistoryPos = self.HistoryPos + 1
            self:UpdateFromHistory()
        end
    end

    te.Send = function(self)
        local val = self:GetValue()
        if string.Trim(self:GetValue()) ~= "" then
            if gmlfi.chat.Prefix then val = gmlfi.chat.Prefix .. val end
            gmlfi.chat.Say(val)
            self:AddHistory(val)
            if #self.History > sets["maxhistory-entry"] then table.remove(self.History, 1) end
            timer.Create("LFI:Chat.History", 5, 1, function()
                gmlfi.file.Write("chat_history.json", util.TableToJSON(self.History))
            end)
        end
        self:SetText("")
        fr:Close()
    end

    local hist = gmlfi.file.Read("chat_history.json")
    if hist then te.History = util.JSONToTable(hist) or {} end

    gmlfi.chat.Entry = te

    gmlfi.chat.Prefix = nil
    local po = vgui.Create("DButton", tb)
    po:SetPos(ww(6), 0)
    po:SetSize(ww(8), hh(29))
    po:SetText("")
    po.Paint = function(self, w, h)
        if gmlfi.chat.Opened then
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(webmats.collapse_arrow)
            surface.DrawTexturedRectRotated(w - ww(3), h / 2, ww(6), hh(11), gmlfi.chat.Prefix and 180 or 0)
            if gmlfi.chat.Prefix then
                draw.SimpleText(gmlfi.chat.Prefix, FONT_CAT, 0, hh(5), ts)
            end
        end
    end
    po.DoClick = function()
        if gmlfi.chat.Prefix then gmlfi.chat.Prefix = nil po:SetWide(ww(6)) te:DockMargin(ww(18), 0, 0, 0) return end
        gmlfi.vgui.request.String("Введите префикс сообщения", "Префикс, например, !r , @ , !pm", function(str)
            if str then
                surface.SetFont(FONT_CAT)
                local tw = surface.GetTextSize(str)
                po:SetWide(ww(12) + tw) te:DockMargin(ww(22) + tw, 0, 0, 0)
                gmlfi.chat.Prefix, gmlfi.chat.PrefixLast = str, str
            end
        end, gmlfi.chat.PrefixLast, true)
    end

    local sb = vgui.Create("DButton", fr)
    sb:SetSize(ww(29), hh(29))
    sb:SetText("")
    sb.Paint = function(self, w, h)
        if gmlfi.chat.Opened then
            draw.RoundedBox(0, 0, 0, w, h, sets.bgcolor or bg)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(webmats.chat_send)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    sb.DoClick = function(self, w, h)
        te:Send()
    end

    local osettings = vgui.Create("DButton", fr)
    osettings:SetSize(ww(18), hh(18))
    osettings:SetText("")
    osettings.Paint = function(self, w, h)
        if gmlfi.chat.Opened then
            draw.RoundedBox(0, 0, 0, w, h, sets.bgcolor or bg)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(webmats.chat_settings)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    osettings.DoClick = function(self, w, h)
        if IsValid(fr.SettingsPanel) then return fr.SettingsPanel:Remove() end
        local set = vgui.Create("DFrame")
        local x, y = fr:GetPos()
        x = x + fw
        local lw, lh = ww(280), fh
        set:SetPos(x + (x + lw > sw and -(lw + ww(51)) or ww(4)), y)
        set:SetSize(lw, lh)
        set:SetTitle("")
        set:ShowCloseButton(false)
        set:SetSizable(true)
        set:MakePopup()
        set.Paint = function(self, w, h)
            if gmlfi.chat.settings.blur then
                surface.SetMaterial(blur)
                surface.SetDrawColor(255, 255, 255, 255)

                local x, y = self:LocalToScreen( 0, 0 )
                for i = 0.33, 1, 0.33 do
                    blur:SetFloat("$blur", 5 * i)
                    blur:Recompute()

                    render.UpdateScreenEffectTexture()
                    surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
                end
            end
            
            draw.RoundedBox(0, 0, 0, w, h, sets.bgcolor or bg)
            draw.SimpleText("Настройки", FONT_TITLE, ww(6), hh(5), wh)
        end
        fr.SettingsPanel = set

        local reload = vgui.Create("DButton", set)
        reload:SetPos(lw - ww(46), hh(6))
        reload:SetSize(ww(18), hh(18))
        reload:SetText("")
        reload.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, sets.bgcolor or bg)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(webmats.chat_refresh)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        reload.DoClick = function(self, w, h)
            gmlfi.chat.Load()
        end

        local close = vgui.Create("DButton", set)
        close:SetPos(lw - ww(24), hh(6))
        close:SetSize(ww(18), hh(18))
        close:SetText("")
        close.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, sets.bgcolor or bg)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(webmats.close)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        close.DoClick = function(self, w, h)
            set:Close()
        end

        local set = vgui.Create("DScrollPanel", set)
        set:SetPos(0, hh(28))
        set:SetSize(lw, lh - hh(28))
        set.Paint = function() end
        set.VBar:SetWidth(ww(2))
        set.VBar:SetHideButtons(true)

        local k = {0}
        local header = function(name, parent, k)
            local p = vgui.Create("DPanel", parent)
            p:SetPos(ww(4), k[1])
            p:SetSize(ww(268), hh(16))
            p.Paint = function(self, w, h)
                draw.SimpleText(name, FONT_SETTINGS, 0, 0, wh)
            end
            k[1] = k[1] + hh(20)
            return p
        end

        local types types = {
            boolean = function(k, kk, v, set)
                local b = vgui.Create("DButton", set)
                b:SetPos(ww(6), k[1])
                b:SetSize(ww(268), hh(16))
                b:SetText("")
                b.Paint = function(self, w, h)
                    surface.SetDrawColor(self:IsDown() and bs or self:IsHovered() and bh or bi)
                    surface.DrawRect(0, 0, ww(16), h)
                    if gmlfi.chat.settings[kk] then
                        surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(webmats.checked)
                        surface.DrawTexturedRect(0, 0, ww(16), h)
                    end
                    draw.SimpleText(v[2], FONT_SETTINGS, ww(18), h / 2, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                b.DoClick = function()
                    gmlfi.chat.settings[kk] = not gmlfi.chat.settings[kk]
                    if v[3] then gmlfi.chat.UpdateSettings() end
                end
                k[1] = k[1] + hh(20)
            end,
            string = function(k, kk, v, set)
                header(v[2], set, k)
                local tb = vgui.Create("DPanel", set)
                tb:SetPos(ww(6), k[1])
                tb:SetSize(ww(268), hh(16))
                tb.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, bi) end

                local b = vgui.Create("DTextEntry", tb)
                b:Dock(FILL)
                b:SetPlaceholderText("Введите текст...")
                b:SetFont(FONT_SETTINGS)
                b:SetDrawLanguageID(false)
                b:SetValue(gmlfi.chat.settings[kk])
                b.Paint = function(self, w, h)
                    if self:GetValue() ~= "" then self:DrawTextEntryText(wh, ts, wh)
                    elseif self:GetPlaceholderText() and self:GetPlaceholderText() ~= "" then
                        local old = self:GetText()
                        self:SetText(self:GetPlaceholderText())
                        self:DrawTextEntryText(gr, ts, wh)
                        self:SetText(old)
                    end
                end
                b.OnEnter = function(_, t)
                    gmlfi.chat.settings[kk] = t
                    if v[3] then gmlfi.chat.UpdateSettings() end
                end
                k[1] = k[1] + hh(20)
            end,
            number = function(k, kk, v, set)
                header(v[2], set, k)
                local tb = vgui.Create("DPanel", set)
                tb:SetPos(ww(6), k[1])
                tb:SetSize(ww(268), hh(16))
                tb.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, bi) end

                local b = vgui.Create("DNumberWang", tb)
                b:Dock(FILL)
                b:SetPlaceholderText("Введите число...")
                b:SetFont(FONT_SETTINGS)
                if v[5] then b:SetMinMax(v[5][1], v[5][2]) else b:SetMinMax(1, 100) end
                b:SetValue(gmlfi.chat.settings[kk])
                b.Paint = function(self, w, h)
                    if self:GetValue() ~= "" then self:DrawTextEntryText(wh, ts, wh)
                    elseif self:GetPlaceholderText() and self:GetPlaceholderText() ~= "" then
                        local old = self:GetText()
                        self:SetText(self:GetPlaceholderText())
                        self:DrawTextEntryText(gr, ts, wh)
                        self:SetText(old)
                    end
                end
                b.OnValueChanged = function(_, t)
                    gmlfi.chat.settings[kk] = t
                    if v[3] then gmlfi.chat.UpdateSettings() end
                end
                k[1] = k[1] + hh(20)
            end,
            table = function(k, kk, v, set)
                if v[4].r then return types.Color(k, kk, v, set) end
                header(v[2], set, k)
                local b = vgui.Create("DButton", set)
                b:SetPos(ww(6), k[1])
                b:SetSize(ww(268), hh(16))
                b:SetText("")
                b.Paint = function(self, w, h)
                    surface.SetDrawColor(self:IsDown() and bs or self:IsHovered() and bh or bi)
                    surface.DrawRect(0, 0, w, h)
                    draw.SimpleText(gmlfi.chat.settings[kk] or "Выберите значение...", FONT_SETTINGS, ww(4), h / 2, wh, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                b.DoClick = function()
                    local dm = DermaMenu()
                    for _, vv in ipairs(v[4]) do
                        dm:AddOption(vv == true and "Выбрать значение..." or vv, function()
                            if vv == true then
                                gmlfi.vgui.request.String("Введите название шрифта (на Windows найдите \"Параметры шрифта\")", "Полное название шрифта, например, Times New Roman", function(str)
                                    if str then
                                        gmlfi.chat.settings[kk] = str
                                        if v[3] then gmlfi.chat.UpdateSettings() end
                                    end
                                end)
                            else
                                gmlfi.chat.settings[kk] = vv
                                if v[3] then gmlfi.chat.UpdateSettings() end
                            end
                        end)
                    end
                    dm:Open()
                end
                k[1] = k[1] + hh(20)
            end,
            Color = function(k, kk, v, set)
                header(v[2], set, k)
                local s = gmlfi.chat.settings[kk]
                if s and type(s) == "string" and string.match(s, "^rgba%(") then
                    local r, g, b, a = string.match(s, "^rgba%((%d+), (%d+), (%d+), ([0-9%.-]+)%)$")
                    s = Color(r, g, b, a * 255)
                end
                local b = vgui.Create("DColorMixer", set)
                b:SetPos(ww(4), k[1])
                b:SetSize(ww(268), hh(268))
                b:SetColor(s or Color(255, 255, 255))
                b.ValueChanged = function(_, col)
                    gmlfi.chat.settings[kk] = v[3] and string.format("rgba(%s, %s, %s, %s)", col.r, col.g, col.b, col.a / 255) or col
                    if v[3] then gmlfi.chat.UpdateSettings() end
                end
                k[1] = k[1] + hh(272)
            end
        }
        
        for _, v in ipairs(settings) do
            if v == true then
                local p = vgui.Create("DPanel", set)
                p:SetPos(ww(4), k[1])
                p:SetSize(ww(268), hh(5))
                p.Paint = function(self, w, h)
                    surface.DrawLine(0, h - 1, w, h - 1)
                end
                k[1] = k[1] + hh(8)
            else types[type(v[4])](k, v[1], v, set) end
        end
    end

    local close = vgui.Create("DButton", fr)
    close:SetSize(ww(18), hh(18))
    close:SetText("")
    close.Paint = function(self, w, h)
        if gmlfi.chat.Opened then
            draw.RoundedBox(0, 0, 0, w, h, sets.bgcolor or bg)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(webmats.close)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    close.DoClick = function(self, w, h)
        fr:Close()
    end

    local pl = fr.PerformLayout
    fr.PerformLayout = function(self, w, h)
        pl(self, w, h)
        fw, fh = w, h
        fr:SetSizable(true)
        fr:SetDraggable(true)
        html:SetSize(fw - ww(14), fh - hh(70))
        tb:SetPos(ww(7), fh - hh(36))
        tb:SetSize(fw - ww(47), hh(29))
        sb:SetPos(fw - ww(36), fh - hh(36))
        osettings:SetPos(fw - ww(47), hh(6))
        close:SetPos(fw - ww(25), hh(6))
        gmlfi.chat.settings.size = {fw, fh}
        gmlfi.chat.SaveSettings()
    end
    fr:PerformLayout(fr:GetPos())

    gmlfi.chat.UpdateSettings()
    hook.Run("LFI:Chat.Loaded")
end

do
    if gmlfi.chat.panels and gmlfi.chat.panels.frame then gmlfi.chat.panels.frame:Remove() gmlfi.chat.panels = nil end
    gmlfi.chat.SetTyping = function(mode) net.Start("LFI:Chat.Typing") net.WriteBool(not not mode) net.SendToServer() end
    gmlfi.chat._chatAddText = gmlfi.chat._chatAddText or chat.AddText
    gmlfi.chat.Say = function(content, isteam)
        net.Start("LFI:Chat")
            net.WriteString(content)
            net.WriteBool(isteam or false)
        net.SendToServer()

        gmlfi.chat.HTML:ScrollToBottom()
    end

    gmlfi.chat.Open = function() if not IsValid(gmlfi.chat.Frame) then gmlfi.chat.Load() end gmlfi.chat.Frame:Open() end

    hook.Add("InitPostEntity", "LFI:Chat", function() timer.Simple(1, function() gmlfi.chat.Load() gmlfi.chat._Done = true end) end)
    if gmlfi.chat._Done then chat.AddText(Color(255, 200, 150), "Внимание, чат будет очищен и перезагружен через 3 секунды!") timer.Create("LFI:Chat.Reload", 3, 1, gmlfi.chat.Load) end

    local bindcases = { -- better than switch ngl
        ["messagemode"] = gmlfi.chat.Open,
        ["messagemode2"] = gmlfi.chat.Open,
    }

    hook.Add("PlayerBindPress", "LFI:Chat", function(_, bind)
        if bindcases[bind] then bindcases[bind]() return true else return end
    end)

    hook.Add("OnPauseMenuShow", "LFI:Chat", function()
        if gmlfi.chat.Opened and IsValid(gmlfi.chat.Frame) then gmlfi.chat.Frame:Close() return false end
    end)

    local goodchattypes = {
        ["none"] = true, ["namechange"] = true, ["servermsg"] = true
    }

    hook.Add("ChatText", "LFI:Chat", function(_, _, text, type)
        if goodchattypes[type] then chat.AddText(text) end
    end)

    hook.Add("HUDShouldDraw", "LFI:Chat", function(el) if el == "CHudChat" then return false end end)

    local cattypes = {
        ["table"] = function(obj) return obj end,
        ["Player"] = function(obj)
            return team.GetColor(obj:Team()), obj:Name(), wh
        end,
    }

    chat.AddText = function(...)
        if not IsValid(gmlfi.chat.HTML) then return gmlfi.chat._chatAddText(...) end
        local t = {}

        for _, obj in ipairs({...}) do
            if cattypes[type(obj)] then
                table.Add(t, {cattypes[type(obj)](obj)})
            else t[#t + 1] = tostring(obj) end
        end

        gmlfi.chat.HTML:AddText(t)
        gmlfi.chat.HTML:ScrollToBottom()
        gmlfi.chat._chatAddText(...)
    end

    net.Receive("LFI:Chat", function()
        local who, text, isteam = net.ReadEntity(), net.ReadString(), net.ReadBool()

        local isconsole = not IsValid(who) or not who:IsPlayer()
        hook.Run("OnPlayerChat", isconsole and NULL or who, text, isteam, isconsole or not who:Alive())
    end)
end