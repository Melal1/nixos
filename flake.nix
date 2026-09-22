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

    skwd-wall = {
      url = "github:liixini/skwd-wall/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      treefmt-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      overlays = [ (import ./overlays/default.nix) ];

      pkgs = import nixpkgs { inherit system overlays; };
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
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
          isHost = name: type: type == "directory" && builtins.pathExists (./hosts + "/${name}/meta.nix");
        in
        nixpkgs.lib.mapAttrs (name: _: import (./hosts + "/${name}/meta.nix")) (
          nixpkgs.lib.filterAttrs isHost dirs
        );

      # User definitions are auto-discovered from users/<name>/meta.nix.
      # A host's meta.nix decides which of these accounts it actually has.
      users =
        let
          dirs = builtins.readDir ./users;
          isUser =
            name: type:
            type == "directory"
            && builtins.pathExists (./users + "/${name}/meta.nix")
            && builtins.pathExists (./users + "/${name}/nixos.nix")
            && builtins.pathExists (./users + "/${name}/home.nix");
        in
        nixpkgs.lib.mapAttrs (name: _: (import (./users + "/${name}/meta.nix")) // { inherit name; }) (
          nixpkgs.lib.filterAttrs isUser dirs
        );

      hostUsers =
        hostName: host:
        map (
          userName:
          if builtins.hasAttr userName users then
            userName
          else
            throw "hosts/${hostName}/meta.nix references unknown user '${userName}'"
        ) (host.users or [ ]);

      mkHost =
        name: host:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs unstable;
            hostname = name;
          };
          modules = [
            {
              nixpkgs.hostPlatform = system;
              nixpkgs.overlays = overlays;
            }
            (./hosts + "/${name}")
          ]
          ++ map (userName: import (./users + "/${userName}/nixos.nix") { user = users.${userName}; }) (
            hostUsers name host
          );
        };

      mkHome =
        hostName: userName:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit self inputs unstable;
            hostname = hostName;
            osConfig = self.nixosConfigurations.${hostName}.config;
          };
          modules = [
            inputs.spicetify-nix.homeManagerModules.default
            (import (./users + "/${userName}/home.nix") { user = users.${userName}; })
            (./hosts + "/${hostName}/home.nix")
          ];
        };

      homeConfigs = nixpkgs.lib.foldl' (
        configs: hostName:
        configs
        // builtins.listToAttrs (
          map (userName: {
            name = "${userName}@${hostName}";
            value = mkHome hostName userName;
          }) (hostUsers hostName hosts.${hostName})
        )
      ) { } (builtins.attrNames hosts);

      # Keep #<hostname> working where a host has exactly one configured user.
      singleUserHosts = nixpkgs.lib.filterAttrs (
        hostName: host: builtins.length (hostUsers hostName host) == 1
      ) hosts;
      legacyHomeConfigs = builtins.mapAttrs (
        hostName: host: homeConfigs."${builtins.head (hostUsers hostName host)}@${hostName}"
      ) singleUserHosts;
    in
    {
      nixosConfigurations = builtins.mapAttrs mkHost hosts;

      homeConfigurations = homeConfigs // legacyHomeConfigs;

      packages.${system} = {
        inherit (pkgs)
          dwm
          dwmblocks-async
          xwinwrap
          easydotnet
          ;
      };

      devShells.${system} = import ./shells { inherit pkgs; };

      formatter.${system} = treefmtEval.config.build.wrapper;

      checks.${system} = {
        formatting = treefmtEval.config.build.check self;

        deadnix =
          pkgs.runCommand "deadnix-check"
            {
              nativeBuildInputs = [ pkgs.deadnix ];
            }
            ''
              deadnix --fail --no-lambda-pattern-names ${self}
              touch "$out"
            '';

        statix =
          pkgs.runCommand "statix-check"
            {
              nativeBuildInputs = [ pkgs.statix ];
            }
            ''
              statix check --config ${self}/statix.toml ${self}
              touch "$out"
            '';
      };
    };
}
