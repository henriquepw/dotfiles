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
		"efm",
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

-- Incremental selection via Treesitter.
do
	local stack = {}

	local function range_eq(a, b)
		local a1, a2, a3, a4 = a:range()
		local b1, b2, b3, b4 = b:range()
		return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
	end

	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)

	local function select_node(node)
		local sr, sc, er, ec = node:range()
		if ec == 0 and er > 0 then
			er = er - 1
			ec = #vim.fn.getline(er + 1)
		end
		if vim.fn.mode():match("[vV\22]") then
			vim.api.nvim_feedkeys(esc, "nx", false)
		end
		vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
		vim.cmd("normal! v")
		vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
	end

	map({ "n", "x" }, "<C-space>", function()
		if vim.fn.mode() ~= "v" or #stack == 0 then
			local node = vim.treesitter.get_node()
			if not node then
				return
			end
			stack = { node }
			select_node(node)
			return
		end

		local current = stack[#stack]
		local parent = current:parent()
		while parent and range_eq(parent, current) do
			parent = parent:parent()
		end
		if parent then
			table.insert(stack, parent)
			select_node(parent)
		end
	end, { desc = "TS expand selection" })

	map("x", "<BS>", function()
		if #stack > 1 then
			table.remove(stack)
			select_node(stack[#stack])
		end
	end, { desc = "TS shrink selection" })
end

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
