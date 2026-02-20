-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

local function add_word_to_lang(lang)
  -- Find word under cursor
  local word = vim.fn.expand("<cword>")
  if word == "" then
    print("No word under cursor.")
    return
  end

  -- Save original language and spellfile
  local original_lang = vim.opt.spelllang:get()
  local original_spellfile = vim.opt.spellfile

  -- Get the current language file
  local spellfile_path = vim.fn.expand(string.format("~/.dotfiles/nvim/spell/%s.utf-8.add", lang))

  -- Temporarily set spelllang to only the desired language
  vim.opt.spelllang = { lang }
  vim.opt.spellfile = spellfile_path

  -- Mark word as good and save spellfile
  vim.cmd("silent! spellgood " .. word)
  vim.cmd("silent! mkspell! " .. spellfile_path)

  -- Restore original settings
  vim.opt.spelllang = original_lang
  vim.opt.spellfile = original_spellfile

  print("Added '" .. word .. "' to " .. lang)
end

map("n", "<leader>z", "", { desc = "Spelling" })

map("n", "<leader>zp", function()
  add_word_to_lang("pt_br")
end, {
  desc = "Add word to Portuguese",
})

map("n", "<leader>ze", function()
  add_word_to_lang("en_us")
end, {
  desc = "Add word to English",
})
