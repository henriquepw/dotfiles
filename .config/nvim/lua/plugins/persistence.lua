vim.pack.add({
	"https://github.com/folke/persistence.nvim",
})

require("persistence").setup({})

-- Load the session from the start menu.
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.keymap.set("n", "r", function()
			require("persistence").load()
		end, { buffer = true })
	end,
})

vim.keymap.set("n", "<leader>qs", function()
	require("persistence").load()
end)

vim.keymap.set("n", "<leader>qS", function()
	require("persistence").select()
end)

vim.keymap.set("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end)

vim.keymap.set("n", "<leader>qd", function()
	require("persistence").stop()
end)
