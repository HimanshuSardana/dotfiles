return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		previewer = true,
	},
	config = function()
		require("fzf-lua").setup({ "ivy", previewer = true })
		require("fzf-lua").register_ui_select()
	end,
}
