return {
	"stevearc/conform.nvim",
	-- event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				-- javascript = { "prettierd" },
				-- typescript = { "prettierd" },
				-- javascriptreact = { "prettierd" },
				-- typescriptreact = { "prettierd" },
				-- svelte = { "prettierd" },
				css = { "prettierd" },
				html = { "prettierd" },
				-- json = { "prettierd" },
				-- yaml = { "prettierd" },
				-- markdown = { "prettierd" },
				-- graphql = { "prettierd" },
				-- lua = { "stylua" },
				-- python = { "ruff" },
				typst = { "tinymist", "typstyle" },
				-- go = { "gofmt" },
				-- golang = { "gofmt" },
				-- bash = { "beautysh" },
			},

			format_on_save = {
				-- async = true,
				lsp_fallback = true,
				timeout_ms = 500,
			},
		})
	end,
}
