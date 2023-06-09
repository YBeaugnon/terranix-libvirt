{
  description = "A very basic flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    terranix.url = "github:terranix/terranix";
    nixos-generators.url = "github:nix-community/nixos-generators";
  };

  outputs = { self, flake-utils, nixpkgs, terranix, nixos-generators, ... }: flake-utils.lib.eachDefaultSystem (system:
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

      packages.example =
        let
          nixos-base = nixos-generators.nixosGenerate {
            inherit system;
            modules = [ ];
            format = "qcow";
          };
          images = { inherit nixos-base; };
        in
        terranix.lib.terranixConfiguration {
          inherit system;
          modules = [
            { _module.args = { inherit images; }; }
            ./modules/default.nix
            ./examples/default.nix
          ];
        };
    });
}
