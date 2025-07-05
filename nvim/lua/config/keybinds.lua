-- QoL
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

-- Oil.nvim
vim.keymap.set("n", "<leader>ft", require("oil").open)

-- fzf-lua
vim.keymap.set("n", "<leader>ff", require("fzf-lua").files)
vim.keymap.set("n", "<leader><leader>", require("fzf-lua").buffers)
vim.keymap.set("n", "<leader>fc", function()
	local config_dir = vim.fn.stdpath("config")
	require("fzf-lua").files({ cwd = config_dir })
end, { desc = "[F]ind [C]onfig" })
vim.keymap.set("n", "<leader>fg", require("fzf-lua").live_grep, { desc = "[F]ind [G]rep" })

-- RUN CODE
function run_current_file()
	local ft = vim.bo.filetype
	local filename = vim.fn.expand("%:p") -- full path to current file

	if vim.bo.modified then
		vim.cmd("write") -- save before running
	end

	local cmd

	if ft == "python" then
		cmd = "python3 " .. filename
	elseif ft == "lua" then
		cmd = "lua " .. filename
	elseif ft == "javascript" then
		cmd = "node " .. filename
	elseif ft == "sh" then
		cmd = "bash " .. filename
	elseif ft == "r" then
		cmd = "Rscript " .. filename
	elseif ft == "go" then
		cmd = "go run " .. filename
	elseif ft == "c" then
		local base_name = vim.fn.expand("%:r") -- filename without extension
		cmd = string.format("gcc %s -o %s && ./%s", filename, base_name, base_name)
	elseif ft == "cpp" then
		local base_name = vim.fn.expand("%:r") -- filename without extension
		cmd = string.format("g++ %s -o %s && %s", filename, base_name, base_name)
	else
		vim.notify("Unsupported filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	-- Open a vertical split and run the command in a terminal
	vim.cmd("rightbelow vsplit")
	vim.cmd("terminal " .. cmd)
	-- vim.cmd("startinsert") -- jump into insert mode in terminal
end

vim.keymap.set("n", "<leader>rc", function()
	run_current_file()
end, { desc = "Run current file in vertical terminal" })
