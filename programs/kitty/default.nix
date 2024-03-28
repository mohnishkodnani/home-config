{config, pkgs, ...}:
{
    programs.kitty = {
      enable = true;
      settings = {
        font_size = 22;
        shell = "${pkgs.fish}/bin/fish --login --interactive";
        editor = "nvim";
        kitty_mod = "cmd";
        enable_layouts = "all";
#        shell_integration = "enabled";
        font_family = "Monoid Nerd Font Mono Retina";
      };
      theme = "Obsidian";
      keybindings = {
        "kitty_mod+|" = "launch --location=vsplit";
      };
    };
}
