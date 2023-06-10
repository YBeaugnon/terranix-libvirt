{ nixpkgs, pkgs, terranix, nixos-generators, system, ... }: with pkgs; let
  nixos-base = nixos-generators.nixosGenerate {
    inherit system;
    modules = [
      "${nixpkgs}/nixos/modules/profiles/minimal.nix"
      ./config.nix
    ];
    format = "qcow";
  };
  images = { inherit nixos-base; };
in
{
  local_deployment = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [
      ../modules
      ./infra.nix
      { _module.args = { inherit images; }; }
    ];
  };
}
