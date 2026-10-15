{ pkgs }:
pkgs.mkShell {
  inputsFrom = [ (import ./cpp.nix { inherit pkgs; }) ];

  buildInputs = with pkgs; [
    libsndfile
    onnxruntime
    portaudio
  ];
}
