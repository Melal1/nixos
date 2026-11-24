{
  description = "First!";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    discord-tmp.url = "github:NixOS/nixpkgs/nixos-unstable";
    toofan = {
      url = "github:vyrx-dev/toofan";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rea-flake = {
      url = "github:Fractal-Tess/rea-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    serein = {
      url = "github:ViceVerse-cz/Serein";
      # Serein's locked dependencies require a newer Rust than stable provides.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    tincan-cli = {
      url = "github:bilalyazicioglu/tincan-cli/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    skwd-wall = {
      url = "github:liixini/skwd-wall/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium-flake = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./flake/hosts.nix
        ./flake/checks.nix
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = { system, pkgs, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ (import ./overlays/default.nix) ];
        };

        packages.easydotnet = pkgs.easydotnet;
        devShells = import ./shells { inherit pkgs; };
        treefmt = {
          imports = [ ./treefmt.nix ];
          flakeCheck = false;
        };
      };
    };
}
