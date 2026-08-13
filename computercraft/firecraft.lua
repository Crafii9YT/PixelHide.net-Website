-- FIRECRAFT BROWSER (Advanced HTML & Scrolling Edition)
-- CC:Tweaked

local W, H = term.getSize()

--------------------------------------------------
-- SETTINGS & STATE
--------------------------------------------------

local settings = {
    theme = 1,
}

local themes = {
    { name = "Fire", bg = colors.black, fg = colors.white, accent = colors.orange, header = colors.red, button = colors.gray, selected = colors.orange },
    { name = "Ocean", bg = colors.black, fg = colors.white, accent = colors.cyan, header = colors.blue, button = colors.gray, selected = colors.cyan }
}

local currentURL = "firecraft://newtab"
local history = {}
local buttons = {}
local selectedButton = 1

-- Für das Scrollen von langen Seiten
local scrollOffset = 0
local parsedLines = {}
local parsedButtons = {}

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function T()
    return themes[settings.theme]
end

local function clear()
    term.setBackgroundColor(T().bg)
    term.setTextColor(T().fg)
    term.clear()
    term.setCursorPos(1, 1)
end

local function line(y, color)
    term.setBackgroundColor(color)
    term.setCursorPos(1, y)
    write(string.rep(" ", W))
end

local function center(y, text, color)
    if #text > W then text = text:sub(1, W) end
    local x = math.floor((W - #text) / 2) + 1
    if x < 1 then x = 1 end
    term.setCursorPos(x, y)
    term.setTextColor(color or T().fg)
    write(text)
end

--------------------------------------------------
-- UI COMPONENTS
--------------------------------------------------

local function drawHeader()
    line(1, T().header)
    term.setTextColor(colors.white)
    term.setCursorPos(2, 1)
    write("FIRECRAFT WEB BROWSER")
end

local function drawAddress()
    local width = W - 4
    local text = currentURL
    if #text > width - 4 then
        text = text:sub(1, width - 4)
    end
    local bar = "[ " .. text .. " ]"
    term.setCursorPos(2, 3)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    write(bar)
    if #bar < width then
        write(string.rep(" ", width - #bar))
    end
    term.setBackgroundColor(T().bg)
end

local function drawFooter()
    line(H, colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(2, H)
    write("UP/DN: Select | I/K: Scroll | ENTER: Open | L: URL | Q: Quit")
end

--------------------------------------------------
-- HTML PARSER (Wandelt HTML in lesbaren Text & Buttons)
--------------------------------------------------

local function parseHTML(html)
    parsedLines = {}
    parsedButtons = {}

    -- 1. Finde alle <button>...</button> Elemente und mache Buttons daraus
    for btnText in html:gmatch("<button[^>]*>(.-)</button>") do
        -- HTML Tags im Button-Text bereinigen
        local cleanBtn = btnText:gsub("<[^>]+>", ""):match("^%s*(.-)%s*$")
        if cleanBtn ~= "" then
            table.insert(parsedButtons, {
                text = cleanBtn,
                action = function()
                    -- Standard-Aktion: Zeige Info oder Suche
                    currentURL = "firecraft://action/" .. cleanBtn
                end
            })
        end
    end

    -- 2. Finde alle Links <a href="...">...</a>
    for href, linkText in html:gmatch('<a[^>]*href="([^"]+)"[^>]*>(.-)</a>') do
        local cleanText = linkText:gsub("<[^>]+>", ""):match("^%s*(.-)%s*$")
        if cleanText ~= "" and href:match("^https?://") then
            table.insert(parsedButtons, {
                text = cleanText:sub(1, 15) .. " ->",
                action = function()
                    currentURL = href
                end
            })
        end
    end

    -- Falls keine Buttons im HTML waren, Standard-Buttons hinzufügen
    if #parsedButtons == 0 then
        table.insert(parsedButtons, { text = "Zurück", action = function() 
            if #history > 0 then
                currentURL = history[#history]
                table.remove(history, #history)
            end
        end })
        table.insert(parsedButtons, { text = "Neue Startseite", action = function() currentURL = "firecraft://newtab" end })
    end

    -- 3. HTML-Text bereinigen für die Anzeige
    -- Entferne Skripte, Styles und Tags
    local body = html:match("<body[^>]*>(.-)</body>") or html
    body = body:gsub("<script[^>]*>.-</script>", "")
    body = body:gsub("<style[^>]*>.-</style>", "")
    
    for textLine in body:gmatch("[^\r\n]+") do
        local cleanLine = textLine:gsub("<[^>]+>", ""):match("^%s*(.-)%s*$")
        if cleanLine and cleanLine ~= "" then
            -- Zeilenumbruch für die Terminal-Breite erzwingen
            while #cleanLine > W - 4 do
                table.insert(parsedLines, cleanLine:sub(1, W - 4))
                cleanLine = cleanLine:sub(W - 3)
            end
            table.insert(parsedLines, cleanLine)
        end
    end
end

--------------------------------------------------
-- HTTP LOADER
--------------------------------------------------

local function fetchWebPage(url)
    clear()
    drawHeader()
    drawAddress()

    center(5, "Lade Webseite...", T().accent)
    term.setCursorPos(3, 7)
    term.setTextColor(colors.lightGray)
    write("Ziel: " .. url)

    local ok, response = pcall(http.get, url)

    if ok and response then
        local html = response.readAll()
        response.close()
        parseHTML(html)
    else
        parsedLines = {
            "FEHLER: Konnte keine Verbindung herstellen.",
            "Entweder ist die URL ungültig, die Seite offline,",
            "oder HTTP ist in der Server-Konfiguration gesperrt."
        }
        parsedButtons = {
            { text = "Zurück", action = function() currentURL = "firecraft://newtab" end }
        }
    end

    scrollOffset = 0
    selectedButton = 1
end

--------------------------------------------------
-- RENDER ENGINE
--------------------------------------------------

local function renderPage()
    clear()
    drawHeader()
    drawAddress()

    -- Wenn eine echte URL geladen werden soll
    if currentURL:match("^https?://") then
        if #parsedLines == 0 and #parsedButtons == 0 then
            fetchWebPage(currentURL)
        end
    end

    -- Startseite
    if currentURL == "firecraft://newtab" then
        parsedLines = {
            "Willkommen bei FireCraft Web!",
            "",
            "Gib eine beliebige Adresse ein (Taste L)",
            "oder wähle eine Beispiel-Webseite aus:"
        }
        parsedButtons = {
            { text = "Beispiel: Example.com", action = function() 
                table.insert(history, currentURL)
                currentURL = "https://example.com"
                parsedLines = {} 
            end },
            { text = "Beispiel: Info-Seite", action = function() 
                table.insert(history, currentURL)
                currentURL = "https://info.cern.ch"
                parsedLines = {} 
            end }
        }
    end

    -- Zeichne den Webseiten-Inhalt mit Scroll-Offset (Bereich: Zeile 5 bis H-7)
    local maxDisplayLines = H - 12
    local startY = 5

    for i = 1, maxDisplayLines do
        local lineIdx = i + scrollOffset
        if parsedLines[lineIdx] then
            term.setCursorPos(3, startY + i - 1)
            term.setTextColor(colors.white)
            write(parsedLines[lineIdx])
        end
    end

    -- Zeichne interaktive Buttons am unteren Bildschirmrand
    local btnY = H - 6
    for i, b in ipairs(parsedButtons) do
        if btnY < H - 1 then
            local selected = (i == selectedButton)
            local prefix = selected and "> " or "  "
            local content = prefix .. "[ " .. b.text .. " ]"

            term.setCursorPos(3, btnY)
            if selected then
                term.setBackgroundColor(T().selected)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(T().button)
                term.setTextColor(colors.white)
            end
            write(content)

            local rem = W - 2 - #content
            if rem > 0 then write(string.rep(" ", rem)) end
            term.setBackgroundColor(T().bg)
            btnY = btnY + 2
        end
    end

    drawFooter()
end

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

renderPage()

while true do
    local event, key = os.pullEvent("key")

    if key == keys.up then
        if #parsedButtons > 0 then
            selectedButton = selectedButton - 1
            if selectedButton < 1 then selectedButton = #parsedButtons end
            renderPage()
        end
    elseif key == keys.down then
        if #parsedButtons > 0 then
            selectedButton = selectedButton + 1
            if selectedButton > #parsedButtons then selectedButton = 1 end
            renderPage()
        end
    elseif key == keys.i then
        -- Scrollen nach oben
        if scrollOffset > 0 then
            scrollOffset = scrollOffset - 1
            renderPage()
        end
    elseif key == keys.k then
        -- Scrollen nach unten
        if scrollOffset < #parsedLines - 5 then
            scrollOffset = scrollOffset + 1
            renderPage()
        end
    elseif key == keys.enter then
        local button = parsedButtons[selectedButton]
        if button and button.action then
            table.insert(history, currentURL)
            button.action()
            renderPage()
        end
    elseif key == keys.l then
        -- URL frei eingeben
        clear()
        drawHeader()
        term.setCursorPos(3, 6)
        term.setTextColor(colors.white)
        write("URL eingeben (z.B. https://example.com): ")
        term.setCursorPos(3, 8)
        write("-> ")
        local customUrl = read()
        if customUrl ~= "" then
            if not customUrl:match("^https?://") then
                customUrl = "https://" .. customUrl
            end
            table.insert(history, currentURL)
            currentURL = customUrl
            parsedLines = {}
            parsedButtons = {}
            renderPage()
        end
    elseif key == keys.q then
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(1, 1)
        break
    end
end
