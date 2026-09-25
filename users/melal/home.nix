{ user }:
{
  home = {
    username = user.name;
    inherit (user) homeDirectory;
    stateVersion = user.homeStateVersion;
  };
}
