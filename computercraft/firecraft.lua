--==================================================
-- FIRECRAFT BROWSER
-- Single-file CC:Tweaked browser
--==================================================

local W, H = term.getSize()

--------------------------------------------------
-- STATE
--------------------------------------------------

local currentURL = "firecraft://newtab"

local page = {
    url = currentURL,
    title = "New Tab",
    nodes = {}
}

local history = {}
local historyPos = 0

local controls = {}
local selected = 1

local scroll = 0

local inputValues = {}

--------------------------------------------------
-- COLORS
--------------------------------------------------

local COLORS = {
    background = colors.black,
    foreground = colors.white,
    header = colors.blue,
    address = colors.gray,
    link = colors.cyan,
    selected = colors.yellow,
    muted = colors.lightGray,
    error = colors.red
}

--------------------------------------------------
-- SCREEN
--------------------------------------------------

local function clear()
    term.setBackgroundColor(COLORS.background)
    term.setTextColor(COLORS.foreground)

    term.clear()
    term.setCursorPos(1, 1)
end

--------------------------------------------------
-- URL ENCODE
--------------------------------------------------

local function urlEncode(text)
    text = tostring(text)

    text = text:gsub("%%", "%%25")
    text = text:gsub(" ", "%%20")
    text = text:gsub("\n", "%%0A")
    text = text:gsub("&", "%%26")
    text = text:gsub("?", "%%3F")
    text = text:gsub("=", "%%3D")
    text = text:gsub("#", "%%23")

    return text
end

--------------------------------------------------
-- URL DECODE
--------------------------------------------------

local function urlDecode(text)
    text = text:gsub("%%20", " ")
    text = text:gsub("%%0A", "\n")
    text = text:gsub("%%26", "&")
    text = text:gsub("%%3F", "?")
    text = text:gsub("%%3D", "=")
    text = text:gsub("%%23", "#")

    return text
end

--------------------------------------------------
-- HTML ENTITIES
--------------------------------------------------

local function decodeHTML(text)

    text = text:gsub("&nbsp;", " ")
    text = text:gsub("&amp;", "&")
    text = text:gsub("&lt;", "<")
    text = text:gsub("&gt;", ">")
    text = text:gsub("&quot;", '"')
    text = text:gsub("&#39;", "'")

    return text
end

--------------------------------------------------
-- HTML ATTRIBUTES
--------------------------------------------------

local function parseAttributes(raw)

    local attrs = {}

    for key, quote, value in raw:gmatch(
        "([%w_:%-]+)%s*=%s*([\"'])(.-)%2"
    ) do

        attrs[key:lower()] = value
    end

    return attrs
end

--------------------------------------------------
-- HTML PARSER
--------------------------------------------------

