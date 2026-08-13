-- FireCraft - einfacher Text-Webbrowser für CC:Tweaked

term.clear()
term.setCursorPos(1, 1)

print("================================")
print("          FireCraft")
print("================================")
print()
print("Startseite: https://example.com")
print()

while true do
    write("URL > ")
    local url = read()

    if url == "exit" or url == "quit" then
        break
    end

    if not url:match("^https?://") then
        url = "https://" .. url
    end

    term.clear()
    term.setCursorPos(1, 1)

    print("FireCraft")
    print("Lade: " .. url)
    print("--------------------------------")

    local response, err = http.get(url)

    if not response then
        print()
        print("Fehler beim Laden:")
        print(err or "Unbekannter Fehler")
    else
        local content = response.readAll()
        response.close()

        -- Ein bisschen HTML aufräumen
        content = content:gsub("<script.-</script>", "")
        content = content:gsub("<style.-</style>", "")
        content = content:gsub("<[^>]->", "")
        content = content:gsub("&nbsp;", " ")
        content = content:gsub("&amp;", "&")
        content = content:gsub("&lt;", "<")
        content = content:gsub("&gt;", ">")

        print()

        local width = term.getSize()

        for line in content:gmatch("[^\r\n]+") do
            line = line:gsub("^%s+", ""):gsub("%s+$", "")

            if #line > 0 then
                while #line > width do
                    print(line:sub(1, width))
                    line = line:sub(width + 1)
                end

                print(line)
            end
        end
    end

    print()
    print("--------------------------------")
    print("ENTER = neue Seite | exit = Ende")
    read()
    term.clear()
    term.setCursorPos(1, 1)
end
