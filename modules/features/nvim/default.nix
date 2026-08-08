{ ... }:
{
  flake.nixosModules.nvim =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        neovim
        nil
        nixfmt
        statix
        efm-langserver
        tree-sitter
        gcc
      ];

      # nix-ld lets mason's generic dynamically linked binaries run on NixOS
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        openssl
        libgcc
      ];

      environment.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      home-manager.sharedModules = [
        (
          {
            config,
            featurePath,
            link,
            ...
          }:
          {
            xdg.configFile."nvim".source = link "${featurePath}/nvim/config";
          }
        )
      ];
    };
}
