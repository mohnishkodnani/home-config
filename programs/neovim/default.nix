{ config, pkgs, ...}:

let
  lspConfig = builtins.readFile ./lsp.lua;
  telescopeConfig = builtins.readFile ./telescope.lua;

  cmpConfig = builtins.readFile ./cmp.lua;
  treesitter = builtins.readFile ./treesitter.lua;
  dapConfig = builtins.readFile ./dap.lua;
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    # TODO: Add back cmpConfig  right now its causing the commands like MetalsImport to not autocomplete for some reason.
    extraConfig = 
#      lspConfig + telescopeConfig + treesitter + dapConfig + cmpConfig 
    ''
      luafile ${builtins.toString ./lsp.lua}
      luafile ${builtins.toString ./cmp.lua}
    ''
    ;
    plugins = with pkgs.vimPlugins; [
      vim-nix                   # nix highlighting
      vim-surround              # edit surrounding characters
      telescope-nvim            # Fuzzy Finder
      telescope-fzf-native-nvim
      nvim-dap                  # debug protocol
      nvim-dap-ui               # debug UI
      nvim-lspconfig            # Language Server Protocol
      nvim-metals               # Metals Scala Plugin
      plenary-nvim
      nvim-treesitter           # Treesitter plugin for highlighting parsing.
      nvim-cmp                  # Completion
      cmp-buffer                # buffer source for nvim-cmp
      cmp-nvim-lsp              # lsp source for nvim-cmp
      cmp-path                  # filesystem source for nvim-cmp
      cmp-spell                 # spelling source for nvim-cmp
      cmp-treesitter            # tree sitter source for nvim-cmp
      cmp-nvim-lua              # lua source for nvim-cmp
      vim-vsnip
      vim-fugitive
      vim-airline               # beautify statusbar
    ];
  };
}
