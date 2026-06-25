{ pkgs, unstable, ... }: {
  environment.systemPackages = (with pkgs; [
    (python3.withPackages (p: [
      p.requests
      p.soundfile
      p.numpy
      p.matplotlib
      p.opencv4Full
      p.pyqt6
    ]))
    nlohmann_json
    libsndfile
    onnxruntime
    portaudio
  ]) ++ (with unstable; [
    ncurses
    dpp
    fmt
  ]);
}
