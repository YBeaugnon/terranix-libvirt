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

      packages =
        let
          examples = import ./examples {
            inherit pkgs;
            inherit terranix;
            inherit nixos-generators;
            inherit system;
            inherit nixpkgs;
          };
        in
        {
          inherit (examples) local_deployment;
        };
    });
}
