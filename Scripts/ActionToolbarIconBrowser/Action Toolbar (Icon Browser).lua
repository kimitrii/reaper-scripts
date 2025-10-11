-- @description Action Toolbar (Icon Browser)
-- @version 1.0
-- @author Kimitri

local script_name = "Action Toolbar (Icon Browser)"
local section = "ActionToolbarIconBrowserDockState"

------------------------------------------------------------
-- Detect and toggle instance
------------------------------------------------------------
if reaper.JS_Window_Find then
    local hwnd = reaper.JS_Window_Find(script_name, true)
    if hwnd then
        reaper.JS_Window_Destroy(hwnd)
        return
    end
end

--  Retrieve previous docking state
local dock_state = tonumber(reaper.GetExtState(section, "dock_state")) or 0
gfx.init(script_name, 600, 500, dock_state)

reaper.defer(function()
    local hwnd = reaper.JS_Window_Find(script_name, true)
    if hwnd then
        reaper.JS_Window_SetFocus(hwnd)
    end
end)


------------------------------------------------------------
-- Colors and fonts
------------------------------------------------------------
local theme_color = reaper.GetThemeColor("col_main_bg2", 0)
if theme_color == -1 then theme_color = reaper.GetThemeColor("col_main_bg", 0) end

local function colorToRGB(color)
    local r = color & 0xFF
    local g = (color >> 8) & 0xFF
    local b = (color >> 16) & 0xFF
    return r/255, g/255, b/255
end

local bg_r, bg_g, bg_b = colorToRGB(theme_color)
local bg_color_native = reaper.ColorToNative(bg_r * 255, bg_g * 255, bg_b * 255) 

gfx.setfont(1, "Arial", 16)
local was_lmb = false
local active_button = nil

------------------------------------------------------------
-- Load buttons from .ini file
------------------------------------------------------------
local config_dir = reaper.GetResourcePath() .. "/scripts/ActionToolbarIconBrowser"
local config_path = config_dir .. "/ActionToolbarIconBrowserConfig.ini"

if not reaper.file_exists(config_dir) then
    reaper.RecursiveCreateDirectory(config_dir, 0)
end

local icon_path = reaper.GetResourcePath() .. "/Data/toolbar_icons/"

local function parse_ini(path)
    local f = io.open(path, "r")
    if not f then return {}, {} end

    local menu_buttons = {}
    local content_buttons = {}
    local current_section

    for line in f:lines() do
        line = line:match("^%s*(.-)%s*$") -- trim
        if line ~= "" and not line:match("^;") then
            local section = line:match("^%[(.-)%]$")
            if section then
                current_section = section
                if section ~= "Menu" then
                    content_buttons[section] = {}
                end
            elseif current_section then
                local key, value = line:match("^(.-)=(.+)$")
                if key and value then
                    key = key:match("^%s*(.-)%s*$")
                    value = value:match("^%s*(.-)%s*$")

                    if current_section == "Menu" then
                        table.insert(menu_buttons, { name = key, category = value })
                    else
                        local cmd, img = value:match("([^,]+),%s*(.+)")
                        table.insert(content_buttons[current_section], {
                            name = key,
                            cmd = cmd,
                            image = icon_path .. img
                        })
                    end
                end
            end
        end
    end

    f:close()
    return menu_buttons, content_buttons
end

local menu_buttons, content_buttons = parse_ini(config_path)

local active_category = menu_buttons[1] and menu_buttons[1].category or nil
local active_menu_index = 1
local active_content_index = 0

------------------------------------------------------------
-- save data to /FXCustomBrowserConfig/FXBrowserConfig.ini
------------------------------------------------------------
local function save_to_ini(path, menu_buttons, content_buttons)
    local f = io.open(path, "w")
    if not f then return end

    f:write("[Menu]\n")
    for _, btn in ipairs(menu_buttons) do
        f:write(("%s=%s\n"):format(btn.name, btn.category))
    end
    f:write("\n")

    for cat, list in pairs(content_buttons) do
        f:write(("[" .. cat .. "]\n"))
        for _, fx in ipairs(list) do
            local img = fx.image:match("([^/\\]+)$") or fx.image 
            f:write(("%s=%s,%s\n"):format(fx.name, fx.cmd, img))
        end
        f:write("\n")
    end
    f:close()
end

------------------------------------------------------------
-- load images with cache
------------------------------------------------------------
local next_image_id = 0
local loaded_images = {}

local function load_image(path)
    if not path or path == "" then return nil end
    if loaded_images[path] then return loaded_images[path].id end

    next_image_id = next_image_id + 1
    local id = next_image_id
    local success = gfx.loadimg(id, path)
    if success ~= -1 then
        local w, h = gfx.getimgdim(id)
        loaded_images[path] = { id = id, w = w, h = h }
        return id
    end
    return nil
end

------------------------------------------------------------
-- Run content button actions
------------------------------------------------------------
local function run_action(cmd_id)
    local command = reaper.NamedCommandLookup(cmd_id)
    if command and command ~= 0 then
        reaper.Main_OnCommand(command, 0)
    else
        reaper.ShowMessageBox("Command ID inválido: " .. tostring(cmd_id), "Erro", 0)
    end
