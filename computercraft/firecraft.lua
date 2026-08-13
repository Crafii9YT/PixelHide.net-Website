--[[
    FIRECRAFT
    Offline fictional browser for CC:Tweaked

    Internal URLs:
      firecraft://newtab
      firecraft://settings

    Search:
      http://firecraft.org/search?=QUERY

    No real websites are loaded.
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

local currentURL = "firecraft://newtab"

local history = {}
local historyIndex = 0

local buttons = {}
local selectedButton = 1

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function getTheme()
    return themes[settings.theme]
end

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
    local text = currentURL
    local width = W - 6

    if #text > width then
        text = text:sub(1, width)
    end

    local bar = "[ " .. text .. " ]"

    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)

    term.setCursorPos(2, 3)
    write(bar)

    local remaining = W - 2 - #bar

    if remaining > 0 then
        write(string.rep(" ", remaining))
    end

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

    local available = W - 5

    if #content < available then
        write(content)
        write(string.rep(" ", available - #content))
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

local function goBack()
    if historyIndex > 0 then
        currentURL = history[historyIndex]
        historyIndex = historyIndex - 1
        selectedButton = 1
    end
end

--------------------------------------------------
-- URL ENCODING
--------------------------------------------------

local function urlEncode(text)
    text = text:gsub(" ", "%%20")
    text = text:gsub("%?", "%%3F")
    text = text:gsub("&", "%%26")
    text = text:gsub("=", "%%3D")

    return text
end

--------------------------------------------------
-- SEARCH QUERY
--------------------------------------------------

local function getSearchQuery()
    local query = currentURL:match("^http://firecraft%.org/search%?=(.*)$")

    if not query then
        return ""
    end

    query = query:gsub("%%20", " ")
    query = query:gsub("%%3F", "?")
    query = query:gsub("%%26", "&")
    query = query:gsub("%%3D", "=")

    return query
end

--------------------------------------------------
-- FAKE SEARCH DATABASE
--------------------------------------------------

local searchDatabase = {
    {
        name = "Minecraft",
        url = "https://www.minecraft.net",
        description = "Official Minecraft website."
    },

    {
        name = "YouTube",
        url = "https://www.youtube.com",
        description = "Video sharing and streaming platform."
    },

    {
        name = "Wikipedia",
        url = "https://www.wikipedia.org",
        description = "Free online encyclopedia."
    },

    {
        name = "GitHub",
        url = "https://github.com",
        description = "Code hosting and development platform."
    },

    {
        name = "Roblox",
        url = "https://www.roblox.com",
        description = "Online gaming platform."
    },

    {
        name = "Mozilla Firefox",
        url = "https://www.mozilla.org/firefox",
        description = "Official Firefox website."
    },

    {
        name = "Microsoft",
        url = "https://www.microsoft.com",
        description = "Microsoft official website."
    },

    {
        name = "Google",
        url = "https://www.google.com",
        description = "Search engine and online services."
    }
}

local function searchMatches(query)
    local results = {}

    query = query:lower()

    for _, result in ipairs(searchDatabase) do

        local name = result.name:lower()
        local description = result.description:lower()

        if query == ""
            or name:find(query, 1, true)
            or description:find(query, 1, true) then

            table.insert(results, result)
        end
    end

    return results
end

--------------------------------------------------
-- NEW TAB
--------------------------------------------------

local function pageNewTab()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "FIRECRAFT", getTheme().accent)
    center(7, "The fictional offline Internet.")

    center(9, "What would you like to do?")

    addButton("Search the FireCraft Web", function()

        clear()

        drawHeader()

        term.setCursorPos(3, 6)
        term.setTextColor(colors.white)

        write("Search: ")

        local query = read()

        if query == "" then
            navigate("firecraft://newtab")
        else
            navigate(
                "http://firecraft.org/search?="
                .. urlEncode(query)
            )
        end
    end)

    addButton("FireCraft Settings", function()
        navigate("firecraft://settings")
    end)

    addButton("About FireCraft", function()
        navigate("firecraft://about")
    end)

    drawButtons(12)
    drawFooter()
end

--------------------------------------------------
-- SEARCH PAGE
--------------------------------------------------

local function pageSearch()
    clearButtons()

    local query = getSearchQuery()
    local results = searchMatches(query)

    clear()
    drawHeader()
    drawAddress()

    center(5, "FIRECRAFT SEARCH", getTheme().accent)

    term.setCursorPos(3, 7)
    term.setTextColor(colors.white)

    write("Search results for: " .. query)

    local y = 9

    if #results == 0 then

        term.setCursorPos(3, y)
        term.setTextColor(colors.red)

        write("No results found.")

        y = y + 2

    else

        for i, result in ipairs(results) do

            if y >= H - 5 then
                break
            end

            term.setTextColor(getTheme().accent)

            term.setCursorPos(3, y)
            write(i .. ". " .. result.name)

            term.setTextColor(colors.lightGray)

            term.setCursorPos(5, y + 1)
            write(result.url)

            term.setCursorPos(5, y + 2)
            write(result.description)

            addButton(
                "Open " .. result.name,
                function()
                    -- The result is displayed as a real-looking
                    -- website address, but FireCraft does NOT
                    -- actually connect to it.
                    navigate("firecraft://external/" .. result.name)
                end
            )

            y = y + 4
        end
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
                .. urlEncode(newQuery)
            )
        else
            navigate("firecraft://newtab")
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
-- SETTINGS
--------------------------------------------------

local function pageSettings()
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "FIRECRAFT SETTINGS", getTheme().accent)

    addButton(
        "Theme: " .. getTheme().name,
        function()

            settings.theme = settings.theme + 1

            if settings.theme > #themes then
                settings.theme = 1
            end

            selectedButton = 1
        end
    )

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

    addButton("Back to New Tab", function()
        navigate("firecraft://newtab")
    end)

    drawButtons(10)
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
    center(14, "No real websites are loaded.")
    center(15, "No real Internet connection.")
    center(17, "Everything is simulated locally.")

    addButton("Back to New Tab", function()
        navigate("firecraft://newtab")
    end)

    drawButtons(20)
    drawFooter()
