return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      notifier = { enabled = false },
      bigfile = { enabled = true },
      picker = {
        sources = {
          explorer = {
            auto_close = true,
            layout = {
              { preview = true },
              layout = {
                box = "horizontal",
                width = 0.90,
                height = 0.90,
                {
                  box = "vertical",
                  border = "rounded",
                  title = "{source} {live} {flags}",
                  title_pos = "center",
                  { win = "input", height = 1, border = "bottom" },
                  { win = "list", border = "none" },
                },
                { win = "preview", border = "rounded", width = 0.65, title = "{preview}" },
              },
            },
          },
        },
      },
    },
  },
}
