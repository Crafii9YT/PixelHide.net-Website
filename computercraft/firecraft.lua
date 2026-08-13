--[[
    FIRECRAFT
    Offline fictional web browser for CC:Tweaked

    No real Internet.
    No HTTP requests.
    Everything is built into this program.
]]

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
-- BROWSER STATE
--------------------------------------------------

local currentPage = "firecraft.org"

local history = {}
local historyIndex = 0

local buttons = {}
local selectedButton = 1

--------------------------------------------------
-- THEME
--------------------------------------------------

local function getTheme()
    return themes[settings.theme]
end

--------------------------------------------------
-- SCREEN
--------------------------------------------------

local function clear()
    term.setBackgroundColor(getTheme().bg)
    term.setTextColor(getTheme().fg)
    term.clear()
    term.setCursorPos(1, 1)
end

local function fillLine(y, color)
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
    term.setTextColor(color or getTheme().fg)
    write(text)
end

--------------------------------------------------
-- HEADER
--------------------------------------------------

local function drawHeader()
    fillLine(1, getTheme().header)

    term.setTextColor(colors.white)

    term.setCursorPos(2, 1)
    write("FIRECRAFT")

    local status = "OFFLINE"

    if W > #status + 4 then
        term.setCursorPos(W - #status - 1, 1)
        write(status)
    end

    term.setBackgroundColor(getTheme().bg)
end

--------------------------------------------------
-- ADDRESS BAR
--------------------------------------------------

local function drawAddress()
    local text = "http://" .. currentPage
    local width = W - 4

    if #text > width then
        text = text:sub(1, width)
    end

    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)

    term.setCursorPos(2, 3)
    write("[ " .. text)

    local used = #text + 4

    if used < W - 1 then
        write(string.rep(" ", W - 1 - used))
    end

    write("]")

    term.setBackgroundColor(getTheme().bg)
end

--------------------------------------------------
-- BUTTON SYSTEM
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
    local prefix

    if selected then
        prefix = "> "
    else
        prefix = "  "
    end

    local content = prefix .. "[ " .. text .. " ]"

    if #content > W - 4 then
        content = content:sub(1, W - 4)
    end

    term.setCursorPos(3, y)

    if selected then
        term.setBackgroundColor(getTheme().selected)
        term.setTextColor(colors.black)
    else
        term.setBackgroundColor(getTheme().button)
        term.setTextColor(colors.white)
    end

    local empty = W - 5

    if #content < empty then
        write(content)
        write(string.rep(" ", empty - #content))
    else
        write(content)
    end

    term.setBackgroundColor(getTheme().bg)
end

local function drawButtons(startY)
    local y = startY

    for i, b in ipairs(buttons) do
        drawButton(y, b.text, i == selectedButton)
        y = y + 2
    end
end

--------------------------------------------------
-- FOOTER
--------------------------------------------------

local function drawFooter()
    if H < 2 then
        return
    end

    fillLine(H, colors.gray)

    term.setTextColor(colors.white)

    term.setCursorPos(2, H)
    write("UP/DOWN: Select")

    local text = "ENTER: Open"

    if W > #text + 20 then
        term.setCursorPos(W - #text - 1, H)
        write(text)
    end
end

--------------------------------------------------
-- NAVIGATION
--------------------------------------------------

local function navigate(page)
    if page == currentPage then
        return
    end

    if historyIndex < #history then
        for i = #history, historyIndex + 1, -1 do
            table.remove(history, i)
        end
    end

    table.insert(history, currentPage)

    historyIndex = #history

    currentPage = page

    -- New page = first button selected
    selectedButton = 1
end

local function goBack()
    if historyIndex > 0 then
        currentPage = history[historyIndex]
        historyIndex = historyIndex - 1

        selectedButton = 1
    end
end

--------------------------------------------------
-- HOME
--------------------------------------------------

local function pageHome()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "FIRECRAFT WEB", getTheme().accent)

    center(8, "Welcome to the fictional Internet.")
    center(9, "Everything here is completely offline.")

    addButton("Search the FireCraft Web", function()
        navigate("search.firecraft.org")
    end)

    addButton("FireCraft Settings", function()
        navigate("settings.firecraft.org")
    end)

    addButton("FireCraft Documentation", function()
        navigate("docs.firecraft.org")
    end)

    addButton("About FireCraft", function()
        navigate("about.firecraft.org")
    end)

    drawButtons(12)
    drawFooter()
end

--------------------------------------------------
-- SEARCH
--------------------------------------------------

local function pageSearch()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "FIRECRAFT SEARCH", getTheme().accent)

    center(8, "Search the fictional FireCraft Web.")
    center(9, "There is no real Internet connection.")

    addButton("Enter Search", function()

        clear()

        drawHeader()

        term.setCursorPos(3, 6)
        term.setTextColor(colors.white)

        write("Search query: ")

        local query = read()

        clear()
        drawHeader()
        drawAddress()

        center(6, "SEARCH RESULTS", getTheme().accent)

        term.setCursorPos(3, 8)
        term.setTextColor(colors.white)

        write("Results for: " .. query)

        term.setCursorPos(3, 10)
        write("--------------------------------")

        term.setCursorPos(3, 12)
        term.setTextColor(getTheme().accent)

        write("[ FireCraft Web ]")

        term.setCursorPos(3, 14)
        term.setTextColor(colors.white)

        write("This is a fictional search result.")

        term.setCursorPos(3, 15)
        write("No real websites are accessed.")

        term.setCursorPos(3, 17)
        write("Press any key to return.")

        os.pullEvent("key")

        pageSearch()
    end)

    addButton("FireCraft Home", function()
        navigate("firecraft.org")
    end)

    drawButtons(12)
    drawFooter()
end

--------------------------------------------------
-- DOCUMENTATION
--------------------------------------------------

local function pageDocs()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "FIRECRAFT DOCUMENTATION", getTheme().accent)

    term.setTextColor(colors.white)

    term.setCursorPos(3, 8)
    write("FireCraft is an offline browser")

    term.setCursorPos(3, 9)
    write("created for ComputerCraft.")

    term.setCursorPos(3, 11)
    write("Available domains:")

    term.setTextColor(getTheme().accent)

    term.setCursorPos(5, 13)
    write("firecraft.org")

    term.setCursorPos(5, 14)
    write("search.firecraft.org")

    term.setCursorPos(5, 15)
    write("docs.firecraft.org")

    term.setCursorPos(5, 16)
    write("settings.firecraft.org")

    term.setCursorPos(5, 17)
    write("about.firecraft.org")

    addButton("FireCraft Home", function()
        navigate("firecraft.org")
    end)

    drawButtons(20)
    drawFooter()
