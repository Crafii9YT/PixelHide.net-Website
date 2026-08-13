--[[
    FireCraft Browser
    Offline fake web browser for CC:Tweaked
    No real internet access.
]]

local w, h = term.getSize()

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
    }
}

local settings = {
    theme = 1,
    sounds = true,
    animations = true
}

local history = {}
local historyPos = 0

local currentPage = "firecraft.org"
local currentButtons = {}
local selectedButton = 1

local function theme()
    return themes[settings.theme]
end

local function clear()
    term.setBackgroundColor(theme().bg)
    term.setTextColor(theme().fg)
    term.clear()
    term.setCursorPos(1, 1)
end

local function center(y, text, color)
    term.setCursorPos(math.max(1, math.floor((w - #text) / 2) + 1), y)
    if color then
        term.setTextColor(color)
    end
    write(text)
end

local function line(y, color)
    term.setBackgroundColor(color or theme().header)
    term.setCursorPos(1, y)
    write(string.rep(" ", w))
end

local function header()
    term.setBackgroundColor(theme().header)
    term.setTextColor(colors.white)

    term.setCursorPos(1, 1)
    write(string.rep(" ", w))

    term.setCursorPos(2, 1)
    write("🔥 FIRECRAFT")

    term.setCursorPos(math.max(1, w - 13), 1)
    write("OFFLINE WEB")

    term.setBackgroundColor(theme().bg)
end

local function addressBar()
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)

    term.setCursorPos(2, 3)
    write(string.rep(" ", w - 2))

    term.setCursorPos(3, 3)
    write("🌐 " .. currentPage)

    term.setBackgroundColor(theme().bg)
end

local function button(y, text, selected)
    local color = selected and theme().selected or theme().button

    term.setBackgroundColor(color)
    term.setTextColor(selected and colors.black or colors.white)

    term.setCursorPos(3, y)

    local display = "[ " .. text .. " ]"

    if #display > w - 4 then
        display = display:sub(1, w - 4)
    end

    write(display)
    term.setBackgroundColor(theme().bg)
end

local function addButton(text, action)
    table.insert(currentButtons, {
        text = text,
        action = action
    })
end

local function resetButtons()
    currentButtons = {}
    selectedButton = 1
end

local function navigate(domain)
    if domain ~= currentPage then
        if historyPos < #history then
            for i = #history, historyPos + 1, -1 do
                table.remove(history, i)
            end
        end

        table.insert(history, currentPage)
        historyPos = #history
    end

    currentPage = domain
end

local function back()
    if #history > 0 and historyPos > 0 then
        currentPage = history[historyPos]
        historyPos = historyPos - 1
    end
end

local function firecraftHome()
    clear()
    header()
    addressBar()

    term.setTextColor(theme().accent)
    center(6, "WELCOME TO FIRECRAFT")

    term.setTextColor(colors.white)
    center(8, "The completely fake internet.")

    center(9, "100% offline. 0% real websites.")

    addButton("Search the FireCraft Web", function()
        navigate("search.firecraft.org")
    end)

    addButton("FireCraft Settings", function()
        navigate("settings.firecraft.org")
    end)

    addButton("FireCraft Docs", function()
        navigate("docs.firecraft.org")
    end)

    addButton("About FireCraft", function()
        navigate("about.firecraft.org")
    end)

    local y = 12

    for i, b in ipairs(currentButtons) do
        button(y, b.text, i == selectedButton)
        y = y + 2
    end

    term.setTextColor(colors.lightGray)
    center(h - 2, "↑ ↓ auswählen   ENTER öffnen   B zurück")
end

local function searchPage()
    clear()
    header()
    addressBar()

    term.setTextColor(theme().accent)
    center(6, "FIRECRAFT SEARCH")

    term.setTextColor(colors.white)
    center(8, "Search the fictional FireCraft Web")

    addButton("Search for something", function()
        term.clear()
        term.setCursorPos(3, 7)
        term.setTextColor(colors.white)

        write("Search: ")
        local query = read()

        navigate("search.firecraft.org")
        searchPage()

        term.setCursorPos(3, 12)
        term.setTextColor(theme().accent)
        write("Results for: " .. query)

        term.setCursorPos(3, 14)
        term.setTextColor(colors.white)
        write("No real results found.")

        term.setCursorPos(3, 15)
        write("This is the FireCraft offline web.")
    end)

    addButton("FireCraft Home", function()
        navigate("firecraft.org")
    end)

    local y = 11

    for i, b in ipairs(currentButtons) do
        button(y, b.text, i == selectedButton)
        y = y + 2
    end

    term.setTextColor(colors.lightGray)
    center(h - 2, "↑ ↓ auswählen   ENTER öffnen   B zurück")
end

local function docsPage()
    clear()
    header()
    addressBar()

    term.setTextColor(theme().accent)
    center(6, "FIRECRAFT DOCUMENTATION")

    term.setTextColor(colors.white)

    term.setCursorPos(3, 8)
    write("Welcome to the FireCraft documentation.")

    term.setCursorPos(3, 10)
    write("FireCraft is a fictional offline browser")

    term.setCursorPos(3, 11)
    write("built entirely inside ComputerCraft.")

    term.setCursorPos(3, 13)
    write("Available domains:")

    term.setCursorPos(5, 15)
    write("firecraft.org")

    term.setCursorPos(5, 16)
    write("search.firecraft.org")

    term.setCursorPos(5, 17)
    write("docs.firecraft.org")

    term.setCursorPos(5, 18)
    write("settings.firecraft.org")

    term.setCursorPos(5, 19)
    write("about.firecraft.org")

    addButton("FireCraft Home", function()
        navigate("firecraft.org")
    end)

    button(22, currentButtons[1].text, true)

    term.setTextColor(colors.lightGray)
    center(h - 2, "ENTER öffnen   B zurück")
end

local function aboutPage()
    clear()
    header()
    addressBar()

    term.setTextColor(theme().accent)
    center(6, "ABOUT FIRECRAFT")

    term.setTextColor(colors.white)

    center(8, "FireCraft Browser")
    center(10, "Version 1.0")
    center(12, "Made for ComputerCraft")
    center(14, "No real websites.")
    center(15, "No real internet.")
    center(17, "Just a tiny fictional web.")

    addButton("FireCraft Home", function()
        navigate("firecraft.org")
    end)

    button(20, currentButtons[1].text, true)

    term.setTextColor(colors.lightGray)
    center(h - 2, "ENTER öffnen   B zurück")
end

local function settingsPage()
    clear()
    header()
    addressBar()

    term.setTextColor(theme().accent)
    center(6, "FIRECRAFT SETTINGS")

    addButton("Theme: " .. theme().name, function()
        settings.theme = settings.theme + 1

        if settings.theme > #themes then
            settings.theme = 1
        end

        settingsPage()
    end)

    addButton("Sounds: " .. (settings.sounds and "ON" or "OFF"), function()
        settings.sounds = not settings.sounds
        settingsPage()
    end)

    addButton("Animations: " .. (settings.animations and "ON" or "OFF"), function()
        settings.animations = not settings.animations
        settingsPage()
    end)

    addButton("Back to FireCraft", function()
        navigate("firecraft.org")
    end)

    local y = 9

    for i, b in ipairs(currentButtons) do
        button(y, b.text, i == selectedButton)
        y = y + 2
    end

    term.setTextColor(colors.lightGray)
    center(h - 2, "↑ ↓ auswählen   ENTER ändern   B zurück")
end

local function unknownPage()
    clear()
    header()
    addressBar()

    term.setTextColor(colors.red)
    center(7, "404 - DOMAIN NOT FOUND")

    term.setTextColor(colors.white)
    center(9, "This domain does not exist")

    center(10, "in the FireCraft Web.")

    addButton("FireCraft Home", function()
        navigate("firecraft.org")
    end)

    button(13, currentButtons[1].text, true)

    term.setTextColor(colors.lightGray)
    center(h - 2, "ENTER öffnen   B zurück")
end

local function render()
    resetButtons()

    if currentPage == "firecraft.org" then
        firecraftHome()

    elseif currentPage == "search.firecraft.org" then
        searchPage()

    elseif currentPage == "docs.firecraft.org" then
        docsPage()

    elseif currentPage == "settings.firecraft.org" then
        settingsPage()

    elseif currentPage == "about.firecraft.org" then
        aboutPage()

    else
        unknownPage()
    end
end

local function runButton()
    local b = currentButtons[selectedButton]

    if b and b.action then
        b.action()
    end
end

render()

while true do
    local event, key = os.pullEvent("key")

    if key == keys.up then
        if #currentButtons > 0 then
            selectedButton = selectedButton - 1

            if selectedButton < 1 then
                selectedButton = #currentButtons
            end

            render()
        end

    elseif key == keys.down then
        if #currentButtons > 0 then
            selectedButton = selectedButton + 1

            if selectedButton > #currentButtons then
                selectedButton = 1
            end

            render()
        end

    elseif key == keys.enter then
        runButton()
        render()

    elseif key == keys.b then
        back()
        render()

    elseif key == keys.q then
        clear()
        print("FireCraft closed.")
        break
    end
end
