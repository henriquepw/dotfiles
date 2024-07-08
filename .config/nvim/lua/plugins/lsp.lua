return {
  { "williamboman/mason.nvim" },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_installation = true,
      ensure_installed = {
        "lua_ls",
        "gopls",
        "biome",
        "html",
        "htmx",
      },
    },
  },
  { "neovim/nvim-lspconfig" },
}
