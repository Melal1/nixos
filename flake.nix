{
  description = "First!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";

    };
#    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  #outputs = { self, nixpkgs, home-manager,nixpkgs-unstable }@inputs: {
  outputs = { self, nixpkgs, home-manager}@inputs: {
    nixosConfigurations = {
      alpha = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [ 
          ./configuration.nix
          ./hosts/desktop
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit inputs; };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.melal = import ./modules/home.nix ;
            };
          }
        ];
      };
      zeta = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [ 
          ./configuration.nix
          ./hosts/laptop
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit inputs; };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.melal = import ./modules/home.nix ;
            };
          }
        ];
      };

    };
  };
}
