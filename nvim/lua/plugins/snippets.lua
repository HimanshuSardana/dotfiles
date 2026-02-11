return {
	"L3MON4D3/LuaSnip",
	version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	build = "make install_jsregexp",
	config = function()
		local ls = require("luasnip")
		vim.keymap.set({ "i" }, "<C-y>", function() ls.expand() end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<Tab>", function() ls.jump(1) end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<S-Tab>", function() ls.jump(-1) end, { silent = true })
	end
}
