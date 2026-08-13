-- FIRECRAFT BROWSER (Optimiert & Bereinigt)
-- CC:Tweaked

local W, H = term.getSize()

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local settings = {
    theme = 1,
    sounds = true,
    animations = true
}

local themes = {
    {
        name = "Fire",
        bg = colors.black,
        fg = colors.white,
        accent = colors.orange,
        header = colors.red,
        button = colors.gray,
        selected = colors.orange
    },
    {
        name = "Ocean",
        bg = colors.black,
        fg = colors.white,
        accent = colors.cyan,
        header = colors.blue,
        button = colors.gray,
        selected = colors.cyan
    }
}

--------------------------------------------------
-- STATE
--------------------------------------------------

local currentURL = "firecraft://newtab"
local history = {}
local historyIndex = 0
local buttons = {}
local selectedButton = 1

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
    if #text > W then
        text = text:sub(1, W)
    end
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
    write("FIRECRAFT BROWSER")
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
    write("UP/DOWN: Select | ENTER: Open | Q: Quit")
end

--------------------------------------------------
-- NAVIGATION
--------------------------------------------------

local function navigate(url)
    if url == currentURL then return end
    table.insert(history, currentURL)
    historyIndex = #history
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

--------------------------------------------------
-- PAGES
--------------------------------------------------

local function newTab()
    clearButtons()
    clear()
    drawHeader()
    drawAddress()

    center(6, "FIRECRAFT START", T().accent)
    center(8, "Waehle eine Option:")

    addButton("Suche starten", function()
        clear()
        drawHeader()
        term.setCursorPos(3, 6)
        term.setTextColor(colors.white)
        write("Suchbegriff: ")
        local query = read()
        if query ~= "" then
            navigate("firecraft://search/" .. query)
        end
    end)

    addButton("Roblox (Interaktiv)", function()
        navigate("firecraft://site/Roblox")
    end)

    addButton("Wikipedia (Offline-Modus)", function()
        navigate("firecraft://site/Wikipedia")
    end)

    addButton("Einstellungen", function()
        navigate("firecraft://settings")
    end)

    drawButtons(11)
    drawFooter()
end

local function sitePage(name)
    clearButton = {}
    clear()
    drawHeader()
    drawAddress()

    center(5, name:upper(), T().accent)
    
    if name == "Roblox" then
        center(7, "--- ROBLOX HUB ---")
        center(9, "Wilkommen bei Roblox in CC:Tweaked!")
        
        addButton("Spiele-Liste anzeigen", function()
            print("Lade Spiele...")
            os.sleep(1)
        end)
    elseif name == "Wikipedia" then
        center(7, "--- WIKIPEDIA ---")
        center(9, "Die freie Enzyklopaedie (Text-Modus).")
    else
        center(7, "Webseite nicht verfuegbar.")
    end

    addButton("Zurueck", function() back() end)
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

    addButton("Zurueck zum Start", function()
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
    elseif currentURL:match("^firecraft://site/(.*)") then
        local name = currentURL:match("^firecraft://site/(.*)")
        sitePage(name)
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
    elseif key == keys.q then
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(1, 1)
        break
    end
end
