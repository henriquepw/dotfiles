-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Go templ format on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = "*.templ",
  callback = function()
    vim.cmd("silent term templ fmt %")
  end,
})
