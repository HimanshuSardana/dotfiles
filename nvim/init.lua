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

local makeprg = {
	["*.py"] = "uv run %",
	["*.typ"] = "typst compile %",
	["*.go"] = "go run %",
    ["*.c"] = "gcc % -o %:r && ./%:r",
}

for pattern, cmd in pairs(makeprg) do
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = pattern,
		callback = function()
			vim.bo.makeprg = cmd
		end,
	})
end

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.pack.add({ { src = "https://github.com/ibhagwan/fzf-lua" } })
vim.pack.add({ { src = "https://github.com/nvim-mini/mini.nvim" } })
vim.pack.add({ { src = "https://github.com/stevearc/oil.nvim" } })
vim.pack.add({ { src = "https://github.com/Saghen/blink.cmp" } })
vim.pack.add({ { src = "https://github.com/mason-org/mason.nvim" } })
vim.pack.add({ { src = "https://github.com/neovim/nvim-lspconfig" } })
vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim" } })
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter" } })
vim.pack.add({ { src = "https://github.com/chomosuke/typst-preview.nvim" } })
vim.pack.add({ { src = "https://github.com/tpope/vim-fugitive" } })
vim.pack.add({ { src = "https://github.com/neanias/everforest-nvim" } })
vim.pack.add({ { src = "https://github.com/HakonHarnes/img-clip.nvim" } })

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
require("nvim-treesitter").setup({
	ensure_installed = { "lua", "go", "python", "typst", "vim", "vimdoc", "markdown", "markdown_inline", "bash", "sh" },
	highlight = { enable = true, additional_vim_regex_highlighting = false },
})
require("blink.cmp").setup({ fuzzy = { implementation = "lua" } })
vim.cmd("colorscheme everforest")

vim.keymap.set("n", "<leader>ff", ":FzfLua files<CR>")
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>")
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

vim.lsp.enable({ "lua_ls", "gopls", "basedpyright", "ruff", "tinymist", "typstyle", "gofumpt", "stylua", "bash_ls", "clangd" })
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

vim.keymap
