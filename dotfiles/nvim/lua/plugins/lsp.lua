vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
		build = ":TSUpdate",
	},
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
})

local map = vim.keymap.set

local setup_treesitter = function()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})
	local ensure_installed = {
		"regex",
		"vim",
		"vimdoc",
		"rust",
		"c",
		"cpp",
		"go",
		"html",
		"css",
		"javascript",
		"json",
		"lua",
		"markdown",
		"typescript",
		"tsx",
		"bash",
		"zig",
		"nix",
	}

	local config = require("nvim-treesitter.config")

	local already_installed = config.get_installed()
	local parsers_to_install = {}

	for _, parser in ipairs(ensure_installed) do
		if not vim.tbl_contains(already_installed, parser) then
			table.insert(parsers_to_install, parser)
		end
	end

	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

local setup_mason = function()
	require("mason").setup({})

	local ensure_installed = {
		-- efm vem do nix (nvim.nix), não do mason
		-- Latex
		"tectonic",
		-- Markdown
		"mmdc",
		-- Shell
		"bash-language-server",
		"shellcheck",
		"shfmt",
		-- Rust
		"rust-analyzer",
		-- C
		"clangd",
		"cpplint",
		-- Lua
		"lua-language-server",
		"stylua",
		-- "luacheck",
		-- Golang
		"gopls",
		"goimports",
		"gofumpt",
		"revive",
		-- TS
		"biome",
		"vtsls",
		"tailwindcss-language-server",
	}

	local registry = require("mason-registry")

	for _, pkg in ipairs(ensure_installed) do
		if not registry.is_installed(pkg) then
			vim.notify("Mason: instaling " .. pkg, vim.log.levels.INFO)
			registry.get_package(pkg):install()
		end
	end

	registry.update()
end

setup_mason()
map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

setup_treesitter()

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = { default = { "lsp", "path", "buffer" } },
	snippets = {},
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("bashls", {})
vim.lsp.config("vtsls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("clangd", {})
vim.lsp.config("rust-analyzer", {})
vim.lsp.config("tailwindcss", {})
vim.lsp.config("nil_ls", {
	settings = {
		["nil"] = {
			formatting = { command = { "nixfmt" } },
		},
	},
})

do
	-- local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")

	local biome = require("efmls-configs.formatters.biome")

	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")

	local cpplint = require("efmls-configs.linters.cpplint")
	local clangfmt = require("efmls-configs.formatters.clang_format")

	local go_revive = require("efmls-configs.linters.go_revive")
	local gofumpt = require("efmls-configs.formatters.gofumpt")
	local goimports = require("efmls-configs.formatters.goimports")

	local rustfmt = require("efmls-configs.formatters.rustfmt")

	local nixfmt = require("efmls-configs.formatters.nixfmt")
	local statix = require("efmls-configs.linters.statix")

	vim.lsp.config("efm", {
		filetypes = {
			"c",
			"cpp",
			"css",
			"go",
			"html",
			"javascript",
			"javascriptreact",
			"json",
			"jsonc",
			"lua",
			"sh",
			"typescript",
			"typescriptreact",
			"rust",
			"nix",
		},
		init_options = {
			documentFormatting = true,
		},
		settings = {
			languages = {
				c = { clangfmt, cpplint },
				go = { gofumpt, go_revive, goimports },
				cpp = { clangfmt, cpplint },
				css = { biome },
				html = { biome },
				javascript = { biome },
				javascriptreact = { biome },
				json = { biome },
				jsonc = { biome },
				lua = { stylua },
				sh = { shellcheck, shfmt },
				typescript = { biome },
				typescriptreact = { biome },
				rust = { rustfmt },
				nix = { nixfmt, statix },
			},
		},
	})
end

vim.lsp.enable({
	"efm",
	"lua_ls",
	"bashls",
	"vtsls",
	"gopls",
	"clangd",
	"rust-analyzer",
	"tailwindcss",
	"nil_ls",
})

local augroup = vim.api.nvim_create_augroup("lsp", { clear = true })

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	if client:supports_method("textDocument/codeAction", bufnr) then
		map("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

-- Format on save (ONLY real file buffers, ONLY when efm is attached)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = {
		"*.lua",
		"*.py",
		"*.go",
		"*.js",
		"*.jsx",
		"*.ts",
		"*.tsx",
		"*.json",
		"*.css",
		"*.scss",
		"*.html",
		"*.sh",
		"*.bash",
		"*.zsh",
		"*.c",
		"*.cpp",
		"*.h",
		"*.hpp",
		"*.nix",
	},
	callback = function(args)
		-- avoid formatting non-file buffers (helps prevent weird write prompts)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		if not vim.bo[args.buf].modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(args.buf) == "" then
			return
		end

		local has_efm = false
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
			if c.name == "efm" then
				has_efm = true
				break
			end
		end
		if not has_efm then
			return
		end

		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(c)
				return c.name == "efm"
			end,
		})
	end,
})
