local opts = { noremap = true, silent = true }
local dap = require("dap")
dap.configurations.scala = {
	{
		type = "scala",
		request = "launch",
		name = "RunOrTest",
		metals = {
			runType = "runOrTestFile",
			--args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
		},
	},
	{
		type = "scala",
		request = "launch",
		name = "Run",
		metals = {
			runType = "run",
			--args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
		},
	},
	{
		type = "scala",
		request = "launch",
		name = "Test Target",
		metals = {
			runType = "testTarget",
		},
	},
}
  -- nvim-dap Keybindings
  vim.api.nvim_set_keymap('n', '<leader>dc', '<cmd>lua require"dap".continue()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<leader>dr', '<cmd>lua require"dap".repl.toggle()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<leader>ds', '<cmd>lua require"dap.ui.variables".scopes()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<leader>dK', '<cmd>lua require"dap.ui.widgets".hover()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<leader>dt', '<cmd>lua require"dap".toggle_breakpoint()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<leader>dso', '<cmd>lua require"dap".step_over()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<leader>dsi', '<cmd>lua require"dap".step_into()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<leader>dl', '<cmd>lua require"dap".run_last()<CR>', opts)

  require("metals").setup_dap()
