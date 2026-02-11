-- GLOBAL OPTIONS
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

-- set termgui colors
vim.opt.termguicolors = true

vim.cmd("set nowrap")

-- FOLDING
require("config.folding")

vim.opt.cursorline = true
vim.opt.showmode = false
vim.opt.swapfile = false
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undodir"
vim.opt.undofile = true
vim.o.winborder = "none"

vim.g.python3_host_prog = "/usr/bin/python3"

-- LAZY
require("config.lazy")

-- KEYBINDS
require("config.keybinds")

-- AUTOCOMMANDS
require("config.autocommands")

-- COPILOT CHAT
vim.api.nvim_set_hl(0, "CopilotChatHeader", { fg = "#7C3AED", bold = true })
vim.api.nvim_set_hl(0, "CopilotChatSeparator", { fg = "#374151" })

-- SNIPPETS
require("snippets")

vim.cmd("colorscheme everforest")

-- Treat MATLAB files as Octave files
vim.filetype.add({
	extension = {
		m = "octave",
	},
})

-- set background transparent
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
