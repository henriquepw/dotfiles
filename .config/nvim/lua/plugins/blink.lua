vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
})

require("blink.cmp").setup({
	keymap = {
		preset = "super-tab",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = {
		menu = { auto_show = true },
		documentation = { auto_show = true, auto_show_delay_ms = 200 },
	},
	sources = { default = { "lsp", "path", "buffer" } },
	snippets = { preset = "default" },
	fuzzy = { implementation = "prefer_rust", prebuilt_binaries = { download = true } },
})
