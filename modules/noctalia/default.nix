{
  inputs,
  pkgs,
  config,
  repoRoot,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd.enable = true;
  };

  xdg.configFile."noctalia".source = link "${repoRoot}/modules/noctalia/config";
}
