return {
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			require("lspconfig").lua_ls.setup({ capabilities = capabilities })
			require("lspconfig").r_language_server.setup({ capabilities = capabilities })
			require("lspconfig").basedpyright.setup({ capabilities = capabilities })
			require("lspconfig").ruff.setup({ capabilities = capabilities })
			require("lspconfig").gopls.setup({ capabilities = capabilities })
			require("lspconfig").tinymist.setup({ capabilities = capabilities, formatterMode = "typstyle" })
			require("lspconfig").matlab_ls.setup({ capabilities = capabilities })
			require("lspconfig").tsserver.setup({
				capabilities = capabilities,
				init_options = {
					preferences = { importModuleSpecifierPreference = "non-relative", quotePreference = "single" },
				},
			})
			require("lspconfig").clangd.setup({
				capabilities = capabilities,
				filetypes = { "c", "cpp", "objc", "objcpp" },
				cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
			})
			require("lspconfig").marksman.setup({ capabilities = capabilities, filetypes = { "markdown" } })
			require("lspconfig").emmet_ls.setup({
				capabilities = capabilities,
				filetypes = {
					"html",
					"css",
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"svelte",
					"vue",
					"astro",
				},
			})
			require("lspconfig").prismals.setup({ capabilities = capabilities, filetypes = { "prisma" } })

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				update_in_insert = false,
				underline = true,
				severity_sort = true,
			})
		end,
	},
}
