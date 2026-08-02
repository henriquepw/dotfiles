{ ... }:
{
  flake.nixosModules.keyd =
    { ... }:
    {
      # Meta+c/v/x/a/z → Ctrl/Shift+Insert universal
      services.keyd = {
        enable = true;
        keyboards.default = {
          ids = [ "*" ];
          settings.meta = {
            c = "C-insert";
            v = "S-insert";
            x = "C-x";
            a = "C-a";
            z = "C-z";
          };
        };
      };
    };
}
