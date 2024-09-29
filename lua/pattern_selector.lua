local M = {}

function M.setup(opts)
	-- Optional: Handle options here if needed in the future
	opts = opts or {}
end
-- Common patterns to search for
local patterns = {
	url_https = "(https?://[%w%.%-/:#%?%&_=]+)",
	url_http = "(http?://[%w%.%-/:#%?%&_=]+)",
	uuid = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x",
	ip = "%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?",
	address = "0x[0-9a-fA-F]+",
	token_pattern = "eyJ[%w%p]+",
}

-- Common function for finding patterns in the buffer
local function find_patterns_in_buffer()
	local api = vim.api
	local hint_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local ns_id = api.nvim_create_namespace("uuid_highlight")

	local bufnr = api.nvim_get_current_buf()
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local hints = {}
	local hint_idx = 1

	api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

	-- Match patterns in the buffer
	for i, line in ipairs(lines) do
		for pattern_name, pattern in pairs(patterns) do
			for start_pos, match in line:gmatch("()(" .. pattern .. ")") do
				if hint_idx <= #hint_chars then
					local hint_char = hint_chars:sub(hint_idx, hint_idx)
					table.insert(hints, { char = hint_char, match = match, line = i, start_pos = start_pos })
					api.nvim_buf_add_highlight(bufnr, ns_id, "IncSearch", i - 1, start_pos - 1, start_pos + #match - 1)
					api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, start_pos - 1, {
						virt_text = { { hint_char, "Error" } },
						virt_text_pos = "overlay",
					})

					hint_idx = hint_idx + 1
				end
			end
		end
	end

	return hints, ns_id, bufnr
end

-- First function: Copy the matched pattern to the clipboard
function M.FindAndSelectPattern()
	local hints, ns_id, bufnr = find_patterns_in_buffer()

	local function select_hint()
		local char = vim.fn.getcharstr()

		if char == "\27" then -- Escape key
			vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
			return
		end

		for _, hint in ipairs(hints) do
			if hint.char == char then
				vim.fn.setreg("+", hint.match)
				vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
				vim.notify("Copied " .. hint.match, vim.log.levels.INFO, { timeout = 2000 })
				return
			end
		end
	end

	-- Force a screen redraw
	vim.cmd("redraw")

	if #hints > 0 then
		select_hint()
	end
end

-- Second function: Replace the matched pattern with the clipboard content
function M.ReplaceWithClipboard()
	local hints, ns_id, bufnr = find_patterns_in_buffer()
	local clipboard_content = vim.fn.getreg("+") -- Get the current + register

	local function select_hint()
		local char = vim.fn.getcharstr()

		if char == "\27" then -- Escape key
			vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
			return
		end

		for _, hint in ipairs(hints) do
			if hint.char == char then
				-- Replace the matched text with the clipboard content
				vim.api.nvim_buf_set_text(
					bufnr,
					hint.line - 1,
					hint.start_pos - 1,
					hint.line - 1,
					hint.start_pos - 1 + #hint.match,
					{ clipboard_content }
				)
				vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
				vim.notify(
					"Replaced " .. hint.match .. " with clipboard content: " .. clipboard_content,
					vim.log.levels.INFO,
					{ timeout = 2000 }
				)
				return
			end
		end
	end

	-- Force a screen redraw
	vim.cmd("redraw")

	if #hints > 0 then
		select_hint()
	end
end

return M
