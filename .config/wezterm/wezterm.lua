local wezterm = require 'wezterm';
wezterm.on("update-right-status", function(window, pane)
    -- "Wed Mar 3 08:14"
    local date = wezterm.strftime("%a %b %-d,%I:%M:%S%p ");

    local bat = ""
    for _, b in ipairs(wezterm.battery_info()) do
        bat = "🔋 " .. string.format("%.0f%%", b.state_of_charge * 100)
    end

    window:set_right_status(wezterm.format({{
        Text = bat .. " 🔥 " .. date
    }}));
end)
return {
    window_background_opacity = 1.0,
    initial_rows = 26,
    initial_cols = 90,
    adjust_window_size_when_changing_font_size = false,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    },
    colors = {
        tab_bar = {
            active_tab = {
                bg_color = '#1C262B',
                fg_color = '#F93295',
                intensity = 'Normal',
                underline = 'None',
                italic = false,
                strikethrough = false
            },
            inactive_tab = {
                bg_color = "#1b1032",
                fg_color = "#303030"
            },
            inactive_tab_hover = {
                bg_color = "#3b3052",
                fg_color = "#909090",
                italic = true
            }
        }
    },
    font = wezterm.font("Operator Mono Lig Medium"),
    exit_behavior = "Close",
    color_scheme = "OceanicMaterial",
    dpi = 121.0
}
