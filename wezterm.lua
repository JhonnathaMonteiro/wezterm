local wezterm = require("wezterm")
local act = wezterm.action

local config = {}
-- Use config builder opbject if possible
if wezterm.config then config = wezterm.config end

-- Settings
config.color_scheme = "Batman"
config.font = wezterm.font {
    family = 'JetBrains Mono',
    weight = 'DemiBold'
}
config.font_size = 14
config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "home"

-- Dim active pane
config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.8,
}

-- Keys
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    -- Send C-a when pressing C-a twice
    { key = "a", mods = "LEADER",       action = act.SendKey { key = "a", mods = "CTRL" } },
    { key = "c", mods = "LEADER",       action = act.ActivateCopyMode },

    -- Pane keybindings
    { key = "-", mods = "LEADER",       action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "h", mods = "LEADER",       action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER",       action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER",       action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER",       action = act.ActivatePaneDirection("Right") },
    { key = "x", mods = "LEADER",       action = act.CloseCurrentPane { confirm = true } },
    { key = "z", mods = "LEADER",       action = act.TogglePaneZoomState },

    -- We can make separete keybindings for resizing panes
    -- But wezterm offers custom "mode" in the name of "KeyTable"
    { key = "r", mods = "LEADER",       action = act.ActivateKeyTable { name = "resize_pane", one_shot = false } },

    -- Tab keybindings
    { key = "n", mods = "LEADER",       action = act.SpawnTab("CurrentPaneDomain") },
    { key = "[", mods = "LEADER",       action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "LEADER",       action = act.ActivateTabRelative(1) },

    -- Key table for moving tabs around
    { key = "m", mods = "LEADER",       action = act.ActivateKeyTable { name = "move_tab", one_shot = false } },

    -- Lastly, workspace
    { key = "w", mods = "LEADER",       action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" } },
}

for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = act.ActivateTab(i - 1)
    })
end

config.key_tables = {
    resize_pane = {
        { key = "h",      action = act.AdjustPaneSize { "Left", 1 } },
        { key = "j",      action = act.AdjustPaneSize { "Down", 1 } },
        { key = "k",      action = act.AdjustPaneSize { "Up", 1 } },
        { key = "l",      action = act.AdjustPaneSize { "Right", 1 } },
        { key = "Escape", action = "PopKeyTable" },
        { key = "Enter",  action = "PopKeyTable" },
    },
    move_tab = {
        { key = "h",      action = act.MoveTabRelative(-1) },
        { key = "j",      action = act.MoveTabRelative(-1) },
        { key = "k",      action = act.MoveTabRelative(1) },
        { key = "l",      action = act.MoveTabRelative(1) },
        { key = "Escape", action = "PopKeyTable" },
        { key = "Enter",  action = "PopKeyTable" },
    }
}

--
-- Tab bar
--
---Return the suitable argument depending on the appearance
---@param arg { light: any, dark: any } light and dark alternatives
---@return any
local function depending_on_appearance(arg)
    local appearance = wezterm.gui.get_appearance()
    if appearance:find 'Dark' then
        return arg.dark
    else
        return arg.light
    end
end
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.status_update_interval = 1000
config.colors = {
    tab_bar = {
        active_tab = depending_on_appearance {
            light = { fg_color = '#ffffff', bg_color = '#282828' },
            dark = { fg_color = '#ffffff', bg_color = '#282828' },
        }
    }
}
wezterm.on("update-right-status", function(window, pane)
    -- workspace name
    local stat = window:active_workspace()
    if window:active_key_table() then stat = window:active_key_table() end
    if window:leader_is_active() then stat = "LDR" end

    -- Current command
    local cmd = string.match(pane:get_foreground_process_name(), ".*/(.-)$")

    -- Time
    local time = wezterm.strftime("%H:%M")

    -- Let's add color to one of the components
    window:set_right_status(wezterm.format({
        -- Wezterm has a built-in nerd fonts
        { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
        { Text = " | " },
        { Foreground = { Color = "FFB86C" } },
        { Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
        "ResetAttributes",
        { Text = " | " },
        { Text = wezterm.nerdfonts.md_clock .. "  " .. time .. " " },
    }))
end)

return config
