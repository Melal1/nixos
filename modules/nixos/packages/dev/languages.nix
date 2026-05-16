{ pkgs, config, unstable, lib, ... }: {
  config = lib.mkIf config.my.groups.dev.enable {
    environment.systemPackages = (with pkgs; [
      vscode-extensions.ms-vscode.cpptools gdb lua
      cmake gradle gnumake
      cargo python3 nodejs typescript kdePackages.qtdeclarative premake go
    ]) ++ (with unstable; [
      clang gcc
    ]);
    programs.java = {
      enable = true;
      package = pkgs.jdk21_headless.override { enableJavaFX = true; };
    };
  };
}
