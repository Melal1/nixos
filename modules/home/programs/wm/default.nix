{ windowManager, ... }:
{
  imports =
    if windowManager == "hyprland" then [ ./hyprland ]
    else [ ];
}
