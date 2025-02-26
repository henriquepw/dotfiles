return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    servers = {
      ts_ls = {
        enabled = true,
      },
      tailwindcss = {
        filetypes = {
          "html",
          "css",
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
          "rust",
          "templ",
        },
        init_options = {
          userLanguages = {
            rust = "html",
          },
        },
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                'tw!\\("([^"]*)"\\)',
                '"([^"]*)"',
                'class: "(.*)"',
              },
            },
            lint = {
              invalidApply = false,
            },
          },
        },
      },
      cssls = {
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
          scss = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
      },
      volar = {
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
          scss = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
      },
    },
  },
}
