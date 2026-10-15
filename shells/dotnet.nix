{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    dotnet-sdk_10
    csharpier
    easydotnet
    netcoredbg
  ];

  shellHook = ''
    export DOTNET_ROOT="${pkgs.dotnet-sdk_10}/share/dotnet"
  '';
}
