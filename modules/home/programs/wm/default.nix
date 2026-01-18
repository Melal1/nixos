{ windowManager, ... }:
{
  imports =
    if windowManager == "hyprland" then [ ./hyprland ]
    else if windowManager == "dwm" then [./dwm ]
    else [ ];
}
