{
  config,
  pkgs,
  ...
}: {
  fonts.fontconfig.enable = false;
  home.packages = with pkgs.nerd-fonts; [
    monoid
    fira-code
  ];
}
