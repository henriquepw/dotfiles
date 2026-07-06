{
  pkgs,
  config,
  dotfiles,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.packages = [ pkgs.brave ];
  xdg.configFile."brave-flags.conf".source = link "${dotfiles}/brave/brave-flags.conf";
  xdg.configFile."brave-origin-beta-flags.conf".source =
    link "${dotfiles}/brave/brave-origin-beta-flags.conf";

  # Navegador padrão — mimeapps cobre o xdg-open; o kdeglobals cobre o que o
  # KDE resolve por conta própria
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
    };
  };
  programs.plasma.configFile."kdeglobals"."General"."BrowserApplication".value =
    "brave-browser.desktop";
  home.sessionVariables.BROWSER = "brave";
}
