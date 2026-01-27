-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.colorcolumn = "80,120"
vim.g.snacks_animate = false

local biome_augroup = vim.api.nvim_create_augroup("BiomeOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  group = biome_augroup,
  pattern = { "*.ts", "*.tsx" },
  callback = function()
    local current_file_path = vim.fn.expand("%:p")
    local current_dir = vim.fn.fnamemodify(current_file_path, ":h")

    -- Get root directory
    local project_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
    if not project_root or project_root == "" then
      project_root = current_dir
      local parent_dir = current_dir
      while parent_dir ~= "/" and parent_dir ~= "." and parent_dir ~= "" do
        if vim.fn.filereadable(parent_dir .. "/biome.json") then
          project_root = parent_dir
          break
        end
        parent_dir = vim.fn.fnamemodify(parent_dir, ":h")
      end
    end

    -- Run biome check if the repository has a biome config file
    local biome_config_path = project_root .. "/biome.json"
    if vim.fn.filereadable(biome_config_path) == 1 then
      vim.cmd("silent !biome check --write --unsafe " .. vim.fn.expand("%:p"))
    end
  end,
})