end

------------------------------------------------------------
-- Draw sidebar menu
------------------------------------------------------------
local menu_scroll_y = 0
local menu_max_scroll = 0
local scroll_y = 0
local max_scroll = 0

local function draw_menu(mx, my, lmb)
    local x, y = 20, 40 - menu_scroll_y
    local btn_w, btn_h = 120, 35
    local visible_limit = gfx.h + 50

    

    ------------------------------------------------------------
    -- Then draw the normal menu buttons (as before)
    ------------------------------------------------------------
    for _, btn in ipairs(menu_buttons) do
        if y + btn_h >= 0 and y <= visible_limit then
            local hover = mx > x and mx < x + btn_w and my > y and my < y + btn_h
            local active = (btn.category == active_category)

            -- Adjust button width according to text
            gfx.setfont(1, "Arial", 16)
            local text_w, text_h = gfx.measurestr(btn.name)
            local padding = 20
            local min_w = 120
            local dynamic_w = math.max(min_w, text_w + padding)
            local btn_w_dynamic = dynamic_w

            -- Colors
            if active then
                gfx.set(0.2, 0.6, 1.0)
            elseif hover then
                gfx.set(0.45, 0.45, 0.55)
            else
                gfx.set(0.35, 0.35, 0.35)
            end

            -- Draw button with adjusted width
            gfx.roundrect(x, y, btn_w_dynamic, btn_h, 6, 1)

            -- Vertically centered text
            gfx.x = x + 10
            gfx.y = y + (btn_h - text_h) / 2
            gfx.set(1, 1, 1)
            gfx.drawstr(btn.name)

            -- Click
            if hover and lmb and not was_lmb then
                if active_category ~= btn.category then
                    active_category = btn.category
                    scroll_y = 0 
                end
            end
        end
        y = y + btn_h + 10
    end


    ------------------------------------------------------------
    -- Button: Add Menu
    ------------------------------------------------------------
    local function add_menu_button()
        local ok, ret = reaper.GetUserInputs("New Menu Category", 2, "Display name:,Category ID:", "")
        if not ok then return end
        local name, category = ret:match("([^,]+),([^,]+)")
        if not (name and category) then return end

        table.insert(menu_buttons, { name = name, category = category })
        content_buttons[category] = {}
        save_to_ini(config_path, menu_buttons, content_buttons)
    end

    ------------------------------------------------------------
    -- Draw the add button
    ------------------------------------------------------------

    local hover = mx > x and mx < x + 50 and my > y and my < y + btn_h
    gfx.set(hover and 0.4 or 0.3, hover and 0.5 or 0.3, hover and 0.6 or 0.3)
    gfx.roundrect(x, y, 50, btn_h, 6, 1)
    gfx.x, gfx.y = x + 20, y + 8
    gfx.set(1, 1, 1)
    gfx.drawstr("+")

    if hover and lmb and not was_lmb then
        add_menu_button()
    end
    y = y + btn_h + 10

    menu_max_scroll = math.max(0, (#menu_buttons * (btn_h + 10)) - gfx.h + 90)
end

------------------------------------------------------------
-- Draw content with scroll (optimized)
------------------------------------------------------------

local function draw_content(mx, my, lmb)
    local x_start = 180
    local y_start = 40 - scroll_y
    local spacing_x, spacing_y = 20, 20
    local list = content_buttons[active_category] or {}

    local x = x_start
    local y = y_start
    local line_height = 0
    local available_width = gfx.w - x_start - 20
    local visible_limit = gfx.h + 150

    ------------------------------------------------------------
    -- Pre-calculate total height (without drawing)
    ------------------------------------------------------------
    local total_height = 0
    local temp_x, temp_line_height = 0, 0

    for _, btn in ipairs(list) do
        local img_data = loaded_images[btn.image]
        if not img_data then load_image(btn.image) img_data = loaded_images[btn.image] end
        if img_data then
            local iw, ih = img_data.w / 3, img_data.h
            if temp_x + iw > available_width then
                total_height = total_height + temp_line_height + spacing_y
                temp_x, temp_line_height = 0, 0
            end
            temp_x = temp_x + iw + spacing_x
            temp_line_height = math.max(temp_line_height, ih)
        end
    end
    total_height = total_height + temp_line_height + spacing_y + 30  

    ------------------------------------------------------------
    --  Draw content
    ------------------------------------------------------------
    for i, btn in ipairs(list) do
        local img_data = loaded_images[btn.image]
        if img_data then
            local img_id, iw, ih = img_data.id, img_data.w / 3, img_data.h
            local frame_w, frame_h = iw, ih

            if x + frame_w > gfx.w - 20 then
                x = x_start
                y = y + line_height + spacing_y
                line_height = 0
            end

            line_height = math.max(line_height, frame_h)

            if y + frame_h >= 0 and y <= visible_limit then
                local offset_y = (line_height - frame_h) / 2
                local hover = mx > x and mx < x + frame_w and my > y + offset_y and my < y + offset_y + frame_h

                -- Keyboard selected icon
                local selected = (i == active_content_index) 

                local active = (active_button == btn)
                local src_x = active and frame_w * 2 or (hover and frame_w or 0)

                gfx.blit(img_id, 1, 0, src_x, 0, frame_w, frame_h, x, y + offset_y, frame_w, frame_h)

                if selected then
                    gfx.set(0.2, 0.6, 1.0, 1) 
                    gfx.rect(x - 2, y + offset_y - 2, frame_w + 4, frame_h + 4, false)
                end

                if hover and lmb and not was_lmb then
                    active_button = btn
                    active_content_index = i
                    run_action(btn.cmd)
                end
            end

            x = x + frame_w + spacing_x
        end
    end

    y = y + line_height + spacing_y

    ------------------------------------------------------------
    -- Add button (fixed after everything)
    ------------------------------------------------------------
    local hover = mx > x_start and mx < x_start + 50 and my > y and my < y + 30
    gfx.set(hover and 0.4 or 0.3, hover and 0.5 or 0.3, hover and 0.6 or 0.3)
    gfx.roundrect(x_start, y, 50, 30, 6, 1)
    gfx.x, gfx.y = x_start + 20, y + 8
    gfx.set(1, 1, 1)
    gfx.drawstr("+")

    if hover and lmb and not was_lmb then
        if active_category then
            local ok, ret = reaper.GetUserInputs("New Action Button", 3, "Name:,Action ID:,Image file (ex: MyIcon.png):", "")
            if ok then
                local name, cmd, img = ret:match("([^,]+),([^,]+),([^,]+)")
                if name and cmd and img then
                    table.insert(content_buttons[active_category], { name=name, cmd=cmd, image=icon_path .. img })
                    save_to_ini(config_path, menu_buttons, content_buttons)
                end
            end
        else
            reaper.ShowMessageBox("No active category.", "Warning", 0)
        end
    end

    ------------------------------------------------------------
    -- max scroll based on total height
    ------------------------------------------------------------
    max_scroll = math.max(0, total_height - (gfx.h - 50))
end

------------------------------------------------------------
function main()
    gfx.clear = bg_color_native
    local mx, my = gfx.mouse_x, gfx.mouse_y
    local lmb = gfx.mouse_cap & 1 == 1

    -- Independent scroll for menu and content
    local mw = gfx.mouse_wheel
    if mw ~= 0 then
        if mx < 160 then
            -- Scroll in menu (left side)
            menu_scroll_y = math.max(0, math.min(menu_scroll_y - mw / 120 * 30, menu_max_scroll))
        else
            -- Scroll in content
            scroll_y = math.max(0, math.min(scroll_y - mw / 120 * 30, max_scroll))
        end
    end
    gfx.mouse_wheel = 0


    draw_menu(mx, my, lmb)
    draw_content(mx, my, lmb)

    if was_lmb and not lmb then
        active_button = nil
    end

    was_lmb = lmb
    gfx.update()

    local char = gfx.getchar()

-- If ESC is pressed, exit the script
    if char == 27 then
        gfx.quit()
        return
    end

    ------------------------------------------------------------
    -- ↑ up arrow = previous menu
    ------------------------------------------------------------
    if char == 30064 then
        if #menu_buttons > 0 then
            active_menu_index = math.max(1, active_menu_index - 1)
            active_category = menu_buttons[active_menu_index].category
            active_content_index = 0
            scroll_y = 0
        end
    end

    ------------------------------------------------------------
    -- ↓ down arrow = next menu
    ------------------------------------------------------------
    if char == 1685026670 then
        if #menu_buttons > 0 then
            active_menu_index = math.min(#menu_buttons, active_menu_index + 1)
            active_category = menu_buttons[active_menu_index].category
            active_content_index = 0
            scroll_y = 0
        end
    end

    ------------------------------------------------------------
    -- ← Left arrow = navegate to the left content items
    ------------------------------------------------------------
    if char == 1818584692 then
        local list = content_buttons[active_category] or {}
        if #list > 0 then
            active_content_index = math.max(0, active_content_index - 1)
        end
    end

    ------------------------------------------------------------
    -- → Right arrow = Navegate to right content items
    ------------------------------------------------------------
    if char == 1919379572 then
        local list = content_buttons[active_category] or {}
        if #list > 0 then
            active_content_index = math.min(#list, active_content_index + 1)
        end
    end

    ------------------------------------------------------------
    -- Enter = executar ação do item ativo
    ------------------------------------------------------------
    if char == 13 then
        local list = content_buttons[active_category] or {}
        local btn = list[active_content_index]
        if btn then
            run_action(btn.cmd)
        end
    end

    if char >= 0 then
        reaper.defer(main)
    else
        gfx.quit()
    end

end

reaper.atexit(function()
    reaper.SetExtState(section, "dock_state", tostring(gfx.dock(-1)), true)
end)

main()
