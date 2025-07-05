return {
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets", "echasnovski/mini.icons", "giuxtaposition/blink-cmp-copilot" },
		version = "1.*",
		opts = {
			keymap = { preset = "enter" },
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = { auto_show = true },
				signature = { enabled = true },
				menu = {
					draw = {
						treesitter = { "lsp" },
						columns = { { "kind_icon" }, { "label", gap = 1 } },
						components = {
							label = {
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
						},
						-- components = {
						-- 	kind_icon = {
						-- 		text = function(ctx)
						-- 			local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
						-- 			return kind_icon
						-- 		end,
						-- 		-- (optional) use highlights from mini.icons
						-- 		highlight = function(ctx)
						-- 			local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
						-- 			return hl
						-- 		end,
						-- 	},
						-- 	kind = {
						-- 		-- (optional) use highlights from mini.icons
						-- 		highlight = function(ctx)
						-- 			local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
						-- 			return hl
						-- 		end,
						-- 	},
						-- },
					},
				},
				keyword = { range = "prefix" },
				trigger = { show_on_trigger_character = true },
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			providers = {},

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
			-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
			--
			-- See the fuzzy documentation for more information
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},
	{
		"xzbdmw/colorful-menu.nvim",
		config = function()
			require("colorful-menu").setup()
		end,
	},
}
