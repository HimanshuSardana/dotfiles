return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	config = function()
		require('fzf-lua').setup({ "ivy" })
		require('fzf-lua').register_ui_select()
	end
}
