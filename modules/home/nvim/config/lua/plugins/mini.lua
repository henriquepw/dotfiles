vim.pack.add({
	"https://github.com/nvim-mini/mini.nvim",
})

require("mini.ai").setup({})
require("mini.bufremove").setup({})
require("mini.comment").setup({})
require("mini.icons").setup({})
require("mini.move").setup({})
require("mini.pairs").setup({})
require("mini.surround").setup({})
require("mini.trailspace").setup({})
require("mini.notify").setup({
	window = {
		config = {
			anchor = "SE",
		},
	},
})
