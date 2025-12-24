{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    #cpp 
    ncurses
    dpp #Discord

    #python
    (python3.withPackages (p: [
      p.requests
    ]))




  ];
}


