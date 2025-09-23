return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    keys = function()
      local harpoon = require("harpoon")

      return {
        {
          "<C-n>",
          function()
            harpoon:list():add()
          end,
          desc = "Harpoon Add File",
        },
        {
          "<C-r>",
          function()
            harpoon:list():clear()
          end,
          desc = "Harpoon Remove Buffers",
        },
        {
          "<leader>h",
          function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = "Harpoon Quick Menu",
        },
        {
          "<M-l>",
          function()
            harpoon:list():next({ ui_nav_wrap = true })
          end,
          desc = "Harpoon Next",
        },
        {
          "<M-h>",
          function()
            harpoon:list():prev({ ui_nav_wrap = true })
          end,
          desc = "Harpoon Prev",
        },
        -- Mac Alt+h and Alt+l
        {
          "¬",
          function()
            harpoon:list():next({ ui_nav_wrap = true })
          end,
          desc = "Harpoon Next",
        },

        {
          "˙",
          function()
            harpoon:list():prev({ ui_nav_wrap = true })
          end,
          desc = "Harpoon Prev",
        },
      }
    end,
  },
}
