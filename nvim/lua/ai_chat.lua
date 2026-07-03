local M = {}

M.config = {
	url = "https://opencode.ai/zen/go/v1/chat/completions",
	api_key = os.getenv("OPENCODE_API_KEY"),
	model = "minimax-m2.7",
}

M.messages = {}
M.buf = nil

local function append(lines)
	local out = {}

	for _, line in ipairs(lines) do
		vim.list_extend(out, vim.split(line, "\n"))
	end

	vim.api.nvim_buf_set_lines(
		M.buf,
		-1,
		-1,
		false,
		out
	)
end
local function create_chat_buffer()
	if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
		vim.cmd("botright split")
		vim.api.nvim_win_set_buf(0, M.buf)
		return
	end

	vim.cmd("botright split")

	M.buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_win_set_buf(0, M.buf)

	vim.bo[M.buf].filetype = "markdown"
	vim.bo[M.buf].bufhidden = "wipe"

	append({
		"# Chat",
		"",
		"Write below and press <C-s> to send.",
		"",
		"---",
		"",
	})

	vim.keymap.set("n", "<C-s>", function()
		M.send()
	end, { buffer = M.buf })

	vim.keymap.set("i", "<C-s>", function()
		M.send()
	end, { buffer = M.buf })
end

function M.send()
	local lines = vim.api.nvim_buf_get_lines(M.buf, 0, -1, false)

	local start = nil

	for i = #lines, 1, -1 do
		if lines[i] == "---" then
			start = i + 1
			break
		end
	end

	if not start then
		return
	end

	local input = table.concat(
		vim.list_slice(lines, start, #lines),
		"\n"
	)

	input = vim.trim(input)

	if input == "" then
		return
	end

	table.insert(M.messages, {
		role = "user",
		content = input,
	})

	append({
		"",
		"# You",
		"",
		input,
		"",
		"# AI",
		"",
		"Thinking...",
	})

	local payload = vim.json.encode({
		model = M.config.model,
		messages = M.messages,
		-- max_tokens = 512,
		temperature = 0.7,
	})

	vim.system({
		"curl",
		"-s",
		M.config.url,
		"-H",
		"Content-Type: application/json",
		"-H",
		"Authorization: Bearer " .. M.config.api_key,
		"-d",
		payload,
	}, {
		text = true,
	}, function(obj)
		vim.schedule(function()
			local ok, data = pcall(vim.json.decode, obj.stdout)

			if not ok then
				append({
					"",
					"Failed to decode response",
					obj.stdout,
				})

				return
			end

			local text =
			    data.choices
			    and data.choices[1]
			    and data.choices[1].message
			    and data.choices[1].message.content
			    or "No response"

			table.insert(M.messages, {
				role = "assistant",
				content = text,
			})

			append({
				text,
				"",
				"---",
				"",
			})

			vim.cmd("normal! G")
		end)
	end)
end

function M.open()
	create_chat_buffer()
end

function M.clear()
	M.messages = {}

	if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
		vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, {})
	end
end

function M.setup()
	vim.api.nvim_create_user_command("AIChat", function()
		M.open()
	end, {})

	vim.api.nvim_create_user_command("AIClear", function()
		M.clear()
	end, {})
end

return M
