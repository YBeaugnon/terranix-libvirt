{ pkgs, config, nixpkgs, system, terranix, ... }:
let
  config-tf = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      ./config.nix
      ../modules
    ];
  };

  terraform = pkgs.terraform.withPlugins (p: [ p.libvirt ]);
in
{
  nodes.server_a = { config, pkgs, ... }: {
    virtualisation.libvirtd.enable = true;
    services.openssh.enable = true;
    security.polkit.enable = true;
    environment.systemPackages = with pkgs; [ virt-manager ];
  };
  nodes.server_b = { config, pkgs, ... }: {
    virtualisation.libvirtd.enable = true;
    services.openssh.enable = true;
    security.polkit.enable = true;
    environment.systemPackages = with pkgs; [ virt-manager ];
  };

  nodes.client = { config, pkgs, ... }: { };

  testScript = ''
    start_all()


    client.succeed('mkdir -m 700 /root/.ssh')
    client.succeed(
      '${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ""'
    )
    public_key = client.succeed(
      '${pkgs.openssh}/bin/ssh-keygen -y -f /root/.ssh/id_ed25519'
    ).strip()

    client.wait_for_unit("network.target")

    for server in [server_a, server_b]:
      server.succeed('mkdir -m 700 /root/.ssh')
      server.succeed(f'echo "{public_key}" > /root/.ssh/authorized_keys')
      server.wait_for_unit('sshd')
      client.succeed(
        f'ssh -o StrictHostKeyChecking=no {server.name} true'
      )


    client.succeed('cp ${config-tf} config.tf.json')
    client.succeed('${terraform}/bin/terraform init')
    client.succeed('${terraform}/bin/terraform plan')
    client.succeed('${terraform}/bin/terraform apply -auto-approve')
  '';
}
