vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
		build = ":TSUpdate",
	},
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/creativenull/efmls-configs-nvim",
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

setup_treesitter()

-- incremental selection via treesitter
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
			-- range ends at column 0 of next line; back up to end of previous line
			er = er - 1
			ec = #vim.fn.getline(er + 1)
		end
		-- leave any current visual selection so `v` starts a fresh one instead of toggling it off
		if vim.fn.mode():match("[vV\22]") then
			vim.api.nvim_feedkeys(esc, "nx", false)
		end
		vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
		vim.cmd("normal! v")
		vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
	end

	map({ "n", "x" }, "<C-space>", function()
		if vim.fn.mode() ~= "v" or #stack == 0 then
			-- start selection from the node under the cursor
			local node = vim.treesitter.get_node()
			if not node then
				return
			end
			stack = { node }
			select_node(node)
			return
		end

		-- expand to the smallest ancestor that covers a bigger range
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
do
	local inlay_hints = {
		parameterNames = { enabled = "literals" },
		parameterTypes = { enabled = true },
		variableTypes = { enabled = true },
		propertyDeclarationTypes = { enabled = true },
		functionLikeReturnTypes = { enabled = true },
		enumMemberValues = { enabled = true },
	}
	vim.lsp.config("vtsls", {
		settings = {
			typescript = { inlayHints = inlay_hints },
			javascript = { inlayHints = inlay_hints },
		},
	})
end
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

	local taplo = require("efmls-configs.formatters.taplo")

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
			"toml",
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
				toml = { taplo },
			},
		},
	})
end

-- oxlint/oxfmt: only attach in repos configured for them (standalone config or a Vite+
-- `lint`/`fmt` block in vite.config.*); there oxfmt takes over formatting from biome
do
	local vite_configs = {
		"vite.config.ts",
		"vite.config.mts",
		"vite.config.cts",
		"vite.config.js",
		"vite.config.mjs",
		"vite.config.cjs",
	}

	local function has_vite_plus_block(file, key)
		local ok, lines = pcall(vim.fn.readfile, file)
		if not ok then
			return false
		end
		local content = "\n" .. table.concat(lines, "\n")
		return content:find("vite%-plus") ~= nil and content:find("\n%s*" .. key .. "%s*:") ~= nil
	end

	local function ox_root_dir(markers, key)
		return function(bufnr, on_dir)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			if fname == "" then
				return
			end
			local found = vim.fs.find(function(name, path)
				if vim.list_contains(markers, name) then
					return true
				end
				return vim.list_contains(vite_configs, name) and has_vite_plus_block(vim.fs.joinpath(path, name), key)
			end, { path = vim.fs.dirname(fname), upward = true, limit = 1 })[1]
			if found then
				on_dir(vim.fs.dirname(found))
			end
		end
	end

	-- resolve project-local binaries (npm/pnpm .bin or bun's isolated store), walking up for
	-- monorepos; mirror the env `vp lint`/`vp fmt` set: Vite+ configs are only read when
	-- VP_VERSION is set, and type-aware linting needs OXLINT_TSGOLINT_PATH
	local function ox_cmd(bin)
		return function(dispatchers, config)
			local root = config.root_dir
			local dirs = { root }
			for dir in vim.fs.parents(root) do
				table.insert(dirs, dir)
			end

			local function find_local(rels)
				for _, dir in ipairs(dirs) do
					for _, rel in ipairs(rels) do
						local candidate = vim.fs.joinpath(dir, "node_modules", rel)
						if vim.fn.executable(candidate) == 1 then
							return candidate
						end
					end
				end
			end

			local env = {}
			for _, dir in ipairs(dirs) do
				local ok, pkg = pcall(function()
					local file = vim.fs.joinpath(dir, "node_modules", "vite-plus", "package.json")
					return vim.json.decode(table.concat(vim.fn.readfile(file), "\n"))
				end)
				if ok then
					env.VP_VERSION = pkg.version
					break
				end
			end
			if bin == "oxlint" then
				env.OXLINT_TSGOLINT_PATH = find_local({
					".bin/tsgolint",
					"oxlint-tsgolint/bin/tsgolint.js",
					".bun/node_modules/oxlint-tsgolint/bin/tsgolint.js",
				})
			end

			local exe = find_local({ ".bin/" .. bin, ".bun/node_modules/" .. bin .. "/bin/" .. bin }) or bin
			return vim.lsp.rpc.start({ exe, "--lsp" }, dispatchers, { cwd = root, env = env })
		end
	end

	vim.lsp.config("oxlint", {
		cmd = ox_cmd("oxlint"),
		root_dir = ox_root_dir({ ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }, "lint"),
		settings = { disableNestedConfig = true },
	})
	vim.lsp.config("oxfmt", {
		cmd = ox_cmd("oxfmt"),
		root_dir = ox_root_dir({ ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }, "fmt"),
	})
end

vim.lsp.enable({
	"oxlint",
	"oxfmt",
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

-- Format on save (only real file buffers); prefer oxfmt, then efm, fall back to any LSP that can format
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
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

		local clients = vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/formatting" })
		if #clients == 0 then
			return
		end

		local preferred = vim.iter({ "oxfmt", "efm" }):find(function(name)
			return vim.iter(clients):any(function(c)
				return c.name == name
			end)
		end)

		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(c)
				return not preferred or c.name == preferred
			end,
		})
	end,
})
