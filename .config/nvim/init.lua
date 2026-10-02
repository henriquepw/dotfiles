require("config/options")
require("config/keymap")
require("config/statusline")
require("config/autocmds")
require("config/spell")

local pluginsPath = vim.fn.stdpath("config") .. "/lua/plugins"
for name, type in vim.fs.dir(pluginsPath) do
	if type == "file" and name:match("%.lua") and name ~= "init.lua" then
		require("plugins." .. name:gsub("%.lua$", ""))
	end
end
