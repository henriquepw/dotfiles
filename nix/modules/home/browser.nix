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
  # XWayland (ozone=x11) para que o Brave respeite o ~/.XCompose (cedilha ç);
  # em Wayland nativo o Chromium ignora o XCompose e digita ć. O --ozone-platform=x11
  # explícito vence o --ozone-platform-hint=auto que o wrapper injeta via NIXOS_OZONE_WL.
  home.packages = [ (pkgs.brave.override { commandLineArgs = [ "--ozone-platform=x11" ]; }) ];
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
  home.sessionVariables = {
    BROWSER = "brave";
    GTK_IM_MODULE = "cedilla";
    QT_IM_MODULE = "cedilla";
  };
}
