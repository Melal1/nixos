{ pkgs, ... }:

pkgs.mkShell {

  packages = with pkgs; [
    nodejs_22
  ];

  shellHook = ''
    export PATH="$PWD/node_modules/.bin:$PATH"
    echo "Node $(node -v) / npm $(npm -v) environment active."
  '';

}
