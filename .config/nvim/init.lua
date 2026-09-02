require("config/options")
require("config/keymap")
require("config/statusline")
require("config/autocmds")
require("config/spell")

require("vim._core.ui2").enable()

local pluginsPath = vim.fn.stdpath("config") .. "/lua/plugins"
for name, type in vim.fs.dir(pluginsPath) do
	if (type == "file" or type == "link") and name:match("%.lua") and name ~= "init.lua" then
		require("plugins." .. name:gsub("%.lua$", ""))
	end
end
