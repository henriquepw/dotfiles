vim.opt.termguicolors = true

vim.pack.add({
  "https://github.com/ficd0/ashen.nvim"
})

require("ashen").setup({ transparent = true })
vim.cmd("colorscheme ashen")

