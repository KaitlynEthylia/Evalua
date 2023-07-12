local function getExpr()
	local root = vim.treesitter.get_parser():parse()[1]:root()
	local query = vim.treesitter.query.parse('lua', [[
		((function_declaration) @_l (#match? @_l "^local"))
		((function_declaration) @_g (#not-match? @_g "^local"))

		(block) @state
		(assignment_statement) @state
		(if_statement) @state
		(for_statement) @state
		(while_statement) @state
		(repeat_statement) @state

		(function_call) @expr
		(unary_expression) @expr
		(binary_expression) @expr
	]])

	local smallest = {
		text = nil,
		type = nil,
	}
	for id, node in query:iter_captures(root, 0, vim.fn.line('.') - 1, vim.fn.line('.')) do
		local sr, sc, er, ec = node:range()
		if query.captures[id] == '_l' then sc = sc + 6 end
		local col = vim.fn.col('.') - 1
		if sr ~= er or (sc <= col and ec >= col) then
			local tsize = vim.api.nvim_buf_get_text(0, sr, sc, er, ec, {})
			local size = table.concat(tsize, ' ', 1, #tsize)
			if not smallest.text or #size < #smallest.text then
				smallest.text = size
				smallest.type = query.captures[id]
			end
		end
	end

	if smallest.text == nil then
		local rg = { root:range() }
		if rg[4] == 0 then
			rg[3] = rg[3] - 1
			rg[4] = #vim.api.nvim_buf_get_lines(0, -2, -1, false)
		end
		local ttext = vim.api.nvim_buf_get_text(0, rg[1], rg[2], rg[3], rg[4], {})
		local text = table.concat(ttext, ' ', 1, #ttext)
		smallest = {
			text = text,
			type = 'state',
		}
	end

	return smallest
end

local function eval(args)
	local expr = getExpr()
	local silent = args.args == 'silent'
	if not silent then
		print('Evaluating:\n ')
		print(expr.text)
		print('\n ')
	end
	if expr.type == 'expr' then
		local ret = vim.fn.luaeval(expr.text)
		if not silent and ret ~= vim.NIL then print(ret) end
		return
	end
	local fn = loadstring(expr.text)
	if fn then fn() end
end

vim.api.nvim_create_user_command('Evalua', eval, {
	desc = "Evaluate the lua expression under the cursor",
	nargs = '?',
})
