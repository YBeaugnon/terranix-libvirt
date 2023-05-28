{ pkgs, config, nixpkgs, system, terranix, ... }:
let
  config-tf = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      ./config.nix
      ../modules
    ];
  };

  inherit (import (nixpkgs + "/nixos/tests/ssh-keys.nix") pkgs)
    snakeOilPrivateKey snakeOilPublicKey;

  terraform = pkgs.terraform.withPlugins (p: [ p.libvirt ]);
in
{
  nodes.server_a = { config, pkgs, ... }: {
    virtualisation.libvirtd.enable = true;
    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [
      snakeOilPublicKey
    ];
  };
  nodes.server_b = { config, pkgs, ... }: {
    virtualisation.libvirtd.enable = true;
    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [
      snakeOilPublicKey
    ];

  };

  nodes.client_a = { config, pkgs, ... }: { };

  testScript = ''
    # Start and wait for all machines
    def setup():
      # start all machines.
      start_all()
      server_a.wait_for_unit("default.target");
      server_b.wait_for_unit("default.target");
      client_a.wait_for_unit("default.target");
      
      # setup client.
      client_a.succeed("ln -s ${config-tf} config.tf.json")
      client_a.succeed("mkdir -p .ssh")
      client_a.succeed("cat ${snakeOilPrivateKey} > .ssh/snakeoil")
    
    with subtest("setup"):
      setup()

    with subtest("testing-provider"):
      client_a.succeed("${terraform}/bin/terraform init")
      client_a.succeed("${terraform}/bin/terraform apply")
  '';
}
