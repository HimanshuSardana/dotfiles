local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

ls.add_snippets("lua", {
	s("print", {
		t("print("), i(1, '"Hello World"'), t(")"),
	}),
})
