return {
  {
    "ahmedkhalf/project.nvim",
    lazy = false,
    config = function()
      require("project_nvim").setup({})
      vim.keymap.set("n", "<leader>p", "<cmd>Telescope projects<cr>", { desc = "Projects" })
    end,
  },
}
