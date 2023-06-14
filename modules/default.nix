{ ... }: {
  imports = [
    ./domain.nix
    ./network.nix
    ./provisioner.nix
    ./volume.nix
    ./pool.nix
  ];
}
