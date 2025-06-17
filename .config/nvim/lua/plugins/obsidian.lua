return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "/Volumes/Data/documents/vaults/personal",
      },
      {
        name = "work",
        path = "/Volumes/Data/documents/vaults/work",
      },
    },
  },
}
