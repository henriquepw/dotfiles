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

        gopls
        revive
        gofumpt
        gotools # goimports

        tectonic

        bash-language-server
        shellcheck
        shfmt

        rust-analyzer

        clang-tools # clangd, clang-format
        cpplint

        lua-language-server
        stylua

        biome
        vtsls
        tailwindcss-language-server

        mermaid-cli # mmdc
      ];

      # nix-ld lets generic dynamically linked binaries run on NixOS
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
