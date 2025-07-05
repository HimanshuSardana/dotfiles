return {
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },

		opts = {
			servers = {
				lua_ls = {},
				clangd = {},
				biome = {},
				tinymist = {},
				tsserver = {},
				prismals = {},
				tailwindcss = {},
				emmet_ls = {},
				gopls = {},
				astro = {},
			},
		},
		config = function(_, opts)
			local lspconfig = require("lspconfig")
			require("lspconfig").lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" }, -- Recognize 'vim' as a global variable
						},
					},
				},
			})

			-- LSP keymaps
			local on_attach = function(_, bufnr)
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				map("n", "gd", vim.lsp.buf.definition, "[LSP] Go to Definition")
				map("n", "gD", vim.lsp.buf.declaration, "[LSP] Go to Declaration")
				map("n", "gr", vim.lsp.buf.references, "[LSP] References")
				map("n", "gi", vim.lsp.buf.implementation, "[LSP] Go to Implementation")
				map("n", "K", vim.lsp.buf.hover, "[LSP] Hover Doc")
				map("n", "<leader>rn", vim.lsp.buf.rename, "[LSP] Rename")
				map("n", "<leader>ca", vim.lsp.buf.code_action, "[LSP] Code Action")
				map("n", "<leader>e", vim.diagnostic.open_float, "[LSP] Show Diagnostics")
				map("n", "[d", vim.diagnostic.goto_prev, "[LSP] Prev Diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "[LSP] Next Diagnostic")
			end

			for server, config in pairs(opts.servers) do
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
				config.on_attach = on_attach -- 💡 Attach keymaps per buffer
				lspconfig[server].setup(config)
			end

			-- Global diagnostic display settings
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					spacing = 4,
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})
		end,
	},
}