local function parseHTML(html, url)

    local nodes = {}

    --------------------------------------------------
    -- Remove scripts/styles
    --------------------------------------------------

    html = html:gsub(
        "<script.-</script>",
        ""
    )

    html = html:gsub(
        "<style.-</style>",
        ""
    )

    html = html:gsub(
        "<noscript.-</noscript>",
        ""
    )

    --------------------------------------------------
    -- Remove comments
    --------------------------------------------------

    html = html:gsub(
        "<!%-%-.-%-%->",
        ""
    )

    local pos = 1

    local activeControl = nil

    while true do

        local s, e, closing, tag, raw =
            html:find(
                "<%s*(/?)%s*([%w]+)(.-)>",
                pos
            )

        if not s then

            local text =
                html:sub(pos)

            text = decodeHTML(text)

            text =
                text:gsub("%s+", " ")

            if text:match("%S") then

                text =
                    text:match("^%s*(.-)%s*$")

                if activeControl then

                    activeControl.text =
                        activeControl.text
                        .. text

                else

                    table.insert(
                        nodes,
                        {
                            type = "text",
                            text = text
                        }
                    )
                end
            end

            break
        end

        --------------------------------------------------
        -- Text before tag
        --------------------------------------------------

        local text =
            html:sub(pos, s - 1)

        text = decodeHTML(text)
        text = text:gsub("%s+", " ")

        if text:match("%S") then

            text =
                text:match("^%s*(.-)%s*$")

            if activeControl then

                activeControl.text =
                    activeControl.text
                    .. text

            else

                table.insert(
                    nodes,
                    {
                        type = "text",
                        text = text
                    }
                )
            end
        end

        --------------------------------------------------
        -- TAG
        --------------------------------------------------

        local tagName =
            tag:lower()

        local isClosing =
            closing == "/"

        if not isClosing then

            local attrs =
                parseAttributes(raw)

            --------------------------------------------------
            -- HEADINGS
            --------------------------------------------------

            if tagName == "h1"
                or tagName == "h2"
                or tagName == "h3"
                or tagName == "h4"
                or tagName == "h5"
                or tagName == "h6" then

                table.insert(
                    nodes,
                    {
                        type = "heading",
                        level =
                            tonumber(
                                tagName:sub(2)
                            ),
                        text = ""
                    }
                )

                activeControl =
                    nodes[#nodes]

            --------------------------------------------------
            -- PARAGRAPHS
            --------------------------------------------------

            elseif tagName == "p"
                or tagName == "div"
                or tagName == "section"
                or tagName == "article"
                or tagName == "main"
                or tagName == "header"
                or tagName == "footer" then

                table.insert(
                    nodes,
                    {
                        type = "break"
                    }
                )

                activeControl = nil

            --------------------------------------------------
            -- LINE BREAK
            --------------------------------------------------

            elseif tagName == "br" then

                table.insert(
                    nodes,
                    {
                        type = "break"
                    }
                )

                activeControl = nil

            --------------------------------------------------
            -- HORIZONTAL LINE
            --------------------------------------------------

            elseif tagName == "hr" then

                table.insert(
                    nodes,
                    {
                        type = "line"
                    }
                )

                activeControl = nil

            --------------------------------------------------
            -- LINKS
            --------------------------------------------------

            elseif tagName == "a" then

                local node = {
                    type = "link",
                    href = attrs.href or "#",
                    text = ""
                }

                table.insert(
                    nodes,
                    node
                )

                activeControl = node

            --------------------------------------------------
            -- BUTTON
            --------------------------------------------------

            elseif tagName == "button" then

                local node = {
                    type = "button",
                    text = "",
                    href =
                        attrs.formaction
                        or attrs.href
                }

                table.insert(
                    nodes,
                    node
                )

                activeControl = node

            --------------------------------------------------
            -- INPUT
            --------------------------------------------------

            elseif tagName == "input" then

                local id =
                    attrs.id
                    or (
                        "input_"
                        .. tostring(#nodes + 1)
                    )

                table.insert(
                    nodes,
                    {
                        type = "input",

                        id = id,

                        name =
                            attrs.name
                            or id,

                        placeholder =
                            attrs.placeholder
                            or "",

                        value =
                            attrs.value
                            or "",

                        inputType =
                            attrs.type
                            or "text",

                        formAction =
                            attrs.formaction
                    }
                )

                activeControl = nil

            --------------------------------------------------
            -- TEXTAREA
            --------------------------------------------------

            elseif tagName == "textarea" then

                local id =
                    attrs.id
                    or (
                        "textarea_"
                        .. tostring(#nodes + 1)
                    )

                table.insert(
                    nodes,
                    {
                        type = "input",

                        id = id,

                        name =
                            attrs.name
                            or id,

                        placeholder =
                            attrs.placeholder
                            or "",

                        value = "",

                        inputType =
                            "textarea"
                    }
                )

                activeControl = nil

            --------------------------------------------------
            -- IMAGE
            --------------------------------------------------

            elseif tagName == "img" then

                table.insert(
                    nodes,
                    {
                        type = "image",

                        src =
                            attrs.src
                            or "",

                        alt =
                            attrs.alt
                            or "[image]"
                    }
                )

                activeControl = nil

            --------------------------------------------------
            -- LIST
            --------------------------------------------------

            elseif tagName == "li" then

                table.insert(
                    nodes,
                    {
                        type = "text",
                        text = "* "
                    }
                )

            end

        else

            --------------------------------------------------
            -- CLOSE TAG
            --------------------------------------------------

            if tagName == "a"
                or tagName == "button"
                or tagName == "h1"
                or tagName == "h2"
                or tagName == "h3"
                or tagName == "h4"
                or tagName == "h5"
                or tagName == "h6" then

                activeControl = nil
            end

            if tagName == "p"
                or tagName == "div"
                or tagName == "section"
                or tagName == "article"
                or tagName == "main" then

                table.insert(
                    nodes,
                    {
                        type = "break"
                    }
                )

                activeControl = nil
            end
        end

        pos = e + 1
    end

    return {
        url = url,
        title = url,
        nodes = nodes
    }
end

--------------------------------------------------
-- HTTP
--------------------------------------------------

local function httpGet(url)

    if not http then
        return nil, "HTTP is disabled"
    end

    if not url:match("^https?://") then
        return nil, "Unsupported URL"
    end

    local ok, response =
        pcall(
            http.get,
            url,
            {
                ["User-Agent"] =
                    "FireCraft/2.0"
            }
        )

    if not ok or not response then
        return nil, "Connection failed"
    end

    local body =
        response.readAll()

    local headers = {}

    if response.getResponseHeaders then
        headers =
            response.getResponseHeaders()
    end

    response.close()

    return {
        body = body,
        headers = headers
    }
end

--------------------------------------------------
-- NEW TAB
--------------------------------------------------

local function createNewTab()

    return {
        url = "firecraft://newtab",

        title = "New Tab",

        nodes = {

            {
                type = "heading",
                text = "FIRECRAFT"
            },

            {
                type = "text",
                text = "Search or enter a web address."
            },

            {
                type = "break"
            },

            {
                type = "input",

                id = "address",

                name = "address",

                placeholder =
                    "https://example.com"
            },

            {
                type = "button",

                text = "Go",

                action = "address"
            },

            {
                type = "break"
            },

            {
                type = "link",

                text = "Settings",

                href =
                    "firecraft://settings"
            }
        }
    }
end

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local function createSettings()

    return {
        url = "firecraft://settings",

        title = "Settings",

        nodes = {

            {
                type = "heading",

                text =
                    "FireCraft Settings"
            },

            {
                type = "break"
            },

            {
                type = "text",

                text =
                    "HTTP browsing is enabled through CC:Tweaked."
            },

            {
                type = "break"
            },

            {
                type = "link",

                text = "New Tab",

                href =
                    "firecraft://newtab"
            }
        }
    }
end

--------------------------------------------------
-- NAVIGATE
--------------------------------------------------

local function navigate(url, saveHistory)

    if not url or url == "" then
        return
    end

    --------------------------------------------------
    -- Relative links
    --------------------------------------------------

    if url:sub(1, 1) == "/" then

        local base =
            currentURL:match(
                "^(https?://[^/]+)"
            )

        if base then
            url = base .. url
        end

    elseif not url:match("^%a+://") then

        if currentURL:match("^https?://") then

            local base =
                currentURL:match(
                    "^(https?://[^/]+)"
                )

            url =
                base
                .. "/"
                .. url
        end
    end

    --------------------------------------------------
    -- History
    --------------------------------------------------

    if saveHistory ~= false
        and currentURL then

        if historyPos < #history then

            for i = #history,
                historyPos + 1,
                -1 do

                table.remove(
                    history,
                    i
                )
            end
        end

        table.insert(
            history,
            currentURL
        )

        historyPos =
            #history
    end

    currentURL = url

    selected = 1
    scroll = 0

    inputValues = {}

    --------------------------------------------------
    -- INTERNAL PAGES
    --------------------------------------------------

    if url == "firecraft://newtab" then

        page =
            createNewTab()

        return
    end

    if url == "firecraft://settings" then

        page =
            createSettings()

        return
    end

    --------------------------------------------------
    -- INTERNET
    --------------------------------------------------

    local result, err =
        httpGet(url)

    if not result then

        page = {

            url = url,

            title = "Error",

            nodes = {

                {
                    type = "heading",

                    text =
                        "Unable to load page"
                },

                {
                    type = "text",

                    text =
                        url
                },

                {
                    type = "break"
                },

                {
                    type = "text",

                    text =
                        err
                        or
                        "Connection failed."
                },

                {
                    type = "break"
                },

                {
                    type = "link",

                    text =
                        "New Tab",

                    href =
                        "firecraft://newtab"
                }
            }
        }

        return
    end

    --------------------------------------------------
    -- PARSE
    --------------------------------------------------

    page =
        parseHTML(
            result.body,
            url
        )
end

--------------------------------------------------
-- WRAP
--------------------------------------------------

local function wrap(text, width)

    local lines = {}

    if width < 1 then
        return lines
    end

    while #text > width do

        local part =
            text:sub(1, width)

        local cut =
            part:match(
                "^.*()%s"
            )

        if not cut then
            cut = width
        end

        table.insert(
            lines,
            text:sub(
                1,
                cut
            ):gsub(
                "%s+$",
                ""
            )
        )

        text =
            text:sub(
                cut + 1
            ):gsub(
                "^%s+",
                ""
            )
    end

    if #text > 0 then
        table.insert(
            lines,
            text
        )
    end

    return lines
end

--------------------------------------------------
-- RENDER
--------------------------------------------------

local function render()

    clear()

    --------------------------------------------------
    -- HEADER
    --------------------------------------------------

    term.setBackgroundColor(
        COLORS.header
    )

    term.setTextColor(
        colors.white
    )

    term.setCursorPos(1, 1)

    write(" FIRECRAFT")

    if W >= 28 then

        term.setCursorPos(
            W - 19,
            1
        )

        write(
            "[B] Back  [Q] Quit"
        )
    end

    --------------------------------------------------
    -- ADDRESS
    --------------------------------------------------

    term.setBackgroundColor(
        COLORS.address
    )

    term.setCursorPos(
        1,
        2
    )

    write(
        string.rep(
            " ",
            W
        )
    )

    term.setCursorPos(
        2,
        2
    )

    local address =
        currentURL

    if #address > W - 3 then

        address =
            address:sub(
                1,
                W - 3
            )
    end

    write(address)

    term.setBackgroundColor(
        COLORS.background
    )

    --------------------------------------------------
    -- CONTENT
    --------------------------------------------------

    controls = {}

    local y = 4

    local contentWidth =
        math.max(
            10,
            W - 4
        )

    local function screenY()
        return y - scroll
    end

    local function addControl(c)

        c.id =
            #controls + 1

        table.insert(
            controls,
            c
        )

        return c.id
    end

    for _, node in ipairs(page.nodes) do

        --------------------------------------------------
        -- BREAK
        --------------------------------------------------

        if node.type == "break" then

            y = y + 1

        --------------------------------------------------
        -- LINE
        --------------------------------------------------

        elseif node.type == "line" then

            y = y + 1

            local sy =
                screenY()

            if sy >= 4
                and sy < H then

                term.setCursorPos(
                    2,
                    sy
                )

                term.setTextColor(
                    colors.gray
                )

                write(
                    string.rep(
                        "-",
                        contentWidth
                    )
                )
            end

        --------------------------------------------------
        -- TEXT
        --------------------------------------------------

        elseif node.type == "text" then

            local lines =
                wrap(
                    node.text,
                    contentWidth
                )

            for _, text in ipairs(lines) do

                y = y + 1

                local sy =
                    screenY()

                if sy >= 4
                    and sy < H then

                    term.setCursorPos(
                        2,
                        sy
                    )

                    term.setTextColor(
                        COLORS.foreground
                    )

                    write(text)
                end
            end

        --------------------------------------------------
        -- HEADING
        --------------------------------------------------

        elseif node.type == "heading" then

            local lines =
                wrap(
                    node.text,
                    contentWidth
                )

            y = y + 1

            for _, text in ipairs(lines) do

                local sy =
                    screenY()

                if sy >= 4
                    and sy < H then

                    term.setCursorPos(
                        2,
                        sy
                    )

                    term.setTextColor(
                        COLORS.selected
                    )

                    write(text)
                end

                y = y + 1
            end

        --------------------------------------------------
        -- LINK
        --------------------------------------------------

        elseif node.type == "link" then

            y = y + 1

            local id =
                addControl({
                    type = "link",
                    href = node.href
                })

            local sy =
                screenY()

            if sy >= 4
                and sy < H then

                term.setCursorPos(
                    2,
                    sy
                )

                if selected == id then

                    term.setTextColor(
                        COLORS.selected
                    )

                    write("> ")

                else

                    term.setTextColor(
                        COLORS.link
                    )

                    write("  ")
                end

                local text =
                    node.text

                if text == "" then
                    text =
                        node.href
                end

                write(
                    "[ "
                    .. text
                    .. " ]"
                )
            end

        --------------------------------------------------
        -- BUTTON
        --------------------------------------------------

        elseif node.type == "button" then

            y = y + 1

            local id =
                addControl({
                    type = "button",

                    href =
                        node.href,

                    action =
                        node.action
                })

            local sy =
                screenY()

            if sy >= 4
                and sy < H then

                term.setCursorPos(
                    2,
                    sy
                )

                if selected == id then

                    term.setTextColor(
                        COLORS.selected
                    )

                    write("> ")

                else

                    term.setTextColor(
                        COLORS.foreground
                    )

                    write("  ")
                end

                local text =
                    node.text

                if text == "" then
                    text = "Button"
                end

                write(
                    "[ "
                    .. text
                    .. " ]"
                )
            end

        --------------------------------------------------
        -- INPUT
        --------------------------------------------------

        elseif node.type == "input" then

            y = y + 2

            local id =
                addControl({
                    type = "input",

                    inputId =
                        node.id,

                    name =
                        node.name,

                    formAction =
                        node.formAction
                })

            local sy =
                screenY()

            if sy >= 4
                and sy < H then

                term.setCursorPos(
                    2,
                    sy - 1
                )

                if selected == id then

                    term.setTextColor(
                        COLORS.selected
                    )

                    write("> ")

                else

                    term.setTextColor(
                        COLORS.foreground
                    )

                    write("  ")
                end

                write(
                    node.placeholder
                    ~= ""
                    and node.placeholder
                    or node.name
                    or "Input"
                )

                term.setCursorPos(
                    2,
                    sy
                )

                term.setBackgroundColor(
                    colors.white
                )

                term.setTextColor(
                    colors.black
                )

                local value =
                    inputValues[node.id]
                    or node.value
                    or ""

                local max =
                    math.max(
                        5,
                        contentWidth - 5
                    )

                value =
                    value:sub(
                        1,
                        max
                    )

                write(
                    "[ "
                    .. value
                )

                local remaining =
                    max - #value

                if remaining > 0 then

                    write(
                        string.rep(
                            " ",
                            remaining
                        )
                    )
                end

                write(" ]")

                term.setBackgroundColor(
                    colors.black
                )
            end

        --------------------------------------------------
        -- IMAGE
        --------------------------------------------------

        elseif node.type == "image" then

            y = y + 1

            local sy =
                screenY()

            if sy >= 4
                and sy < H then

                term.setCursorPos(
                    2,
                    sy
                )

                term.setTextColor(
                    COLORS.muted
                )

                write(
                    "[ "
                    .. node.alt
                    .. " ]"
                )
            end
        end
    end

    --------------------------------------------------
    -- FOOTER
    --------------------------------------------------

    term.setBackgroundColor(
        COLORS.address
    )

    term.setTextColor(
        colors.white
    )

    term.setCursorPos(
        1,
        H
    )

    write(
        string.rep(
            " ",
            W
        )
    )

    term.setCursorPos(
        2,
        H
    )

    write(
        "UP/DOWN Select  ENTER Open"
    )

    term.setBackgroundColor(
        COLORS.background
    )

    --------------------------------------------------
    -- SELECTED CONTROL SAFETY
    --------------------------------------------------

    if #controls == 0 then

        selected = 1

    elseif selected < 1 then

        selected = 1

    elseif selected > #controls then

        selected = #controls
    end
end

--------------------------------------------------
-- ACTIVATE
--------------------------------------------------

local function activate(control)

    if not control then
        return
    end

    --------------------------------------------------
    -- LINK
    --------------------------------------------------

    if control.type == "link" then

        local url =
            control.href

        if url == "#" then
            return
        end

        --------------------------------------------------
        -- Relative URL
        --------------------------------------------------

        if url:sub(1, 1) == "/" then

            local base =
                currentURL:match(
                    "^(https?://[^/]+)"
                )

            if base then
                url =
                    base
                    .. url
            end

        elseif not url:match(
            "^%a+://"
        ) then

            if currentURL:match(
                "^https?://"
            ) then

                local base =
                    currentURL:match(
                        "^(https?://[^/]+)"
                    )

                url =
                    base
                    .. "/"
                    .. url
            end
        end

        navigate(url)

        return
    end

    --------------------------------------------------
    -- BUTTON
    --------------------------------------------------

    if control.type == "button" then

        if control.action == "address" then

            local value =
                inputValues.address
                or ""

            if value ~= "" then

                if not value:match(
                    "^%a+://"
                ) then

                    value =
                        "https://"
                        .. value
                end

                navigate(value)
            end

            return
        end

        if control.href then

            navigate(
                control.href
            )

            return
        end
    end

    --------------------------------------------------
    -- INPUT
    --------------------------------------------------

    if control.type == "input" then

        local old =
            inputValues[
                control.inputId
            ]
            or ""

        clear()

        term.setBackgroundColor(
            COLORS.header
        )

        term.setTextColor(
            colors.white
        )

        term.setCursorPos(
            1,
            1
        )

        write(
            " FIRECRAFT"
        )

        term.setBackgroundColor(
            colors.black
        )

        term.setCursorPos(
            2,
            5
        )

        term.setTextColor(
            colors.white
        )

        write(
            "Enter text:"
        )

        term.setCursorPos(
            2,
            7
        )

        term.setBackgroundColor(
            colors.white
        )

        term.setTextColor(
            colors.black
        )

        local value =
            read(
                "*",
                nil,
                nil,
                old
            )

        if control.inputType ~= "password" then
            inputValues[
                control.inputId
            ] = value
        else
            inputValues[
                control.inputId
            ] = value
        end

        term.setBackgroundColor(
            colors.black
        )

        --------------------------------------------------
        -- Address input
        --------------------------------------------------

        if control.inputId ==
            "address" then

            if value ~= "" then

                if not value:match(
                    "^%a+://"
                ) then

                    value =
                        "https://"
                        .. value
                end

                navigate(value)
            end

            return
        end

        --------------------------------------------------
        -- Form action
        --------------------------------------------------

        if control.formAction
            and control.formAction ~= "" then

            local target =
                control.formAction

            if not target:match(
                "^%a+://"
            ) then

                local base =
                    currentURL:match(
                        "^(https?://[^/]+)"
                    )

                if base then
                    target =
                        base
                        .. "/"
                        .. target
                end
            end

            local separator = "?"

            if target:find(
                "?",
                1,
                true
            ) then

                separator = "&"
            end

            target =
                target
                .. separator
                .. (
                    control.name
                    or "q"
                )
                .. "="
                .. urlEncode(value)

            navigate(target)

            return
        end
    end
end

--------------------------------------------------
-- BACK
--------------------------------------------------

local function goBack()

    if historyPos <= 0 then
        return
    end

    local previous =
        history[historyPos]

    historyPos =
        historyPos - 1

    navigate(
        previous,
        false
    )
end

--------------------------------------------------
-- START
--------------------------------------------------

navigate(
    "firecraft://newtab",
    false
)

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

while true do

    render()

    local event, key =
        os.pullEvent("key")

    --------------------------------------------------
    -- UP
    --------------------------------------------------

    if key == keys.up then

        if #controls > 0 then

            selected =
                selected - 1

            if selected < 1 then
                selected =
                    #controls
            end
        end

    --------------------------------------------------
    -- DOWN
    --------------------------------------------------

    elseif key == keys.down then

        if #controls > 0 then

            selected =
                selected + 1

            if selected > #controls then
                selected = 1
            end
        end

    --------------------------------------------------
    -- ENTER
    --------------------------------------------------

    elseif key == keys.enter then

        activate(
            controls[selected]
        )

    --------------------------------------------------
    -- BACK
    --------------------------------------------------

    elseif key == keys.b then

        goBack()

    --------------------------------------------------
    -- SCROLL
    --------------------------------------------------

    elseif key == keys.pageUp then

        scroll =
            math.max(
                0,
                scroll - (H - 5)
            )

    elseif key == keys.pageDown then

        scroll =
            scroll + (H - 5)

    elseif key == keys.left then

        scroll =
            math.max(
                0,
                scroll - 3
            )

    elseif key == keys.right then

        scroll =
            scroll + 3

    --------------------------------------------------
    -- QUIT
    --------------------------------------------------

    elseif key == keys.q then

        term.setBackgroundColor(
            colors.black
        )

        term.setTextColor(
            colors.white
        )

        term.clear()

        term.setCursorPos(
            1,
            1
        )

        break
    end
end
