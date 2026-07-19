{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  # Noctalia v5 é o "rosto" da sessão: sobe como user service dentro da sessão
  # Plasma6 existente (kwin_wayland + serviços do Plasma), no lugar do plasmashell.
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    # user service systemd (WantedBy/PartOf/After = config.wayland.systemd.target,
    # que resolve pra graphical-session.target por padrão no HM). Sobe no login sem
    # passo manual, junto com o resto da sessão gráfica.
    systemd.enable = true;
    # settings NÃO é declarado aqui de propósito: o config vive na camada mutável
    # ~/.local/state/noctalia/settings.toml (semeada abaixo, copy-once), que a GUI
    # do Noctalia reescreve livremente. Mesmo modelo do painel do KDE (kde.nix).
  };

  # Paleta custom "Matte Black" (réplica do antigo base16 do stylix — ver
  # git 31f2845). Noctalia lê custom palettes de ~/.config/noctalia/palettes/*.json
  # e NUNCA reescreve os arquivos existentes lá (o único write nesse dir é o
  # "export wallpaper palette", que cria arquivo novo com outro nome). Logo é um
  # artefato de tema puramente declarativo → symlink read-only pro store, ao
  # contrário do settings.toml (mutável pela GUI, copy-once). Seleção da paleta:
  # [theme] source="custom" + custom_palette="matte-black" no settings.toml (seed).
  xdg.configFile."noctalia/palettes/matte-black.json".source =
    ./noctalia/palettes/matte-black.json;

  # Mask do plasmashell — cirúrgico. HM não tem bool "mask"; o symlink → /dev/null
  # em ~/.config/systemd/user (precedência sobre a unit vendorizada) equivale a
  # `systemctl --user mask`. plasma-plasmashell.service é puxado só por
  # WantedBy=plasma-core.target / PartOf=graphical-session.target (relações fracas):
  # nenhuma unit dá Requires nele, então kwin, kglobalaccel, powerdevil (AC "never",
  # garantia do Sunshine) e kscreenlocker seguem intactos.
  # mkOutOfStoreSymlink aponta o symlink pro /dev/null literal sem importar o path
  # (o modo puro do flake proíbe string absoluta "/dev/null" direto no source).
  home.file.".config/systemd/user/plasma-plasmashell.service".source =
    config.lib.file.mkOutOfStoreSymlink "/dev/null";

  # settings.toml do Noctalia é reescrito em runtime (mudanças via GUI persistem lá).
  # Copia uma vez do seed do repo no primeiro login e deixa o Noctalia mutar depois.
  # "Atualizar pelo seed" = recapturar ~/.local/state/noctalia/settings.toml pro repo
  # e apagar o arquivo vivo pra re-semear.
  home.activation.noctalia-settings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _NOCT="$HOME/.local/state/noctalia"
    if [ ! -f "$_NOCT/settings.toml" ]; then
      mkdir -p "$_NOCT"
      cp "${./noctalia/settings.toml}" "$_NOCT/settings.toml"
      chmod 644 "$_NOCT/settings.toml"
    fi
  '';
}
