{ ... }:
{
  flake.nixosModules.ai =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        claude-code
        opencode
      ];

      my.unfree = [ "claude-code" ];
    };
}
