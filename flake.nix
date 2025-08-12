{
  description = "First!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    ghostty.url = "github:ghostty-org/ghostty";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ghostty, zen-browser }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        alpha = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [
            ./hosts/desktop
          ];
        };
        zeta = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [
            ./hosts/laptop
            ({ pkgs, ... }: {
              environment.systemPackages = [
                ghostty.packages.${system}.default # Install Ghostty
                zen-browser.packages.${system}.default
              ];
            })
          ];
        };
      };

      homeConfigurations = {
        melal = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./modules/home ];
        };
      };
    };
}
