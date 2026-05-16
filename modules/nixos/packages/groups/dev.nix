{ pkgs, unstable, config, lib, ... }: {
  config = lib.mkIf config.my.groups.dev.enable {
    environment.systemPackages = (with pkgs; [
      vscode gdbgui ninja bear logisim-evolution
    ]) ++ (with unstable; [
      opencode geminicommit gemini-cli codex neovide opencode-desktop
    ]);
  };
}
