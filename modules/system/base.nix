{ ... }:
{
  flake.nixosModules.base =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      options.my.unfree = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };

      config = {
        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
        };
        home-manager.sharedModules = [
          ({ config, ... }: {
            _module.args.repoRoot = "${config.home.homeDirectory}/.dotfiles";
            _module.args.featurePath = "${config.home.homeDirectory}/.dotfiles/modules/features";
            _module.args.link = config.lib.file.mkOutOfStoreSymlink;

            home.file.".XCompose".text = ''
              <dead_acute> <c> : "ç" ccedilla
              <dead_acute> <C> : "Ç" Ccedilla

              include "%L"
            '';
          })
        ];

        nixpkgs.config.allowUnfreePredicate =
          pkg:
          let
            n = lib.getName pkg;
          in
          builtins.elem n config.my.unfree || builtins.elem lib.teams.android (pkg.meta.teams or [ ]);

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
