{
  fullName = "Melal";
  homeDirectory = "/home/melal";
  homeStateVersion = "24.11";
  shell = "fish";
  extraGroups = [
    "wheel"
    "networkmanager"
    "uinput"
    "adbusers"
    # "video" # Grants access to display hardware/video cards
    # "render" # Grants access to DRM render nodes (required for ROCm/AMD GPU compute)
  ];
}
