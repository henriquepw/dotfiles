local map = vim.keymap.set

local spell_dir = vim.fn.stdpath("config") .. "/spell/"
vim.opt.spelllang = { "pt_br", "en_us" }
vim.opt.spellfile = {
	spell_dir .. "pt.utf-8.add",
	spell_dir .. "en.utf-8.add",
}

map("n", "<leader>z", "", { desc = "Spelling" })
map("n", "<leader>zp", "1zg", { desc = "Add word to Portuguese" })
map("n", "<leader>ze", "2zg", { desc = "Add word to English" })
