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
            ignored = true,
            hidden = true,
            auto_close = true,
            layout = {
              layout = {
                box = "horizontal",
                width = 0.9,
                height = 0.8,
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
