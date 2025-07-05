return {
	-- {
	-- 	"catppuccin/nvim",
	-- 	name = "catppuccin",
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.cmd.colorscheme("catppuccin")
	-- 	end,
	-- },
	"AlphaTechnolog/pywal.nvim",
	config = function()
		require("pywal").setup()
		vim.cmd("colorscheme pywal")
	end,
}
