{
  description = "First!";

  inputs = {
    vicinae.url = "github:vicinaehq/vicinae";
    nixpkgs25_05.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    ghostty = {
      url = "github:ghostty-org/ghostty";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
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

  outputs = { self, nixpkgs, nixpkgs25_05, nixpkgs-unstable, home-manager, ghostty, zen-browser, vicinae, quickshell }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
      oldshit = import nixpkgs25_05 { inherit system; };
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
            ({ pkgs, oldsht, ... }: {
              environment.systemPackages = [
                ghostty.packages.${system}.default
                zen-browser.packages.${system}.default
                vicinae.packages.${system}.default
                quickshell.packages.${system}.default
                oldshit.clang-tools
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
                vicinae.packages.${system}.default
                oldshit.clang-tools
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
            vicinae.homeManagerModules.default
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
            vicinae.homeManagerModules.default
            ./modules/home
          ];
        };
      };
      devShells.${system} = import ./modules/packages/dev/nix-shell/default.nix { inherit pkgs; };
    };
}

