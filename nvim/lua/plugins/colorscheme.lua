return {
	-- {
		-- 	"bluz71/vim-moonfly-colors",
		-- 	name = "moonfly",
		-- 	lazy = false,
		-- 	priority = 1000,
		-- 	config = function()
			-- 		vim.cmd("colorscheme moonfly")
			-- 	end
			-- },
			-- {
				-- 	"scottmckendry/cyberdream.nvim",
				-- 	lazy = false,
				-- 	priority = 1000,
				-- 	config = function()
					-- 		vim.cmd("colorscheme cyberdream")
					-- 	end
					-- }
					-- {
						-- 	"uZer/pywal16.nvim",
						-- 	-- for local dev replace with:
						-- 	-- dir = '~/your/path/pywal16.nvim',
						-- 	config = function()
							-- 		vim.cmd.colorscheme("pywal16")
							-- 	end,
							-- },
							{

								"neanias/everforest-nvim",
								version = false,
								lazy = false,
								priority = 1000, -- make sure to load this before all the other start plugins
								config = function()
									require("everforest").setup()
								end
							}
						}
