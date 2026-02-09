-- SOURCE: https://www.reddit.com/r/neovim/comments/1le6l6x/add_decoration_to_the_folded_lines/
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 0
vim.opt.foldlevelstart = 99
local folded_ns = vim.api.nvim_create_namespace('user.folded')

local marked_curline = {}
local function clear_curline_mark(buf)
	local lnum = marked_curline[buf]
	if lnum then
		vim.api.nvim_buf_clear_namespace(buf, folded_ns, lnum - 1, lnum)
		marked_curline[buf] = nil
	end
end

local function cursorline_folded(win, buf)
	if not vim.wo[win].cursorline then
		clear_curline_mark(buf)
		return
	end

	local curline = vim.api.nvim_win_get_cursor(win)[1]
	local lnum = marked_curline[buf]
	local foldstart = vim.fn.foldclosed(curline)
	if foldstart == -1 then
		clear_curline_mark(buf)
		return
	end

	local foldend = vim.fn.foldclosedend(curline)
	if lnum then
		if foldstart > lnum or foldend < lnum then
			clear_curline_mark(buf)
		end
	else
		vim.api.nvim_buf_set_extmark(buf, folded_ns, foldstart - 1, 0, {
			-- this is not working with ephemeral for some reason
			line_hl_group = 'CursorLine',
			hl_mode = 'combine',
			-- ephemeral = true,
		})
		marked_curline[buf] = foldstart
	end
end

-- optional
vim.api.nvim_create_autocmd('ColorScheme', {
	group = vim.api.nvim_create_augroup('bold_highlight', {}),
	callback = function()
		vim.api.nvim_set_hl(0, 'Bold', { bold = true })
	end,
})

local folded_segments = {}
local function render_folded_segments(win, buf, foldstart)
	local foldend = vim.fn.foldclosedend(foldstart)

	local virt_text = {}
	for _, call in ipairs(folded_segments) do
		local chunks = call(buf, foldstart, foldend)
		if chunks then
			vim.list_extend(virt_text, chunks)
		end
	end

	if vim.tbl_isempty(virt_text) then
		return
	end

	local text =
	    vim.api.nvim_buf_get_lines(buf, foldstart - 1, foldstart, false)[1]:match('^(.-)%s*$')
	local wininfo = vim.fn.getwininfo(win)[1]
	local leftcol = wininfo and wininfo.leftcol or 0
	local padding = 3
	local wincol = math.max(0, vim.fn.virtcol({ foldstart, text:len() }) - leftcol)

	vim.api.nvim_buf_set_extmark(buf, folded_ns, foldstart - 1, 0, {
		virt_text = virt_text,
		virt_text_pos = 'overlay',
		virt_text_win_col = padding + wincol,
		hl_mode = 'combine',
		ephemeral = true,
		priority = 0,
	})

	return foldend
end

local function folded_win_decorator(win, buf, topline, botline)
	cursorline_folded(win, buf)

	local line = topline
	while line <= botline do
		local foldstart = vim.fn.foldclosed(line)
		if foldstart ~= -1 then
			line = render_folded_segments(win, buf, foldstart)
		end
		line = line + 1
	end
end

table.insert(folded_segments, function(_, foldstart, foldend)
	return {
		{ ' 󰘕 ' .. (foldend - foldstart) .. ' ', { 'Bold', 'MoreMsg' } },
	}
end)


table.insert(folded_segments, function(buf, foldstart, foldend)
	if not vim.o.hlsearch or vim.v.hlsearch == 0 then
		return
	end

	local sucess, matches = pcall(vim.fn.matchbufline, buf, vim.fn.getreg('/'), foldstart, foldend)
	if not sucess then
		return
	end

	local searchcount = #matches
	if searchcount > 0 then
		return { { ' ' .. searchcount .. ' ', { 'Bold', 'Question' } } }
	end
end)

local diag_icons = {
	[vim.diagnostic.severity.ERROR] = '󰅙',
	[vim.diagnostic.severity.WARN] = '',
	[vim.diagnostic.severity.INFO] = '',
	[vim.diagnostic.severity.HINT] = '󱠃',
}
local diag_hls = {
	[vim.diagnostic.severity.ERROR] = 'DiagnosticError',
	[vim.diagnostic.severity.WARN] = 'DiagnosticWarn',
	[vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
	[vim.diagnostic.severity.HINT] = 'DiagnosticHint',
}
table.insert(folded_segments, function(buf, foldstart, foldend)
	local diag_counts = {}
	for lnum = foldstart - 1, foldend - 1 do
		for severity, value in pairs(vim.diagnostic.count(buf, { lnum = lnum })) do
			diag_counts[severity] = value + (diag_counts[severity] or 0)
		end
	end

	local chunks = {}
	for severity = vim.diagnostic.severity.ERROR, vim.diagnostic.severity.HINT do
		if diag_counts[severity] then
			table.insert(chunks, {
				string.format('%s %d ', diag_icons[severity], diag_counts[severity]),
				{ 'Bold', diag_hls[severity] },
			})
		end
	end

	return chunks
end)

vim.opt.fillchars:append({
	-- fold = '─' -- horizontal line
	fold = ' ' -- just show nothing
})

vim.api.nvim_set_decoration_provider(folded_ns, {
	on_win = function(_, win, buf, topline, botline)
		vim.api.nvim_win_call(win, function()
			folded_win_decorator(win, buf, topline, botline)
		end)
	end,
})
