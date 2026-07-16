{
  description = "First!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    qmlgolsp = {
      url = "github:cushycush/qml-language-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pi = {
      url = "github:lukasl-dev/pi.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NOTE: local-path input; this flake only evaluates on machines that have
    # /home/melal/Dev/projects/cpp/mrem checked out.
    # music-sep = {
    #   url = "git+file:/home/melal/Dev/projects/cpp/mrem";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    ditto = {
      url = "github:Melal1/ditto";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qml-niri = {
      url = "github:imiric/qml-niri/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , qmlgolsp
    , qml-niri
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      overlays = [ (import ./overlays/default.nix) ];

      pkgs = import nixpkgs { inherit system overlays; };
      unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "pnpm-10.29.2" ];
        };
      };
      quickshell-niri = qml-niri.packages.${system};

      # Per-host settings. Adding a machine = one entry here + a hosts/<name>/ dir.
      hosts = {
        alpha = { windowManager = "niri"; };
        zeta = { windowManager = "niri"; };
      };

      mkHost = name: { windowManager }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs quickshell-niri unstable windowManager qmlgolsp;
          };
          modules = [
            { nixpkgs.hostPlatform = system; nixpkgs.overlays = overlays; }
            (./hosts + "/${name}")
          ];
        };

      mkHome = name: { windowManager }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit self windowManager;
            hostname = name;
          };
          modules = [ (./hosts + "/${name}/home.nix") ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs mkHost hosts;

      # Standalone home-manager (kept separate from nixosConfigurations on purpose)
      homeConfigurations = builtins.mapAttrs mkHome hosts;

      # Custom packages, buildable standalone: nix build .#dwm
      packages.${system} = { inherit (pkgs) dwm dwmblocks-async xwinwrap; };

      devShells.${system} = import ./shells { inherit pkgs; };
    };
}
