-- FIRECRAFT BROWSER
-- CC:Tweaked
-- ASCII only

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
    },
    {
        name = "Purple",
        bg = colors.black,
        fg = colors.white,
        accent = colors.purple,
        header = colors.purple,
        button = colors.gray,
        selected = colors.purple
    },
    {
        name = "Green",
        bg = colors.black,
        fg = colors.white,
        accent = colors.lime,
        header = colors.green,
        button = colors.gray,
        selected = colors.lime
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

    if x < 1 then
        x = 1
    end

    term.setCursorPos(x, y)
    term.setTextColor(color or T().fg)
    write(text)
end

--------------------------------------------------
-- TOP BAR
--------------------------------------------------

local function drawHeader()
    line(1, T().header)

    term.setTextColor(colors.white)

    term.setCursorPos(2, 1)
    write("FIRECRAFT")

    local controls = "[-] [X]"

    if W > #controls + 15 then
        term.setCursorPos(W - #controls - 1, 1)
        write(controls)
    end

    term.setBackgroundColor(T().bg)
end

--------------------------------------------------
-- ADDRESS BAR
--------------------------------------------------

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

--------------------------------------------------
-- BUTTONS
--------------------------------------------------

local function clearButtons()
    buttons = {}
end

local function addButton(text, action)
    table.insert(buttons, {
        text = text,
        action = action
    })
end

local function drawButton(y, text, selected)
    local prefix = selected and "> " or "  "

    local content = prefix .. "[ " .. text .. " ]"

    if #content > W - 6 then
        content = content:sub(1, W - 6)
    end

    term.setCursorPos(3, y)

    if selected then
        term.setBackgroundColor(T().selected)
        term.setTextColor(colors.black)
    else
        term.setBackgroundColor(T().button)
        term.setTextColor(colors.white)
    end

    write(content)

    local remaining = W - 5 - #content

    if remaining > 0 then
        write(string.rep(" ", remaining))
    end

    term.setBackgroundColor(T().bg)
end

local function drawButtons(y)
    for i, b in ipairs(buttons) do
        drawButton(y, b.text, i == selectedButton)
        y = y + 2
    end
end

--------------------------------------------------
-- FOOTER
--------------------------------------------------

local function drawFooter()
    line(H, colors.gray)

    term.setTextColor(colors.white)

    term.setCursorPos(2, H)
    write("UP/DOWN  Select")

    local text = "ENTER  Open"

    if W > #text + 20 then
        term.setCursorPos(W - #text - 1, H)
        write(text)
    end
end

--------------------------------------------------
-- NAVIGATION
--------------------------------------------------

local function navigate(url)
    if url == currentURL then
        return
    end

    if historyIndex < #history then
        for i = #history, historyIndex + 1, -1 do
            table.remove(history, i)
        end
    end

    table.insert(history, currentURL)

    historyIndex = #history

    currentURL = url
    selectedButton = 1
end

local function back()
    if historyIndex > 0 then
        currentURL = history[historyIndex]
        historyIndex = historyIndex - 1
        selectedButton = 1
    end
end

--------------------------------------------------
-- SEARCH DATA
--------------------------------------------------

local sites = {
    {
        name = "Minecraft",
        url = "https://www.minecraft.net",
        description = "Official Minecraft website."
    },

    {
        name = "YouTube",
        url = "https://www.youtube.com",
        description = "Videos, channels and live streams."
    },

    {
        name = "Wikipedia",
        url = "https://www.wikipedia.org",
        description = "The free encyclopedia."
    },

    {
        name = "GitHub",
        url = "https://github.com",
        description = "Development and code hosting."
    },

    {
        name = "Roblox",
        url = "https://www.roblox.com",
        description = "Online games and experiences."
    },

    {
        name = "Mozilla Firefox",
        url = "https://www.mozilla.org/firefox",
        description = "Firefox web browser."
    },

    {
        name = "Google",
        url = "https://www.google.com",
        description = "Search and online services."
    },

    {
        name = "Microsoft",
        url = "https://www.microsoft.com",
        description = "Technology and software."
    }
}

--------------------------------------------------
-- URL ENCODING
--------------------------------------------------

local function encode(text)
    text = text:gsub(" ", "%%20")
    text = text:gsub("?", "%%3F")
    text = text:gsub("&", "%%26")
    text = text:gsub("=", "%%3D")
    return text
end

local function decode(text)
    text = text:gsub("%%20", " ")
    text = text:gsub("%%3F", "?")
    text = text:gsub("%%26", "&")
    text = text:gsub("%%3D", "=")
    return text
end

local function getQuery()
    local query = currentURL:match("^http://firecraft%.org/search%?=(.*)$")

    if query then
        return decode(query)
    end

    return ""
end

--------------------------------------------------
-- NEW TAB
--------------------------------------------------

local function newTab()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "FIRECRAFT", T().accent)

    center(8, "What are you looking for?")

    addButton("Search", function()

        clear()
        drawHeader()

        term.setCursorPos(3, 6)
        term.setTextColor(colors.white)

        write("Search: ")

        local query = read()

        if query ~= "" then
            navigate(
                "http://firecraft.org/search?="
                .. encode(query)
            )
        end
    end)

    addButton("Settings", function()
        navigate("firecraft://settings")
    end)

    addButton("About FireCraft", function()
        navigate("firecraft://about")
    end)

    drawButtons(11)
    drawFooter()
end

--------------------------------------------------
-- SEARCH RESULTS
--------------------------------------------------

local function searchPage()
    clearButtons()

    local query = getQuery()

    clear()
    drawHeader()
    drawAddress()

    center(5, "SEARCH", T().accent)

    term.setCursorPos(3, 7)
    term.setTextColor(colors.white)

    write("Results for: " .. query)

    local results = {}

    local q = query:lower()

    for _, site in ipairs(sites) do

        if q == ""
            or site.name:lower():find(q, 1, true)
            or site.url:lower():find(q, 1, true)
            or site.description:lower():find(q, 1, true) then

            table.insert(results, site)
        end
    end

    local y = 9

    for i, site in ipairs(results) do

        if y >= H - 7 then
            break
        end

        term.setCursorPos(3, y)
        term.setTextColor(T().accent)

        write(site.name)

        term.setCursorPos(3, y + 1)
        term.setTextColor(colors.lightGray)

        write(site.url)

        term.setCursorPos(3, y + 2)
        term.setTextColor(colors.white)

        write(site.description)

        addButton("Open " .. site.name, function()
            navigate("firecraft://site/" .. site.name)
        end)

        y = y + 4
    end

    if #results == 0 then
        term.setCursorPos(3, 10)
        term.setTextColor(colors.lightGray)
        write("No results found.")
    end

    addButton("New Search", function()

        clear()

        drawHeader()

        term.setCursorPos(3, 6)
        term.setTextColor(colors.white)

        write("Search: ")

        local newQuery = read()

        if newQuery ~= "" then
            navigate(
                "http://firecraft.org/search?="
                .. encode(newQuery)
            )
        end
    end)

    addButton("New Tab", function()
        navigate("firecraft://newtab")
    end)

    local buttonY = H - (#buttons * 2) - 1

    if buttonY < 9 then
        buttonY = 9
    end

    drawButtons(buttonY)
    drawFooter()
end

--------------------------------------------------
-- SITE PAGE
--------------------------------------------------

local function sitePage(name)
    clearButtons()

    local selected

    for _, site in ipairs(sites) do
        if site.name == name then
            selected = site
            break
        end
    end

    if not selected then
        navigate("firecraft://newtab")
        return
    end

    clear()
    drawHeader()

    currentURL = selected.url

    drawAddress()

    center(6, selected.name, T().accent)

    center(8, selected.description)

    term.setCursorPos(3, 11)
    term.setTextColor(T().accent)

    write(selected.url)

    term.setCursorPos(3, 13)
    term.setTextColor(colors.white)

    write("Welcome to " .. selected.name .. ".")

    term.setCursorPos(3, 15)
    write("This page is available in FireCraft.")

    addButton("Back", function()
        back()
    end)

    addButton("New Tab", function()
        navigate("firecraft://newtab")
    end)

    drawButtons(19)
    drawFooter()
end

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local function settingsPage()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "SETTINGS", T().accent)

    addButton("Theme: " .. T().name, function()

        settings.theme = settings.theme + 1

        if settings.theme > #themes then
            settings.theme = 1
        end

        selectedButton = 1
    end)

    addButton(
        "Sounds: " .. (settings.sounds and "ON" or "OFF"),
        function()
            settings.sounds = not settings.sounds
        end
    )

    addButton(
        "Animations: " .. (settings.animations and "ON" or "OFF"),
        function()
            settings.animations = not settings.animations
        end
    )

    addButton("New Tab", function()
        navigate("firecraft://newtab")
    end)

    drawButtons(10)
    drawFooter()
end

--------------------------------------------------
-- ABOUT
--------------------------------------------------

local function aboutPage()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "ABOUT FIRECRAFT", T().accent)

    center(8, "FireCraft Browser")
    center(10, "Version 1.0")
    center(12, "ComputerCraft Edition")

    addButton("New Tab", function()
        navigate("firecraft://newtab")
    end)

    drawButtons(16)
    drawFooter()
end

--------------------------------------------------
-- 404
--------------------------------------------------

local function notFound()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(7, "404", colors.red)
    center(9, "PAGE NOT FOUND")

    addButton("New Tab", function()
        navigate("firecraft://newtab")
    end)

    drawButtons(13)
    drawFooter()
end

--------------------------------------------------
-- RENDER
--------------------------------------------------

local function render()

    if currentURL == "firecraft://newtab" then

        newTab()

    elseif currentURL == "firecraft://settings" then

        settingsPage()

    elseif currentURL == "firecraft://about" then

        aboutPage()

    elseif currentURL:match("^http://firecraft%.org/search%?=") then

        searchPage()

    elseif currentURL:match("^firecraft://site/") then

        local name = currentURL:match("^firecraft://site/(.*)$")

        sitePage(name)

    else

        notFound()
    end

    if #buttons == 0 then
        selectedButton = 1
    elseif selectedButton < 1 then
        selectedButton = 1
    elseif selectedButton > #buttons then
        selectedButton = #buttons
    end
end

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

render()

while true do

    local event, key = os.pullEvent("key")

    if key == keys.up then

        if #buttons > 0 then

            selectedButton = selectedButton - 1

            if selectedButton < 1 then
                selectedButton = #buttons
            end

            render()
        end

    elseif key == keys.down then

        if #buttons > 0 then

            selectedButton = selectedButton + 1

            if selectedButton > #buttons then
                selectedButton = 1
            end

            render()
        end

    elseif key == keys.enter then

        local button = buttons[selectedButton]

        if button and button.action then
            button.action()
        end

        render()

    elseif key == keys.b then

        back()
        render()

    elseif key == keys.q then

        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(1, 1)

        break
    end
end
