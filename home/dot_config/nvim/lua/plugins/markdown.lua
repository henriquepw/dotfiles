vim.pack.add({
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
})

local map = vim.keymap.set
local markdown = require("render-markdown")

markdown.setup({
	completions = { lsp = { enabled = true } },
})

map("n", "<leader>um", function()
	require("render-markdown").toggle()
end, { desc = "Toggle markdown view" })
