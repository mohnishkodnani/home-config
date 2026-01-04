{
  config,
  pkgs,
  ...
}: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.monoid
    nerd-fonts.fira-code
    noto-fonts-color-emoji
  ];
}
