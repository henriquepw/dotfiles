{ self, inputs, ... }:
{
  flake.deploy.nodes.bellway = {
    hostname = "10.10.0.1";
    profiles.system = {
      user = "root";
      sshUser = "admin";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.bellway;
      magicRollback = true;
      autoRollback = true;
    };
  };

  perSystem =
    { system, ... }:
    {
      checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;
    };
}
