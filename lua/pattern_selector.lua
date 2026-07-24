local M = {}

function M.setup(opts)
	opts = opts or {}
end

-- Common patterns to search for.
-- Order matters: patterns earlier in `pattern_order` get first claim on a
-- range of text. Once a range is claimed, later/overlapping patterns are skipped.
local patterns = {
	url_https = "(https?://[%w%.%-/:#%?%&_=]+)",
	url_http = "(http?://[%w%.%-/:#%?%&_=]+)",
	token_pattern = "eyJ[%w%p]+",
	backtick_quoted = "`([^`]+)`",
	uuid = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x",
	address = "0x[0-9a-fA-F]+",
	hex_hash = "%f[%x]%x*%a%x*%f[%X]", -- run of hex digits, must contain at least one a-f letter
	ip = "%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?",
}

-- Order in which patterns are tried. backtick_quoted comes before hex_hash/uuid
-- so a `52bdf1f`-style token gets claimed as a whole rather than double-matched.
local pattern_order = {
	"url_https",
	"url_http",
	"token_pattern",
	"backtick_quoted",
	"uuid",
	"address",
	"hex_hash",
	"ip",
}

-- Minimum length for a bare hex_hash match, to cut down false positives
-- (e.g. avoid matching short incidental hex-looking substrings).
local MIN_HEX_HASH_LEN = 7

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

	for i, line in ipairs(lines) do
		local claimed = {}

		local function is_claimed(s, e)
			for _, r in ipairs(claimed) do
				if s <= r[2] and e >= r[1] then
					return true
				end
			end
			return false
		end

		for _, pattern_name in ipairs(pattern_order) do
			local pattern = patterns[pattern_name]
			for start_pos, match in line:gmatch("()(" .. pattern .. ")") do
				local end_pos = start_pos + #match - 1

				if pattern_name == "hex_hash" and #match < MIN_HEX_HASH_LEN then
					goto continue
				end

				if hint_idx <= #hint_chars and not is_claimed(start_pos, end_pos) then
					local hint_char = hint_chars:sub(hint_idx, hint_idx)
					table.insert(hints, { char = hint_char, match = match, line = i, start_pos = start_pos })
					table.insert(claimed, { start_pos, end_pos })
					api.nvim_buf_add_highlight(bufnr, ns_id, "IncSearch", i - 1, start_pos - 1, end_pos)
					api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, start_pos - 1, {
						virt_text = { { hint_char, "Error" } },
						virt_text_pos = "overlay",
					})
					hint_idx = hint_idx + 1
				end

				::continue::
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
