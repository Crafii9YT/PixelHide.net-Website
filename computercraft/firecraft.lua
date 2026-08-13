-- FIRECRAFT BROWSER (Echter HTTP & URL-Modus)
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

-- Speichert den Rohtext oder geparsten Inhalt von echten Webseiten
local pageContent = {}

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
    write("FIRECRAFT WEB")
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

local function clearButtons()
    buttons = {}
end

local function addButton(text, action)
    table.insert(buttons, { text = text, action = action })
end

local function drawButtons(y)
    for i, b in ipairs(buttons) do
        if y >= H - 1 then break end
        local selected = (i == selectedButton)
        local prefix = selected and "> " or "  "
        local content = prefix .. "[ " .. b.text .. " ]"
        
        term.setCursorPos(3, y)
        if selected then
            term.setBackgroundColor(T().selected)
            term.setTextColor(colors.black)
        else
            term.setBackgroundColor(T().button)
            term.setTextColor(colors.white)
        end
        write(content)
        
        local remaining = W - 2 - #content
        if remaining > 0 then
            write(string.rep(" ", remaining))
        end
        term.setBackgroundColor(T().bg)
        y = y + 2
    end
end

local function drawFooter()
    line(H, colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(2, H)
    write("UP/DN: Select | ENTER: Open | L: Type URL | Q: Quit")
end

--------------------------------------------------
-- NAVIGATION & HTTP LOADER
--------------------------------------------------

local function navigate(url)
    if url == currentURL then return end
    table.insert(history, currentURL)
    currentURL = url
    selectedButton = 1
end

local function back()
    if #history > 0 then
        currentURL = history[#history]
        table.remove(history, #history)
        selectedButton = 1
    end
end

-- Holt echte Webseiten-Daten über HTTP
local function fetchWebPage(url)
    clearButtons()
    clear()
    drawHeader()
    drawAddress()

    center(5, "Lade Webseite...", T().accent)
    term.setCursorPos(3, 7)
    term.setTextColor(colors.lightGray)
    write("Verbinde mit: " .. url)

    -- HTTP-Anfrage an die echte URL senden
    local ok, response = pcall(http.get, url)

    if ok and response then
        local html = response.readAll()
        response.close()

        clear()
        drawHeader()
        drawAddress()

        term.setCursorPos(3, 5)
        term.setTextColor(T().accent)
        write("Verbunden: " .. url)

        -- Einfache Extraktion von Text / Titeln aus dem HTML
        local y = 7
        term.setCursorPos(3, y)
        term.setTextColor(colors.white)
        write("Seiteninhalt (Text-Modus):")
        
        -- Zeige Ausschnitt des rohen Textes bereinigt an
        y = y + 2
        for lineText in html:gmatch("[^\r\n]+") do
            if y < H - 5 and #lineText < W - 4 then
                term.setCursorPos(3, y)
                term.setTextColor(colors.lightGray)
                write(lineText:sub(1, W - 4))
                y = y + 1
            end
        end

        -- Extrahiere gefundene Links (<a href="...">) als interaktive Buttons
        for link in html:gmatch('href="([^"]+)"') do
            if link:match("^http") and #buttons < 3 then
                local btnName = link:sub(1, 25)
                addButton("Link: " .. btnName, function()
                    navigate(link)
                end)
            end
        end

    else
        clear()
        drawHeader()
        drawAddress()
        center(7, "FEHLER: Verbindung fehlgeschlagen!", colors.red)
        center(9, "Entweder ungültige URL oder HTTP ist")
        center(10, "in der Server-Config gesperrt.")
    end

    addButton("Zurück", function() back() end)
    addButton("Neue URL eingeben", function() 
        -- Direktes URL-Prompt aufrufen
        term.setCursorPos(3, H - 2)
        term.setTextColor(colors.white)
        write("URL: ")
        local input = read()
        if input ~= "" then
            if not input:match("^https?://") then
                input = "https://" .. input
            end
            navigate(input)
        end
    end)

    drawButtons(H - 4)
    drawFooter()
end

--------------------------------------------------
-- PAGES
--------------------------------------------------

local function newTab()
    clearButtons()
    clear()
    drawHeader()
    drawAddress()

    center(6, "FIRECRAFT BROWSER", T().accent)
    center(8, "Gib eine echte Internet-Adresse ein oder")
    center(9, "wähle eine Beispiel-Seite:")

    addButton("URL frei eingeben (Taste L)", function()
        term.setCursorPos(3, 12)
        term.setTextColor(colors.white)
        write("Ziel-URL: https://")
        local url = read()
        if url ~= "" then
            navigate("https://" .. url)
        end
    end)

    addButton("Beispiel: example.com", function()
        navigate("https://example.com")
    end)

    addButton("Einstellungen", function()
        navigate("firecraft://settings")
    end)

    drawButtons(13)
    drawFooter()
end

local function settingsPage()
    clearButtons()
    clear()
    drawHeader()
    drawAddress()

    center(6, "EINSTELLUNGEN", T().accent)

    addButton("Theme wechseln", function()
        settings.theme = settings.theme % #themes + 1
    end)

    addButton("Zurück zum Start", function()
        navigate("firecraft://newtab")
    end)

    drawButtons(10)
    drawFooter()
end

--------------------------------------------------
-- RENDER & MAIN LOOP
--------------------------------------------------

local function render()
    if currentURL == "firecraft://newtab" then
        newTab()
    elseif currentURL == "firecraft://settings" then
        settingsPage()
    elseif currentURL:match("^https?://") then
        fetchWebPage(currentURL)
    else
        newTab()
    end

    if #buttons > 0 and selectedButton > #buttons then
        selectedButton = #buttons
    end
end

render()

while true do
    local event, key = os.pullEvent("key")

    if key == keys.up then
        if #buttons > 0 then
            selectedButton = selectedButton - 1
            if selectedButton < 1 then selectedButton = #buttons end
            render()
        end
    elseif key == keys.down then
        if #buttons > 0 then
            selectedButton = selectedButton + 1
            if selectedButton > #buttons then selectedButton = 1 end
            render()
        end
    elseif key == keys.enter then
        local button = buttons[selectedButton]
        if button and button.action then
            button.action()
            render()
        end
    elseif key == keys.l then
        -- Schnelltaste 'L' zum direkten Eintippen einer URL
        clear()
        drawHeader()
        term.setCursorPos(3, 6)
        term.setTextColor(colors.white)
        write("Ganze URL eingeben: ")
        local customUrl = read()
        if customUrl ~= "" then
            if not customUrl:match("^https?://") then
                customUrl = "https://" .. customUrl
            end
            navigate(customUrl)
            render()
        end
    elseif key == keys.q then
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(1, 1)
        break
    end
end
