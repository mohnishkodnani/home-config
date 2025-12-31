
  local opts = { noremap = true, silent = true }

  vim.api.nvim_set_keymap('n', '<space>ff', '<cmd>Telescope find_files<CR>', opts)
  vim.api.nvim_set_keymap('n', '<space>fg', '<cmd>Telescope live_grep<CR>', opts)
  vim.api.nvim_set_keymap('n', '<space>fb', '<cmd>Telescope buffers<CR>', opts)
  vim.api.nvim_set_keymap('n', '<space>fh', '<cmd>Telescope help_tags<CR>', opts)
