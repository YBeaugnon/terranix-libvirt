{config, pkgs, lib,...}: {
  system.stateVersion = "23.11";
  networking.hostName = "minimal_vm";
  users.users.root.password = "";
  environment.defaultPackages = [];
}