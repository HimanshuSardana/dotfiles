return {
	{
		"HakonHarnes/img-clip.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
		},
	},
	{
		"nvim-mini/mini.ai",
		version = false,
		config = function()
			require("mini.ai").setup()
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup()
		end,
	},
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"folke/snacks.nvim",
		config = function()
			require("snacks").setup()
		end,
	},
	-- {
	-- 	"MeanderingProgrammer/render-markdown.nvim",
	-- 	config = function()
	-- 		require("render-markdown").setup()
	-- 	end,
	-- },
	{
		"jellydn/quick-code-runner.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			debug = true,
			file_types = {
				javascript = { "bun run" },
				python = { "uv run" },
				go = { "go run" },
				r = { "Rscript" },
			},
		},
		cmd = { "QuickCodeRunner", "QuickCodePad" },
		keys = {
			{
				"<leader>r",
				":QuickCodeRunner<CR>",
				desc = "Quick Code Runner",
				mode = "v",
			},
			{
				"<leader>cp",
				":QuickCodePad<CR>",
				desc = "Quick Code Pad",
			},
		},
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"chomosuke/typst-preview.nvim",
		lazy = false, -- or ft = 'typst'
		version = "1.*",
		opts = {}, -- lazy.nvim will implicitly calls `setup {}`
	},
	{
	  "j-hui/fidget.nvim",
	  opts = {
	  },
	}
}
