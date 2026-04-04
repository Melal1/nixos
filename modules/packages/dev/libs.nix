{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    #cpp 
    ncurses
    dpp #Discord
    fmt

    #python
    (python3.withPackages (p: [
      p.requests
      p.soundfile
      p.numpy
      p.matplotlib
      p.opencv-python
    ]))
    nlohmann_json
    libsndfile





  ];
}


