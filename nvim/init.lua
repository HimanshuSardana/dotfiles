---@diagnostic disable: undefined-global
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.swapfile = false
vim.o.clipboard = "unnamedplus"
vim.o.undofile = true
vim.o.wrap = false
vim.o.winborder = "single"
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.smartcase = true
vim.o.scrolloff = 8
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 99
vim.o.foldenable = true
vim.o.foldcolumn = "1"
vim.g.mapleader = " "

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = '.typ',
		callback = function()
			vim.bo.makeprg = "typst compile %"
		end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.pack.add({
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/nvim-mini/mini.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/Saghen/blink.cmp" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/chomosuke/typst-preview.nvim" },
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/neanias/everforest-nvim" },
  { src = "https://github.com/HakonHarnes/img-clip.nvim" },
  { src = "https://github.com/jim-at-jibba/nvim-redraft" },
  -- { src = "https://github.com/zbirenbaum/copilot.lua" },
  -- { src = "https://github.com/github/copilot.vim" },
})

-- require("copilot").setup({
-- 		-- suggestion = { enabled = true },
-- 		-- panel = { enabled = true},
-- })

require("fzf-lua").setup({ "ivy", previewer = true })
require("fzf-lua").register_ui_select()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.statusline").setup()
require("mini.icons").setup()
require("mini.ai").setup()
require("oil").setup()
require("mason").setup()
require("img-clip").setup()
require("blink.cmp").setup({ fuzzy = { implementation = "lua" } })
vim.cmd("colorscheme everforest")
require('nvim-treesitter').install {"lua", "go", "python", "typst", "vim", "vimdoc", "markdown", "markdown_inline", "bash", "sh" }
require("nvim-redraft").setup({
  llm = {
    provider = "copilot",  -- "openai", "anthropic", "xai", "copilot", "openrouter", or "cerebras"
  },
})

vim.api.nvim_create_autocmd( 'FileType', { pattern = 'go',
callback = function(ev)
				vim.treesitter.start(ev.buf, 'go')
				vim.bo[ev.buf].syntax = 'ON'  -- only if additional legacy syntax is needed
		end
})


vim.keymap.set("n", "<leader>ff", ":FzfLua files<CR>")
vim.keymap.set("n", "<C-e>", "<C-^>", { silent = true })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
vim.keymap.set("n", "<leader>fg", ":FzfLua live_grep<CR>")
vim.keymap.set("n", "<leader>ft", ":Oil<CR>")
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Show line diagnostic" })
vim.keymap.set("n", "<leader><space>", ":FzfLua buffers<CR>")
vim.keymap.set("n", "]b", ":bnext<CR>")
vim.keymap.set("n", "[b", ":bprevious<CR>")
vim.keymap.set("n", "gs", ":Git<CR>")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<cr>")

vim.lsp.enable({ "lua_ls", "gopls", "basedpyright", "ruff", "tinymist", "typstyle", "gofumpt", "stylua", "bash_ls", "clangd", "emmet_ls", "ts_ls" })
require("conform").setup({
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		typst = { "typstyle" },
		python = { "ruff" },
		lua = { "stylua" },
		go = { "gofumpt" },
		typscript = { "prettierd" },
		javascript = { "prettierd" },
		html = { "prettierd" },
		css = { "prettierd" },
	},
})

-- code below this line doesn't count
vim.api.nvim_create_user_command("LspInfo", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	print(#clients == 0 and "No LSP clients attached"
		or "LSP: " .. table.concat(vim.tbl_map(function(c) return c.name end, clients), ", "))
end, {})

vim.api.nvim_create_user_command("TypstWatch", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)

  if file == "" then
    print("No file name for current buffer")
    return
  end

  if vim.b[bufnr].typst_watch_job then
    print("Typst watch already running for this buffer")
    return
  end

  local job_id = vim.fn.jobstart({ "typst", "watch", file }, {
    detach = false,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        print(table.concat(data, "\n"))
      end
    end,
    on_stderr = function(_, data)
      if data then
        print(table.concat(data, "\n"))
      end
    end,
  })

  if job_id <= 0 then
    print("Failed to start typst watch")
    return
  end

  vim.b[bufnr].typst_watch_job = job_id
  print("Started typst watch for " .. file)

  vim.api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
    buffer = bufnr,
    once = true,
    callback = function()
      if vim.b[bufnr].typst_watch_job then
        vim.fn.jobstop(vim.b[bufnr].typst_watch_job)
        print("Stopped typst watch for " .. file)
      end
    end,
  })
end, {})

local term_buf = nil
local term_win = nil

function ToggleTerminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
    term_win = nil
    return
  end
  -- vim.cmd("botright split | terminal")
  vim.cmd("terminal")
  term_win = vim.api.nvim_get_current_win()
  term_buf = vim.api.nvim_get_current_buf()
  vim.cmd("stopinsert")
end

vim.keymap.set("n", "<C-\\>", ToggleTerminal)
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>")

require('vim._core.ui2').enable({ enable = true })