end

--------------------------------------------------
-- ABOUT
--------------------------------------------------

local function pageAbout()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "ABOUT FIRECRAFT", getTheme().accent)

    center(8, "FireCraft Browser")
    center(10, "Version 1.0")
    center(12, "Made for ComputerCraft")
    center(14, "No real websites")
    center(15, "No real Internet")
    center(17, "Just a fictional offline web")

    addButton("FireCraft Home", function()
        navigate("firecraft.org")
    end)

    drawButtons(20)
    drawFooter()
end

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local function pageSettings()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "FIRECRAFT SETTINGS", getTheme().accent)

    addButton("Theme: " .. getTheme().name, function()

        settings.theme = settings.theme + 1

        if settings.theme > #themes then
            settings.theme = 1
        end

        selectedButton = 1

        pageSettings()
    end)

    addButton(
        "Sounds: " .. (settings.sounds and "ON" or "OFF"),
        function()

            settings.sounds = not settings.sounds

            pageSettings()
        end
    )

    addButton(
        "Animations: " .. (settings.animations and "ON" or "OFF"),
        function()

            settings.animations = not settings.animations

            pageSettings()
        end
    )

    addButton("Back to FireCraft", function()
        navigate("firecraft.org")
    end)

    drawButtons(10)
    drawFooter()
end

--------------------------------------------------
-- 404
--------------------------------------------------

local function page404()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(7, "404", colors.red)

    center(9, "DOMAIN NOT FOUND")

    center(11, "This domain does not exist")
    center(12, "in the FireCraft Web.")

    addButton("FireCraft Home", function()
        navigate("firecraft.org")
    end)

    drawButtons(15)
    drawFooter()
end

--------------------------------------------------
-- RENDER
--------------------------------------------------

local function render()
    if currentPage == "firecraft.org" then
        pageHome()

    elseif currentPage == "search.firecraft.org" then
        pageSearch()

    elseif currentPage == "docs.firecraft.org" then
        pageDocs()

    elseif currentPage == "settings.firecraft.org" then
        pageSettings()

    elseif currentPage == "about.firecraft.org" then
        pageAbout()

    else
        page404()
    end

    -- Safety check.
    -- This makes sure the selected button always exists.
    if #buttons == 0 then
        selectedButton = 1
    elseif selectedButton < 1 then
        selectedButton = 1
    elseif selectedButton > #buttons then
        selectedButton = #buttons
    end
end

--------------------------------------------------
-- START
--------------------------------------------------

render()

while true do

    local event, key = os.pullEvent("key")

    if event == "key" then

        --------------------------------------------------
        -- UP
        --------------------------------------------------

        if key == keys.up then

            if #buttons > 0 then

                selectedButton = selectedButton - 1

                if selectedButton < 1 then
                    selectedButton = #buttons
                end

                render()
            end

        --------------------------------------------------
        -- DOWN
        --------------------------------------------------

        elseif key == keys.down then

            if #buttons > 0 then

                selectedButton = selectedButton + 1

                if selectedButton > #buttons then
                    selectedButton = 1
                end

                render()
            end

        --------------------------------------------------
        -- ENTER
        --------------------------------------------------

        elseif key == keys.enter then

            local selected = buttons[selectedButton]

            if selected and selected.action then
                selected.action()
            end

            render()

        --------------------------------------------------
        -- BACK
        --------------------------------------------------

        elseif key == keys.b then

            goBack()
            render()

        --------------------------------------------------
        -- QUIT
        --------------------------------------------------

        elseif key == keys.q then

            clear()

            center(
                math.floor(H / 2),
                "FIRECRAFT CLOSED"
            )

            sleep(1)

            term.clear()
            term.setCursorPos(1, 1)

            break
        end
    end
end
