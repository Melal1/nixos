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

  # Each host has a NixOS entrypoint and a corresponding Melal home module.
  hosts =
    let
      dirs = builtins.readDir ../hosts;
      isHost = name: type: type == "directory" && builtins.pathExists (../hosts + "/${name}/default.nix");
    in
    builtins.attrNames (nixpkgs.lib.filterAttrs isHost dirs);

  mkHost =
    name:
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
        (../hosts + "/${name}")
      ];
    };

  mkHome =
    hostName:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit self inputs unstable;
        hostname = hostName;
        osConfig = self.nixosConfigurations.${hostName}.config;
      };
      modules = [
        ../modules/home
        (../modules/home + "/hosts/${hostName}")
      ];
    };

  homeConfigs = builtins.listToAttrs (
    map (hostName: {
      name = "melal@${hostName}";
      value = mkHome hostName;
    }) hosts
  );

  # Preserve the short #<hostname> aliases alongside #melal@<hostname>.
  legacyHomeConfigs = nixpkgs.lib.genAttrs hosts (hostName: homeConfigs."melal@${hostName}");
in
{
  # Share canonical homes with checks without repeating the hostname aliases.
  _module.args.homeConfigs = homeConfigs;

  flake = {
    nixosConfigurations = nixpkgs.lib.genAttrs hosts mkHost;
    homeConfigurations = homeConfigs // legacyHomeConfigs;
  };
}
