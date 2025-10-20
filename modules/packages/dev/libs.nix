{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
  #cpp 
  ncurses 
  dpp  #Discord



  ];
}


