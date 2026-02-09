return {
	{ "github/copilot.vim" },
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
		},
		build = "make tiktoken",
		opts = {
			-- model = "gpt-3.5-turbo",
			debug = false,
			show_help = "yes",
			auto_follow_cursor = false,
			prompts = {
				Rename = {
					prompt =
					"Rename the selected variable appropriately, considering the surrounding code context.",
					selection = function(source)
						local select = require("CopilotChat.select")
						return select.visual(source)
					end,
				},
				Commit = {
					prompt =
					"Write a commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
					selection = function(source)
						local select = require("CopilotChat.select")
						return select.gitdiff(source, true)
					end,
				},
				Tests = {
					prompt = "Generate unit tests for the selected code.",
					selection = function(source)
						local select = require("CopilotChat.select")
						return select.visual(source)
					end,
				},
				Paraphrase = {
					prompt =
					"Paraphrase this in a simpler, shorter, easier to understand way, but keep the original meaning.",
					selection = function(source)
						local select = require("CopilotChat.select")
						return select.visual(source)
					end,
				},
				Answer = {
					prompt = "Answer the highlighted question in simple terms.",
					selection = function(source)
						local select = require("CopilotChat.select")
						return select.visual(source)
					end,
				},
				Explain = {
					prompt =
					"Explain what the selected code does. Add the line of codes as markdown code blocks while explaining them.",
					selection = function(source)
						local select = require("CopilotChat.select")
						return select.visual(source)
					end,
				},
				Code = {
					prompt =
					"Given the following code, and its output, paraphrase them, change variable names, general structure and make it seem not copied. Write the appropriate output",
					selection = function(source)
						local select = require("CopilotChat.select")
						return select.visual(source)
					end,
				},
			},
		},
		keys = {
			{ "<leader>cc",  "<cmd>CopilotChat<cr>",         mode = { "n", "v" }, desc = "Copilot Chat" },
			{ "<leader>cce", "<cmd>CopilotChatExplain<cr>",  mode = "v",          desc = "Copilot Chat: Explain" },
			{ "<leader>ccr", "<cmd>CopilotChatReview<cr>",   mode = "v",          desc = "Copilot Chat: Review" },
			{ "<leader>ccf", "<cmd>CopilotChatFix<cr>",      mode = "v",          desc = "Copilot Chat: Fix" },
			{ "<leader>cco", "<cmd>CopilotChatOptimize<cr>", mode = "v",          desc = "Copilot Chat: Optimize" },
			{ "<leader>ccd", "<cmd>CopilotChatDocs<cr>",     mode = "v",          desc = "Copilot Chat: Docs" },
			{ "<leader>cct", "<cmd>CopilotChatTests<cr>",    mode = "v",          desc = "Copilot Chat: Tests" },
			{ "<leader>ccm", "<cmd>CopilotChatCommit<cr>",   mode = "n",          desc = "Copilot Chat: Commit" },
			-- { "<leader>ccp", "<cmd>CopilotChatParaphrase<cr>", mode = "v",          desc = "Copilot Chat: Paraphrase" },
			{ "<leader>cca", "<cmd>CopilotChatAnswer<cr>",   mode = "v",          desc = "Copilot Chat: Answer" },
			{ "<leader>ccp", "<cmd>CopilotChatCode<cr>",     mode = "v",          desc = "Copilot Chat: Code" },
		},
	},
}
