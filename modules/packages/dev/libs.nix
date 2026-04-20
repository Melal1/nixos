{ pkgs, unstable, ... }: {
  environment.systemPackages = (with pkgs; [
    #cpp 

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





  ]) ++ (with unstable ; [
    ncurses
    dpp #Discord
    fmt
  ]);
}


