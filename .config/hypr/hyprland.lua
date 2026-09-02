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
for workspace = 1, 6 do
	hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-3" })
end

hl.workspace_rule({ workspace = "1", layout = "master", monitor = "DP-3" })
hl.workspace_rule({ workspace = "2", layout = "master", monitor = "DP-3" })
hl.workspace_rule({ workspace = "5", layout = "scrolling", monitor = "DP-3" })

-- Window rules.
o.window(".*", { opacity = "1 1" })
o.window("foot", { workspace = "1" })
o.window({ class = "^sable$" }, { workspace = "4" })

-- Webapps
o.window({ class = "^brave%-*.whatsapp.*$" }, { workspace = "4" })
o.window({ class = "^brave%-music.*$" }, { workspace = "4" })
o.window({ class = "^brave%-discord.*$" }, { workspace = "4" })

-- Steam
o.window("steam", { workspace = "5" })
o.window({ class = "^steam_app_.*$" }, { workspace = "6" })
o.window({ class = "steam", title = "Steam" }, { size = "50% 100%", move = "10 36" })
o.window({ class = "steam", title = "Friends List" }, { size = "18% 100%", move = "51% 38" })
o.window({ class = "steam", title = "Budega do seu Vicente" }, { size = "30% 100%", move = "100% 38" })

o.window("easyeffects", { workspace = "5" })