end

--------------------------------------------------
-- EXTERNAL WEBSITE PAGE
--------------------------------------------------

local function pageExternal(name)
    clearButtons()

    clear()
    drawHeader()
    drawAddress()

    center(6, "EXTERNAL WEBSITE", getTheme().accent)

    center(8, "You selected:")
    center(10, name)

    center(12, "This website exists on the real Internet.")

    term.setTextColor(colors.red)

    center(14, "FireCraft will NOT connect to it.")

    term.setTextColor(colors.white)

    center(16, "This browser is offline by design.")

    addButton("Back to Search", function()
        goBack()
    end)

    addButton("New Tab", function()
        navigate("firecraft://newtab")
    end)

    drawButtons(19)
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

    center(9, "PAGE NOT FOUND")

    center(11, "This address does not exist")
    center(12, "in the FireCraft Web.")

    addButton("New Tab", function()
        navigate("firecraft://newtab")
    end)

    drawButtons(15)
    drawFooter()
end

--------------------------------------------------
-- RENDER
--------------------------------------------------

local function render()

    if currentURL == "firecraft://newtab" then

        pageNewTab()

    elseif currentURL == "firecraft://settings" then

        pageSettings()

    elseif currentURL == "firecraft://about" then

        pageAbout()

    elseif currentURL:match("^http://firecraft%.org/search%?=") then

        pageSearch()

    elseif currentURL:match("^firecraft://external/") then

        local name = currentURL:match("^firecraft://external/(.*)$")

        pageExternal(name or "Unknown")

    else

        page404()
    end

    --------------------------------------------------
    -- Safety
    --------------------------------------------------

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
        -- Q
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
