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

			local servers = {
				{ name = "lua_ls",               config = {} },
				{ name = "r_language_server",    config = { capabilities = capabilities } },
				{ name = "basedpyright",         config = { capabilities = capabilities } },
				{ name = "ruff",                 config = { capabilities = capabilities } },
				{ name = "gopls",                config = { capabilities = capabilities } },
				{ name = "tinymist",             config = { capabilities = capabilities, formatterMode = "typstyle" } },
				{ name = "matlab_ls",            config = { capabilities = capabilities } },
				{ name = "bash_language_server", config = { capabilities = capabilities } },
				{ name = "bash_ls",              config = { capabilities = capabilities } },
				{
					name = "tsserver",
					config = {
						capabilities = capabilities,
						init_options = {
							preferences = {
								importModuleSpecifierPreference = "non-relative",
								quotePreference = "single",
							},
						},
					},
				},
				{
					name = "clangd",
					config = {
						capabilities = capabilities,
						filetypes = { "c", "cpp", "objc", "objcpp" },
						cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
					},
				},
				{ name = "marksman", config = { capabilities = capabilities, filetypes = { "markdown" } } },
				{
					name = "emmet_ls",
					config = {
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
					},
				},
				{ name = "prismals", config = { capabilities = capabilities, filetypes = { "prisma" } } },
			}

			for _, server in ipairs(servers) do
				vim.lsp.config(server.name, server.config)
				vim.lsp.enable(server.name)
			end
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
