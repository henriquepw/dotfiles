vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	{
		src = "https://github.com/ThePrimeagen/harpoon",
		version = "harpoon2",
	},
})

local map = vim.keymap.set
local harpoon = require("harpoon")

harpoon.setup({
	menu = {
		width = vim.api.nvim_win_get_width(0) - 4,
	},
	settings = {
		save_on_toggle = true,
	},
})

map("n", "<leader>h", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon - Quick Menu" })

map("n", "<C-n>", function()
	harpoon:list():add()
end, { desc = "Harpoon - Add file" })
map("n", "<C-r>", function()
	harpoon:list():clear()
end, { desc = "Harpoon - Remove buffers" })

map("n", "<C-]>", function()
	harpoon:list():next({ ui_nav_wrap = true })
end, { desc = "Harpoon - Next buffers" })
map("n", "<C-[>", function()
	harpoon:list():prev({ ui_nav_wrap = true })
end, { desc = "Harpoon - Prev buffers" })

vim.keymap.del("n", "<esc>")
