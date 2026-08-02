{ ... }:
{
  flake.nixosModules.base =
    { lib, config, ... }:
    {
      options.my.unfree = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };

      config = {
        home-manager.sharedModules = [
          ({ config, ... }: {
            _module.args.repoRoot = "${config.home.homeDirectory}/.dotfiles";
            _module.args.featurePath = "${config.home.homeDirectory}/.dotfiles/dendritic/features";
            _module.args.link = config.lib.file.mkOutOfStoreSymlink;
          })
        ];

        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.my.unfree;

        programs.zsh.enable = true;

        time.timeZone = "America/Sao_Paulo";
        services.timesyncd.enable = true;

        i18n = {
          defaultLocale = "en_US.UTF-8";
          extraLocaleSettings = {
            LC_CTYPE = "pt_BR.UTF-8";
            LC_TIME = "pt_BR.UTF-8";
            LC_NUMERIC = "pt_BR.UTF-8";
            LC_MONETARY = "pt_BR.UTF-8";
            LC_PAPER = "pt_BR.UTF-8";
            LC_NAME = "pt_BR.UTF-8";
            LC_ADDRESS = "pt_BR.UTF-8";
            LC_TELEPHONE = "pt_BR.UTF-8";
            LC_MEASUREMENT = "pt_BR.UTF-8";
          };
        };

        nix = {
          settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            auto-optimise-store = true;
          };
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
          };
        };
      };
    };
}
