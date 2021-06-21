local wezterm = require 'wezterm';
wezterm.on("update-right-status", function(window, pane)
  -- "Wed Mar 3 08:14"
  local date = wezterm.strftime("%a %b %-d,%I:%M:%S%p ");

  local bat = ""
  for _, b in ipairs(wezterm.battery_info()) do
    bat = "🔋 " .. string.format("%.0f%%", b.state_of_charge * 100)
  end

  window:set_right_status(wezterm.format({
    {Text=bat .. " 🔥 "..date},
  }));
end)
return {
  window_background_opacity = 1.0,
  window_padding={
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  font = wezterm.font("Operator Mono Lig Medium"),
  exit_behavior="Close",
  color_scheme = "OceanicMaterial",
}
