vim.pack.add({
	"https://github.com/folke/snacks.nvim",
})

require("snacks").setup({
	bigfile = { enabled = true },
	image = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	quickfile = { enabled = true },
	scope = { enabled = true },
	words = { enabled = true },
	picker = {
		sources = {
			explorer = {
				ignored = true,
				hidden = true,
				auto_close = true,
				layout = {
					layout = {
						box = "horizontal",
						width = 0.8,
						height = 0.8,
						{
							box = "vertical",
							border = "rounded",
							title = "{source} {live} {flags}",
							title_pos = "center",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
						{ win = "preview", border = "rounded", width = 0.65, title = "{preview}" },
					},
				},
			},
		},
	},
})

vim.g.snacks_animate = false

local map = vim.keymap.set

-- toggle options
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.dim():map("<leader>uD")

if vim.lsp.inlay_hint then
	Snacks.toggle.inlay_hints():map("<leader>uh")
end

-- Explorer
map("n", "<leader><space>", function()
	Snacks.picker.smart()
end, { desc = "Explorer" })
map("n", "<leader>e", function()
	Snacks.explorer()
end, { desc = "Explorer" })
map("n", "<leader>,", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
map("n", "<leader>/", function()
	Snacks.picker.grep()
end, { desc = "Grep" })

-- LSP
map("n", "<leader>gd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Goto Definition" })

-- Lazygit
map("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })

-- Buffer
map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function()
	Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
