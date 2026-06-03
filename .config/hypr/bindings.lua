-- Application bindings.
o.bind("SUPER + SHIFT + T", "Terminal", 'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"')
o.bind("SUPER + SHIFT + F", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + SHIFT + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + SHIFT + O", "Obsidian", { focus = "^obsidian$", launch = "obsidian" })

hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Steam", { focus = "^steam$", launch = "steam" })

-- Web app bindings.
o.bind("SUPER + SHIFT + C", "ChatGPT", { webapp = "https://chatgpt.com" })
o.bind("SUPER + SHIFT + D", "Discord", { webapp = "https://discord.com/app", focus = true })
o.bind("SUPER + SHIFT + M", "Music", { webapp = "https://music.youtube.com/", focus = true })
o.bind("SUPER + SHIFT + G", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })

-- Full screen
hl.unbind("SUPER + M")
o.bind("SUPER + M", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Launcher and menu.
hl.unbind("SUPER + RETURN")
hl.unbind("SUPER + SPACE")
o.bind("SUPER + RETURN", nil, "walker")
o.bind("SUPER + BACKSPACE", "Omarchy menu", "omarchy-menu")

-- Close windows.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Close window", hl.dsp.window.close())

-- Switch and move workspaces
local workspaceLetter = { "Q", "W", "E", "R", "T", "Y" }
for w = 1, 6 do
	local workspace = tostring(w)
	local code = tostring(w + 9)

	hl.unbind("SUPER + code:" .. code)
	o.bind(
		"SUPER + code:" .. code,
		"Move window to workspace " .. workspace,
		hl.dsp.window.move({ workspace = workspace })
	)

	hl.unbind("SUPER + " .. workspaceLetter[w])
	o.bind(
		"SUPER + " .. workspaceLetter[w],
		"Switch to workspace " .. workspace,
		hl.dsp.focus({ workspace = workspace })
	)
end

hl.unbind("SUPER + H")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus on below window", hl.dsp.focus({ direction = "d" }))

hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
o.bind("SUPER + LEFT", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + RIGHT", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + UP", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + DOWN", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

-- Unbind old print screen keys to avoid conflicts.
hl.unbind("PRINT")
hl.unbind("SHIFT + PRINT")
hl.unbind("CTRL + PRINT")
hl.unbind("ALT + PRINT")
hl.unbind("CTRL + ALT + PRINT")
hl.unbind("SUPER + PRINT")

-- Screenshots and recordings.
hl.unbind("SUPER + P")
hl.unbind("SUPER + SHIFT + P")
o.bind("SUPER + P", "Screenshot of region", "omarchy capture screenshot region")
o.bind("SUPER + SHIFT + P", "Screen record a region", "omarchy capture screenrecording")

-- Color picker.
hl.unbind("SUPER + ALT + C")
o.bind("SUPER + ALT + C", "Color picker", "pkill hyprpicker || hyprpicker -a")

-- CTRL -> SUPER
local function send_shortcut_once(mods, key)
	return function()
		hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down", window = "activewindow" }))

		hl.timer(function()
			hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up", window = "activewindow" }))
		end, { timeout = 50, type = "oneshot" })
	end
end

hl.unbind("SUPER + A")
o.bind("SUPER + A", "Universal cut", send_shortcut_once("CTRL", "A"))

hl.unbind("SUPER + F")
o.bind("SUPER + F", "Universal Search", send_shortcut_once("CTRL", "F"))
