{
  description = "First!";

  inputs = {
    vicinae.url = "github:vicinaehq/vicinae";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    ghostty.url = "github:ghostty-org/ghostty";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ghostty, zen-browser, vicinae }@inputs:
    let
      system = "x86_64-linux";
      overlays = import ./modules/packages/overlays;
      pkgs = import nixpkgs { inherit system overlays; };
      unstable = import nixpkgs-unstable { inherit system overlays; config.allowUnfree = true; };
      windowManager = "hyprland";
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
                ghostty.packages.${system}.default
                zen-browser.packages.${system}.default
                vicinae.packages.${system}.default
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
                ghostty.packages.${system}.default
                zen-browser.packages.${system}.default
              ];
            })
          ];
        };
      };

      homeConfigurations = {
        melal = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit self windowManager;
            hostname = "alpha";
          };
          modules = [
            vicinae.homeManagerModules.default
            ./modules/home
          ];
        };
      };
      devShells.${system} = import ./modules/packages/dev/nix-shell/default.nix { inherit pkgs; };
    };
}

