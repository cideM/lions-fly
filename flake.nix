{
  description = "Simple Go Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            flyctl

            coreutils
            moreutils
            jq

            go
            gopls
            gotools
            graphviz
            golangci-lint
            go-outline
            gopkgs
          ];
        };
      }
    );
}

