{
  inputs,
  self,
  withSystem,
  ...
}:
let
  inherit (inputs) nixpkgs home-manager;
  system = "x86_64-linux";
  overlays = [ (import ../overlays/default.nix) ];
  pkgs = withSystem system ({ pkgs, ... }: pkgs);
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  # Hosts are auto-discovered from hosts/<name>/meta.nix.
  # Adding a machine = creating hosts/<name>/ with meta.nix + default.nix + home.nix.
  hosts =
    let
      dirs = builtins.readDir ../hosts;
      isHost = name: type: type == "directory" && builtins.pathExists (../hosts + "/${name}/meta.nix");
    in
    nixpkgs.lib.mapAttrs (name: _: import (../hosts + "/${name}/meta.nix")) (
      nixpkgs.lib.filterAttrs isHost dirs
    );

  # User definitions are auto-discovered from users/<name>/meta.nix.
  # A host's meta.nix decides which of these accounts it actually has.
  users =
    let
      dirs = builtins.readDir ../users;
      isUser =
        name: type:
        type == "directory"
        && builtins.pathExists (../users + "/${name}/meta.nix")
        && builtins.pathExists (../users + "/${name}/nixos.nix")
        && builtins.pathExists (../users + "/${name}/home.nix");
    in
    nixpkgs.lib.mapAttrs (name: _: (import (../users + "/${name}/meta.nix")) // { inherit name; }) (
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
        (../hosts + "/${name}")
      ]
      ++ map (userName: import (../users + "/${userName}/nixos.nix") { user = users.${userName}; }) (
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
        (import (../users + "/${userName}/home.nix") { user = users.${userName}; })
        (../hosts + "/${hostName}/home.nix")
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
  # Share canonical homes with checks without repeating the hostname aliases.
  _module.args.homeConfigs = homeConfigs;

  flake = {
    nixosConfigurations = builtins.mapAttrs mkHost hosts;
    homeConfigurations = homeConfigs // legacyHomeConfigs;
  };
}
