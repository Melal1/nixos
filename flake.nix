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
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # /home/melal/Dev/projects/cpp/mrem checked out.
    # music-sep = {
    #   url = "git+file:/home/melal/Dev/projects/cpp/mrem";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    tincan-cli = {
      url = "github:bilalyazicioglu/tincan-cli/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    timr-tui = {
      url = "github:sectore/timr-tui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    skwd-wall = {
      url = "github:liixini/skwd-wall/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ditto = {
    #   url = "github:arvingarciabtw/ditto";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell-niri = {
      url = "github:imiric/qml-niri/main";
      inputs.quickshell.follows = "quickshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # zen-browser = {
    #   url = "github:0xc000022070/zen-browser-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    helium-flake = {
      url = "github:oxcl/nix-flake-helium-browser";
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
      devShells = import ./shells { inherit pkgs; };
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
            inputs.skwd-wall.nixosModules.default
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
        inherit (pkgs) easydotnet;
      };

      devShells.${system} = devShells;

      formatter.${system} = treefmtEval.config.build.wrapper;

      checks.${system} = {
        shell-hooks = pkgs.runCommand "shell-hooks-check" { nativeBuildInputs = [ pkgs.bash ]; } (
          nixpkgs.lib.concatStringsSep "\n" (
            nixpkgs.lib.mapAttrsToList (
              name: shell:
              let
                # Syntax checking only needs the text, not the packages referenced by the hook.
                hook = pkgs.writeText "${name}-shell-hook.sh" (
                  builtins.unsafeDiscardStringContext (shell.shellHook or "")
                );
              in
              "bash -n ${hook}"
            ) devShells
          )
          + "\ntouch \"$out\"\n"
        );

        niri-config = pkgs.runCommand "niri-config-check" { nativeBuildInputs = [ pkgs.niri ]; } ''
          mkdir -p niri
          cp ${./modules/home/programs/wm/niri/config.kdl} niri/config.kdl
          cp ${./modules/home/programs/wm/niri/themes/default.kdl} niri/default.kdl
          ${nixpkgs.lib.concatMapStringsSep "\n" (
            homeName:
            nixpkgs.lib.optionalString homeConfigs.${homeName}.config.my.home.wm.niri.enable ''
              cp --remove-destination ${
                pkgs.writeText "${homeName}-browser.kdl"
                  homeConfigs.${homeName}.config.xdg.configFile."niri/browser.kdl".text
              } niri/browser.kdl
              ${nixpkgs.lib.optionalString homeConfigs.${homeName}.config.my.home.noctalia.enable ''
                cp ${./modules/home/programs/noctalia/niri.kdl} niri/noctalia.kdl
              ''}
              niri validate --config niri/config.kdl
              rm -f niri/noctalia.kdl
            ''
          ) (builtins.attrNames homeConfigs)}
          touch "$out"
        '';

        assets-setup =
          pkgs.runCommand "assets-setup-check"
            {
              nativeBuildInputs = [
                pkgs.bash
                pkgs.git
                pkgs.coreutils
                (import ./modules/home/scripts/assets-setup.nix {
                  inherit pkgs;
                  dotfilesDir = self;
                })
              ];
            }
            ''
              bash ${./tests/assets-setup.sh}
              touch "$out"
            '';

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
      }
      // nixpkgs.lib.mapAttrs' (
        name: home: nixpkgs.lib.nameValuePair "home-${name}" home.activationPackage
      ) homeConfigs;
    };
}
