{ inputs, ... }:
{
  imports = [ inputs.kineticwe.nixosModules.default ];
  programs.kineticwe.enable = true;
}
