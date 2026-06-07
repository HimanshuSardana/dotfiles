---@diagnostic disable: undefined-global
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.path:append("**")
vim.opt.clipboard = "unnamedplus"
vim.opt.winborder = "bold"
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undofile = true
require('vim._core.ui2').enable()

vim.g.mapleader = " "
vim.cmd.colorscheme("catppuccin")

vim.pack.add({
	"https://github.com/echasnovski/mini.ai",
	"https://github.com/echasnovski/mini.pairs",
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/tpope/vim-fugitive",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/Saghen/blink.cmp",
})

require("mason").setup()
require("oil").setup()
require("mini.ai").setup()
require("mini.pairs").setup()

require("fzf-lua").setup({ "ivy" })

require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
})

require("nvim-treesitter").setup({
	ensure_installed = {
		"lua",
		"python",
		"javascript",
		"typescript",
		"rust",
		"c",
		"cpp",
		"typst",
		"vim",
		"vimdoc",
		"go",
	},

	highlight = {
		enable = true,
	},

	indent = {
		enable = true,
	},
})

vim.lsp.enable({ "basedpyright", "gopls", "lua_ls", "ts_ls" })

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.keymap.set("n", "<Esc>", ":nohl<CR>")
vim.keymap.set("n", "<leader>q", ":bd<CR>")
vim.keymap.set("n", "<leader>fg", ":FzfLua live_grep<CR>")
vim.keymap.set("n", "<leader>ff", function() require("fzf-lua").files() end)
vim.keymap.set("n", "<leader><leader>", function() require("fzf-lua").buffers() end)
vim.keymap.set("n", "<leader>ft", ":Oil<CR>")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("n", "<C-e>", "<C-^>")
vim.keymap.set("n", "<C-\\>", function()
	vim.cmd("enew")
	vim.cmd("terminal")
end)
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
vim.keymap.set("t", "<leader>q", [[<C-\><C-n><cmd>close<CR>]])
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "typst",
	callback = function()
		vim.bo.makeprg = "typst compile %"
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
			buffer = ev.buf,
			callback = function()
				vim.lsp.buf.format({
					bufnr = ev.buf,
					id = client.id,
					timeout_ms = 1000,
				})
			end,
		})
	end,
})

vim.keymap.set("n", "<leader>dg", function()
	vim.diagnostic.setqflist()
	vim.cmd("copen")
end)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>")

vim.keymap.set("n", "<leader>z", function()
	local dirs = vim.fn.systemlist("zoxide query -l")

	vim.ui.input({
		prompt = "Zoxide> ",
	}, function(input)
		if not input or input == "" then
			return
		end

		local matches = vim.fn.matchfuzzy(dirs, input)

		if #matches == 0 then
			print("No match")
			return
		end

		require("oil").open(matches[1])
	end)
end)

vim.keymap.set("n", "<leader>Z", function()
	vim.ui.input({
		prompt = "Zoxide cd> ",
	}, function(input)
		if not input or input == "" then
			return
		end

		local dir = vim.fn.system(
			"zoxide query " .. vim.fn.shellescape(input)
		):gsub("\n", "")

		if dir == "" then
			print("No match")
			return
		end

		vim.cmd.cd(vim.fn.fnameescape(dir))

		require("oil").open(dir)
	end)
end)

require("ai_chat").setup()
