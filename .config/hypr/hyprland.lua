-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH.
package.path = os.getenv("HOME")
	.. "/.config/?.lua;"
	.. (os.getenv("OMARCHY_PATH") or (os.getenv("HOME") .. "/.local/share/omarchy"))
	.. "/?.lua;"
	.. package.path

-- All Omarchy default setups
require("default.hypr.omarchy")

-- Change your own setup in these files and override defaults.
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
for workspace = 1, 6 do
	hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-3" })
end

hl.workspace_rule({ workspace = "1", layout = "master", monitor = "DP-3" })
hl.workspace_rule({ workspace = "2", layout = "master", monitor = "DP-3" })
hl.workspace_rule({ workspace = "5", layout = "scrolling", monitor = "DP-3" })

-- Window rules.
o.window(".*", { opacity = "1 1" })
o.window("com.mitchellh.ghostty", { workspace = "1" })

-- Webapps
o.window({ class = "^brave%-web%.whatsapp.*$" }, { workspace = "4" })
o.window({ class = "^brave%-music.*$" }, { workspace = "4" })
o.window({ class = "^brave%-discord.*$" }, { workspace = "4" })

-- Steam
o.window("steam", { workspace = "5" })
o.window({ class = "^steam_app_.*$" }, { workspace = "6" })
o.window({ class = "steam", title = "Steam" }, { size = "50% 100%", move = "10 36" })
o.window({ class = "steam", title = "Friends List" }, { size = "18% 100%", move = "51% 38" })
o.window({ class = "steam", title = "Budega do seu Vicente" }, { size = "30% 100%", move = "100% 38" })

o.window("easyeffects", { workspace = "5" })
