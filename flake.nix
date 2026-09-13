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
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
          # permittedInsecurePackages = [ "pnpm-10.29.2" ];
        };
      };

      # Hosts are auto-discovered from hosts/<name>/meta.nix.
      # Adding a machine = creating hosts/<name>/ with meta.nix + default.nix + home.nix.
      hosts =
        let
          dirs = builtins.readDir ./hosts;
          isHost = name: type:
            type == "directory" && builtins.pathExists (./hosts + "/${name}/meta.nix");
        in
        nixpkgs.lib.mapAttrs
          (name: _: import (./hosts + "/${name}/meta.nix"))
          (nixpkgs.lib.filterAttrs isHost dirs);

      mkHost = name: { windowManager }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs unstable windowManager;
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
            inherit self windowManager inputs;
            hostname = name;
            osConfig = self.nixosConfigurations.${name}.config;
          };
          modules = [
            inputs.spicetify-nix.homeManagerModules.default
            (./hosts + "/${name}/home.nix")
          ];
        };
      baseHomeConfigs = builtins.mapAttrs mkHome hosts;
    in
    {
      nixosConfigurations = builtins.mapAttrs mkHost hosts;

      # Standalone home-manager (kept separate from nixosConfigurations on purpose)
      homeConfigurations =
        baseHomeConfigs
        // nixpkgs.lib.mapAttrs'
          (name: conf: nixpkgs.lib.nameValuePair "${conf.config.home.username}@${name}" conf)
          baseHomeConfigs;

      # Custom packages, buildable standalone: nix build .#dwm
      packages.${system} = { inherit (pkgs) dwm dwmblocks-async xwinwrap easydotnet; };

      devShells.${system} = import ./shells { inherit pkgs; };
    };
}
