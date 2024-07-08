return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      pen_mapping = [[<c-\>]],
      shade_terminals = false,
      shell = "zsh --login",
    })
  end,
  keys = {
    { [[<C-\>]] },
    {
      "<leader>t",
      "<cmd>ToggleTerm size=10 direction=horizontal<cr>",
      desc = "Open a horizontal terminal at the Desktop directory",
    },
  },
}
