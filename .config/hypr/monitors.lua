-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "DP-2", mode = "preferred", position = "0x0", scale = omarchy_monitor_scale })

-- Virtual Display
hl.monitor({ output = "HEADLESS-1", mode = "3840x2160@60", position = "2560x0", scale = 1 })
