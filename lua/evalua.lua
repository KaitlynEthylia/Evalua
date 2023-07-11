local function getExpr()
	local root = vim.treesitter.get_parser():parse()[1]:root()
	local query = vim.treesitter.query.parse('lua', [[
		(assignment_statement) @evaluable
		(function_declaration) @evaluable
		(function_call) @evaluable
		(unary_expression) @evaluable
		(binary_expression) @evaluable
	]])

	--- @type TSNode[]
	local smallestSoFar = {}
	local smallestDifference

	local row = vim.fn.line('.') - 1
	for _, node in query:iter_matches(root, 0, 0, vim.fn.line('$')) do
		local ranges = { node[1]:range() }
		if ranges[1] <= row and ranges[3] >= row then
			if not smallestDifference or ranges[3] - ranges[1] < smallestDifference then
				smallestSoFar = { node[1] }
				smallestDifference = ranges[3] - ranges[1]
			end
			if ranges[3] - ranges[1] == smallestDifference then
				smallestSoFar[#smallestSoFar + 1] = node[1]
			end
		end
	end

	--- @type TSNode
	local selectedNode
	local selectedDifference

	local col = vim.fn.col('.') - 1
	for _, node in ipairs(smallestSoFar) do
		local ranges = { node:range() }
		ranges[4] = ranges[4] - 1
		if ranges[2] <= col and ranges[4] >= col then
			if not selectedDifference or ranges[4] - ranges[2] < selectedDifference then
				selectedNode = node
				selectedDifference = ranges[4] - ranges[2]
			end
		end
	end

	if not selectedNode then
		selectedNode = root
	end

	local start_row, start_col, end_row, end_col = selectedNode:range()
	if end_col == 0 then
		end_row = end_row - 1
		end_col = #vim.api.nvim_buf_get_lines(0, -2, -1, false)
	end
	return vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
end

local function eval(silent)
	local expr = getExpr()
	local cexpr = table.concat(expr, ' ', 1, #expr)
	if not silent then
		print('Evaluating:')
		print(' ')
		print(cexpr)
		print(' ')
	end
	local ok, ret = pcall(vim.fn.luaeval, cexpr)
	if ok then
		if ret
			and ret ~= vim.NIL
			and not silent
		then
			print(ret)
		end
		return
	end
	local fn = loadstring(cexpr)
	if not fn then
		return
	end
	fn()
end

print('setting up')
vim.api.nvim_create_user_command('Evalua', function(opts)
	local silent = false
	if opts.args == 'silent' then silent = true end
	eval(silent)
end, { desc = "Evaluate the lua expression under the cursor", nargs = '?' })
