--[[
    FAKE WINDOWS 11 CRASH LOOP
    Für CC:Tweaked / ComputerCraft

    Ablauf:
    BSOD -> 0% bis 100% -> Bootscreen -> BSOD -> ...
]]

math.randomseed(os.epoch("utc"))

local function centerText(y, text)
    local w, h = term.getSize()
    local x = math.floor((w - #text) / 2) + 1

    if x < 1 then
        x = 1
    end

    term.setCursorPos(x, y)
    term.write(text)
end

local function clear()
    term.setCursorPos(1, 1)
    term.clear()
end

--------------------------------------------------
-- WINDOWS BSOD
--------------------------------------------------

local function blueScreen()
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    clear()

    local w, h = term.getSize()

    -- trauriges Gesicht
    term.setCursorPos(2, 2)
    term.write(":(")

    -- Haupttext
    term.setCursorPos(2, 4)
    term.write("Your PC ran into a problem and needs to restart.")

    term.setCursorPos(2, 5)
    term.write("We're just collecting some error info.")

    -- Fortschritt
    local progress = 0

    -- Zufällige Gesamtdauer:
    -- 120 bis 180 Sekunden
    local totalTime = math.random(120, 180)

    local startTime = os.epoch("utc") / 1000

    -- Einige Fake-Fehlerdaten
    local stopCodes = {
        "CRITICAL_PROCESS_DIED",
        "SYSTEM_SERVICE_EXCEPTION",
        "IRQL_NOT_LESS_OR_EQUAL",
        "PAGE_FAULT_IN_NONPAGED_AREA",
        "KERNEL_SECURITY_CHECK_FAILURE",
        "MEMORY_MANAGEMENT",
        "SYSTEM_THREAD_EXCEPTION_NOT_HANDLED"
    }

    local stopCode = stopCodes[math.random(#stopCodes)]

    -- Infos unten
    local function drawStatic()
        local _, height = term.getSize()

        term.setCursorPos(2, math.min(9, height - 8))
        term.write("For more information about this issue and possible fixes,")

        term.setCursorPos(2, math.min(10, height - 7))
        term.write("visit https://windows.com/stopcode")

        term.setCursorPos(2, math.min(12, height - 5))
        term.write("If you call a support person, give them this info:")

        term.setCursorPos(2, math.min(14, height - 3))
        term.write("Stop code: " .. stopCode)

        term.setCursorPos(2, math.min(16, height - 1))
        term.write("Collecting error info...")
    end

    drawStatic()

    --------------------------------------------------
    -- PROGRESS
    --------------------------------------------------

    while progress < 100 do

        -- Zufälliges normales Intervall
        local delay = math.random(1, 15)

        sleep(delay)

        -- Aktuelle vergangene Zeit
        local elapsed = (os.epoch("utc") / 1000) - startTime

        -- Wenn wir zu langsam sind:
        -- Progress etwas schneller erhöhen.
        local expectedProgress = math.floor((elapsed / totalTime) * 100)

        if expectedProgress > progress then
            progress = expectedProgress
        else
            progress = progress + 1
        end

        if progress > 100 then
            progress = 100
        end

        -- Fortschritt anzeigen
        local _, height = term.getSize()

        local progressY = math.min(7, height - 9)

        term.setCursorPos(2, progressY)

        -- Alte Zeile löschen
        term.clearLine()

        term.write(tostring(progress) .. "% complete")

        -- Kleine wechselnde Statusmeldung
        local statuses = {
            "Collecting error information...",
            "Collecting memory dump...",
            "Analyzing system files...",
            "Checking system integrity...",
            "Preparing diagnostic information...",
            "Writing crash information...",
            "Contacting Windows diagnostic service..."
        }

        local status = statuses[math.random(#statuses)]

        local statusY = math.min(16, height - 1)

        term.setCursorPos(2, statusY)
        term.clearLine()
        term.write(status)
    end

    --------------------------------------------------
    -- 100%
    --------------------------------------------------

    term.setCursorPos(2, 7)
    term.clearLine()
    term.write("100% complete")

    term.setCursorPos(2, 16)
    term.clearLine()
    term.write("Crash information collected.")

    sleep(2)
end


--------------------------------------------------
-- FAKE WINDOWS BOOT SCREEN
--------------------------------------------------

local function bootScreen()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    clear()

    local w, h = term.getSize()

    --------------------------------------------------
    -- Windows Logo
    --------------------------------------------------

    local logo = {
        "███  ███",
        "███  ███",
        "███  ███",
        "███  ███"
    }

    local startY = math.floor(h / 2) - 4

    for i, line in ipairs(logo) do
        local x = math.floor((w - #line) / 2) + 1

        if x < 1 then
            x = 1
        end

        term.setCursorPos(x, startY + i)
        term.write(line)
    end

    --------------------------------------------------
    -- Windows Text
    --------------------------------------------------

    local textY = startY + 6

    if textY <= h then
        centerText(textY, "Windows")
    end

    --------------------------------------------------
    -- Loading animation
    --------------------------------------------------

    local spinner = {
        "◐",
        "◓",
        "◑",
        "◒"
    }

    -- 4 bis 10 Sekunden Bootzeit
    local bootTime = math.random(4, 10)

    local start = os.epoch("utc") / 1000
    local index = 1

    while (os.epoch("utc") / 1000) - start < bootTime do

        local elapsed = (os.epoch("utc") / 1000) - start

        local remaining = math.max(0, bootTime - elapsed)

        local spinnerY = h - 3

        term.setCursorPos(1, spinnerY)
        term.clearLine()

        centerText(
            spinnerY,
            spinner[index] .. "  Starting Windows..."
        )

        index = index + 1

        if index > #spinner then
            index = 1
        end

        sleep(0.25)
    end

    --------------------------------------------------
    -- Fake loading transition
    --------------------------------------------------

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    clear()

    centerText(math.floor(h / 2), "Welcome")

    sleep(1)

    --------------------------------------------------
    -- UND JETZT WIEDER CRASH
    --------------------------------------------------

    blueScreen()
end


--------------------------------------------------
-- START
--------------------------------------------------

while true do
    blueScreen()
    bootScreen()
end
