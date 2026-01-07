{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    #cpp 
    ncurses
    dpp #Discord
    fmt

    #python
    (python3.withPackages (p: [
      p.requests
    ]))
    nlohmann_json
    libsndfile





  ];
}


