{
  description = "A very basic flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    terranix.url = "github:terranix/terranix";
  };
  outputs = { self, flake-utils, nixpkgs, terranix }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      nixos-lib = import (nixpkgs + "/nixos/lib") { };
    in
    {
      formatter = pkgs.nixpkgs-fmt;

      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          (terraform.withPlugins (p: [ p.libvirt ]))
        ];
      };
      packages.integrationsTests = nixos-lib.runTest {
        name = "integration";
        _module.args = { inherit terranix nixpkgs; system = "x86_64-linux"; };
        imports = [ ./tests/integration.nix ];
        hostPkgs = pkgs;
      };

      packages.exampleOutput = terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          ./modules/default.nix
          ./tests/config.nix
        ];
      };
    });
}
