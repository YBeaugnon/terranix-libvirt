{ config, pkgs, lib, ... }: {
  system.stateVersion = "23.11";
  networking.hostName = "vm-test";
  users.users.root.password = "";
  environment.defaultPackages = [ ];
}
