{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
  ncurses
  ];
}


