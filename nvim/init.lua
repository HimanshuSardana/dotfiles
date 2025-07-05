-- GLOBAL OPTIONS
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.cmd("set nowrap")

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- LAZY
require("config.lazy")

-- KEYBINDS
require("config.keybinds")

-- AUTOCOMMANDS
require("config.autocommands")
