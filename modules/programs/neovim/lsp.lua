  local opts = { noremap = true, silent = true }
  
  vim.o.tabstop = 2
  vim.o.shiftwidth = 2
  vim.bo.softtabstop = 2
  vim.bo.shiftwidth = 2
  vim.o.expandtab = true
  vim.o.number = true
  vim.o.smarttab = true
  vim.opt.shortmess = vim.opt.shortmess + 'c'
  vim.opt.shortmess = vim.opt.shortmess - 'F'
  vim.o.completeopt=menuone,noinsert,noselect
  -- Metals Diagnostics
  vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  -- Attach keybindings 
  -- Diagnostics custom configuration
  local get_diagnostics_options = function()
	  local options = {
		  underline = true,
		  virtual_text = false,
		  signs = true,
		  update_in_insert = false
	  }
	  return vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, options)
  end

  local on_attach = function(client, bufnr)
	vim.lsp.handlers["textDocument/publishDiagnostics"] = get_diagnostics_options()
  	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'v', 'K', '<cmd>lua require("metals").type_of_range()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>cl', '<cmd>lua vim.lsp.codelens.run()<CR>', opts)
  	-- Treeview
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>tt', '<cmd>lua require("metals.tvp").toggle_tree_view()<CR>', opts)
  	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>tr', '<cmd>lua require("metals.tvp").reveal_in_tree()<CR>', opts)
    -- 
--    vim.cmd([[autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()]])
--    vim.cmd([[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]])
--    vim.cmd([[autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()]])

  end
  
  -- Metals LSP
  metals_config = require('metals').bare_config()
  metals_config.settings = {
  	showImplicitArguments = true,
        showImplicitConversionsAndClasses = true,
  	showInferredType = true,
  	excludedPackages = {
  		"akka.actor.typed.javadsl",
  		"com.github.swagger.akka.javadsl"
  	},
  	gradleScript = "./gradlew"
  }
  metals_config.init_options.statusBarProvider = "on"
  metals_config.on_attach = on_attach
  vim.cmd([[augroup lsp]])
  vim.cmd([[au!]])
  vim.cmd([[au FileType scala,sbt,gradle lua require("metals").initialize_or_attach(metals_config)]])
  vim.cmd([[augroup end]])
  -- Language Servers
  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
  local servers = {'java_language_server', 'pylsp'}
  local server_configs = {
	  java_language_server = {
		cmd = {"java-language-server"},
		settings = {
	
		},
	  }
  }
  for _, lsp in pairs(servers) do
	local config = {
		on_attach = on_attach,
		capabilities = capabilities
	}
	if server_configs[lsp] then
		config = vim.tbl_extend('error', config, server_configs[lsp])
	end

  	require('lspconfig')[lsp].setup(config)
  end
