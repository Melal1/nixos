{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    jmtpfs
    alsa-utils # ALSA, the Advanced Linux Sound Architecture utils
    pavucontrol # GUI audio control
    android-tools
  ];
}
