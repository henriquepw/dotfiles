-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Master layout settings.
hl.config({
	master = {
		mfact = 0.65,
		new_status = "slave",
	},
})

-- Workspace layouts.
o.window(".*", { opacity = "1 1" })
for workspace = 1, 6 do
	hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-2" })
end

-- Workspace 1
hl.workspace_rule({ workspace = "1", layout = "master", monitor = "DP-2" })
o.window("foot", { workspace = "1" })

-- Workspace 2
hl.workspace_rule({ workspace = "2", layout = "master", monitor = "DP-2" })

-- Workspace 3
o.window({ class = "org.freecad.FreeCAD" }, { workspace = "3" })
o.window({ class = "orca-slicer" }, { workspace = "3" })

-- Workspace 4
o.window({ class = "^sable.*$" }, { workspace = "4" })
o.window({ class = "^brave%-*.whatsapp.*$" }, { workspace = "4" })
o.window({ class = "^brave%-music.*$" }, { workspace = "4" })
o.window({ class = "^brave%-discord.*$" }, { workspace = "4" })

-- Workspace 5
hl.workspace_rule({ workspace = "5", layout = "scrolling", monitor = "DP-2" })

o.window("steam", { float = true, idle_inhibit = "fullscreen", workspace = "5" })
o.window({ class = "steam", title = "Steam" }, { size = "50% 700", move = "50 120" })
o.window({ class = "steam", title = "(Friends List|Lista de amigos)" }, { size = "18% 700", move = "55% 150" })

-- Workspace 6
o.window({ class = "^steam_app_.*$" }, { workspace = "6" })
