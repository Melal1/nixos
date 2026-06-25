{
  description = "First!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    qmlgolsp.url = "github:cushycush/qml-language-server";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    music-sep = {
      url = "git+file:/home/melal/Dev/projects/cpp/mrem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qml-niri = {
      url = "github:imiric/qml-niri/main";
      inputs.nixpkgs.follows = "nixpkgs";
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
    , zen-browser
    , antigravity-nix
    , music-sep
    , qmlgolsp
    , qml-niri
    }@inputs:
    let
      system = "x86_64-linux";
      overlays = [ (import ./overlays/default.nix) ];

      pkgs = import nixpkgs { inherit system overlays; };
      unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
      quickshell-niri = qml-niri.packages.${system};
      windowManager = "niri";
    in
    {
      nixosConfigurations = {
        alpha = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs quickshell-niri unstable windowManager qmlgolsp;
          };
          modules = [
            { nixpkgs.hostPlatform = system; nixpkgs.overlays = overlays; }
            ./hosts/desktop
            ({ pkgs, ... }:
              let sys = pkgs.stdenv.hostPlatform.system; in {
                environment.systemPackages = [
                  zen-browser.packages.${sys}.default
                  antigravity-nix.packages.${sys}.google-antigravity-cli
                  music-sep.packages.${sys}.default
                ];
              })
          ];
        };

        zeta = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs unstable windowManager;
          };
          modules = [
            { nixpkgs.hostPlatform = system; nixpkgs.overlays = overlays; }
            ./hosts/laptop
            ({ pkgs, ... }:
              let sys = pkgs.stdenv.hostPlatform.system; in {
                environment.systemPackages = [
                  zen-browser.packages.${sys}.default
                ];
              })
          ];
        };
      };

      homeConfigurations = {
        alpha = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit self windowManager;
            hostname = "alpha";
          };
          modules = [
            ./hosts/desktop/home.nix
          ];
        };
        zeta = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit self windowManager;
            hostname = "zeta";
          };
          modules = [
            ./hosts/laptop/home.nix
          ];
        };
      };
      devShells.${system} = import ./modules/nixos/packages/dev/nix-shell/default.nix { inherit pkgs; };
    };
}

