{
  lib,
  dotfiles,
  ...
}:
{
  # Config de usuário da sessão KineticWE (kwin-we + shell Noctalia). Fica fora
  # do kde.nix porque é transversal às sessões: o Noctalia é o shell do kwin-we,
  # e os keybinds de tiling vão pro kglobalshortcutsrc — o mesmo arquivo que o
  # Plasma usa. (A habilitação da sessão no ly vive em hosts/citadel/kineticwe.nix.)

  # settings.toml do Noctalia é reescrito em runtime (mudanças via GUI persistem
  # lá). Mesmo padrão do painel do KDE: copia uma vez no primeiro login e deixa o
  # Noctalia mutar livremente depois.
  home.activation.noctalia-settings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _NOCT="$HOME/.local/state/noctalia"
    if [ ! -f "$_NOCT/settings.toml" ]; then
      mkdir -p "$_NOCT"
      cp "${dotfiles}/noctalia/settings.toml" "$_NOCT/settings.toml"
      chmod 644 "$_NOCT/settings.toml"
    fi
  '';

  # Keybinds nativos do kwin-we (tiling vim-style) + launcher do Noctalia. O
  # plasma-manager é o único que escreve o kglobalshortcutsrc (compartilhado com
  # o KDE); o Plasma ignora essas ações (não existem no kwin dele) e o kwin-we
  # ignora as do krohnkite. Assim os mesmos binds valem nas duas sessões.
  programs.plasma.shortcuts.kwin = {
    "Noctalia Launcher" = "Meta+Space";
    "Tiling Focus Left" = "Meta+H";
    "Tiling Focus Down" = "Meta+J";
    "Tiling Focus Up" = "Meta+K";
    "Tiling Focus Right" = "Meta+L";
    "Tiling Move Window Previous" = "Meta+Left";
    "Tiling Move Window Next" = "Meta+Right";
    "Tiling Promote To Master" = "Meta+Shift+Space";
    "Tiling Toggle Floating" = "Meta+W";
    "Tiling Cycle Layout" = "Meta+M";
  };
}
