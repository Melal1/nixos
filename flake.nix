{
  description = "First!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, zen-browser, quickshell }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
      windowManager = "dwm";
    in
    {
      nixosConfigurations = {
        alpha = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs unstable windowManager;
          };
          inherit system;
          modules = [
            ./hosts/desktop
            ({ pkgs, ... }: {
              environment.systemPackages = [
                zen-browser.packages.${system}.default
                quickshell.packages.${system}.default
              ];
            })
          ];
        };

        zeta = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs unstable windowManager;
          };
          inherit system;
          modules = [
            ./hosts/laptop
            ({ pkgs, ... }: {
              environment.systemPackages = [
                zen-browser.packages.${system}.default
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
            ./modules/home
          ];
        };
        zeta = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit self windowManager;
            hostname = "zeta";
          };
          modules = [
            ./modules/home
          ];
        };
      };
      devShells.${system} = import ./modules/packages/dev/nix-shell/default.nix { inherit pkgs; };
    };
}

