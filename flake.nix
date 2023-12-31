{
  nixConfig = {};
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    flake-root.url = "github:srid/flake-root";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
    devour-flake = {
      flake = false;
      url = "github:srid/devour-flake";
    };
  };

  outputs = inputs @ {
    flake-parts,
    flake-utils,
    flake-root,
    treefmt-nix,
    ...
  }: (flake-parts.lib.mkFlake
    {
      inherit inputs;
    }
    {
      imports = [
        treefmt-nix.flakeModule
        flake-root.flakeModule
      ];

      systems = flake-utils.lib.defaultSystems;
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        debug = true;

        treefmt.config = {
          inherit (config.flake-root) projectRootFile;
          programs = {
            alejandra.enable = true;
            deadnix = {
              enable = true;
              no-lambda-arg = true;
              no-lambda-pattern-names = true;
              no-underscore = true;
            };

            rustfmt.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;

            statix.enable = true;
          };
        };

        formatter = config.treefmt.build.wrapper;
        devShells.default = config.treefmt.build.devShell;
        packages.default = config.treefmt.build.devShell;
      };
    });
}
