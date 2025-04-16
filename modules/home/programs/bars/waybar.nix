{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        "margin-bottom" = -4;
        "exclusive" = true;
        "margin-left" = 120;
        "margin-right" = 120;
        "height" = 0;
        "position" = "top";
        "spacing" = 0;
        "reload_style_on_change" = true;

        "modules-left" = [
          "user"
          "hyprland/window"
          "cava"
        ];

        "modules-center" = [
          "hyprland/workspaces"
        ];

        "modules-right" = [
          "battery"
          "group/wireless"
          "tray"
          "clock"
        ];

        "user" = {
          "format" = "  |";
          "interval" = 60;
          "height" = 30;
          "width" = 30;
          "icon" = true;
          "avatar" = "/home/melal/Picture/Pfp/ready/A2.png";
          "open-on-click" = false;
        };

        "hyprland/workspaces" = {
          "format" = "{icon}";
          "format-icons" = {
            "1" = " ";
            "2" = " ";
            "3" = "󰇥";
            "4" = " ";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "default" = " ";
            "urgent" = " ";
          };
          "persistent-workspaces" = {
            "*" = 3;
          };
          "on-click" = "activate";
        };

        "cava" = {
          "cava_config" = "/home/melal/.config/cava/config";
          "framerate" = 120;
          "sensitivity" = 1;
          "bars" = 7;
          "lower_cutoff_freq" = 50;
          "higher_cutoff_freq" = 10000;
          "method" = "pulse";
          "source" = "auto";
          "stereo" = true;
          "reverse" = false;
          "bar_delimiter" = 0;
          "monstercat" = false;
          "waves" = false;
          "noise_reduction" = 0.77;
          "input_delay" = 1;
          "format-icons" = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
          "actions" = {
            "on-click-right" = "mode";
          };
        };

        "hyprland/window" = {
          "rewrite" = {
            "(.*) — Zen Browser" = "Zen";
            "(.*) - YouTube — Zen Browser" = "Youtube";
            "NotVscode - (.*)" = "<b>!    $1</b>";
            "sudo nixos-rebuild switch --flake (.*)" = "󱄅    Rebuilding System ...";
            "home-manager switch --flake (.*)" = "󱂵    Rebuilding Home Manager ...";
          };
          "separate-outputs" = true;
        };

        "keyboard-state" = {
          "numlock" = true;
          "capslock" = true;
          "format" = "{name} {icon}";
          "format-icons" = {
            "locked" = "";
            "unlocked" = "";
          };
        };

        "tray" = {
          "spacing" = 10;
        };

        "clock" = {
          "format" = "<b>{:%b %d %a %I:%M%p}</b>";
          "interval" = 30;
          "tooltip-format" = "<tt>{calendar}</tt>";
          "calendar" = {
            "mode" = "month";
            "mode-mon-col" = 4;
            "on-scroll" = 1;
            "format" = {
              "months" = "<span><b><u>{}</u></b></span>";
              "days" = "<span><small>{}</small></span>";
              "weekdays" = "<span><b>{}</b></span>";
              "today" = "<span foreground='#bbb5e4'><big><b><u>{}</u></b></big></span>";
            };
          };
        };

        "cpu" = {
          "format" = "/ C {usage}% ";
          "interval" = 2;
        };

        "memory" = {
          "interval" = 10;
          "format" = "/ M {}% ";
        };

        "disk" = {
          "interval" = 130;
          "format" = "D {percentage_used}% ";
          "path" = "/";
        };

        "hyprland/language" = {
          "format" = "/ K {short}";
        };

        "group/wireless" = {
          "orientation" = "inherit";
          "modules" = [
            "bluetooth"
            "network"
          ];
        };

        "network" = {
          "format" = " {ifname}";
          "format-wifi" = "{icon}";
          "format-ethernet" = "󰈀 ";
          "format-disconnected" = "󰤭 ";
          "max-length" = 50;
          "format-icons" = [ "󰤯 " "󰤟 " "󰤢 " "󰤥 " "󰤨 " ];
          "tooltip-format-wifi" = "{essid}   -   {ipaddr}";
          "on-click-right" = "wihotspot";
          "on-click" = "hyprctl dispatch workspace 1 ; sleep 0.2 ;  kitty -e sudo nmtui";
        };

        "battery" = {
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{icon} <b>{capacity}</b>%";
          "format-charging" = "󰂄 {capacity}%";
          "format-plugged" = " {capacity}%";
          "format-icons" = [ " " " " " " " " " " ];
        };

        "pulseaudio" = {
          "format" = "{icon}  {volume}%";
          "format-bluetooth" = "{volume}%  {icon} {format_source}";
          "format-bluetooth-muted" = "M  {icon} {format_source}";
          "format-muted" = "<b>Muted</b>";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "" " " " " ];
          };
          "on-click" = "pavucontrol";
        };

        "bluetooth" = {
          "format-disabled" = "";
          "format-off" = "";
          "format-on" = "<b>󰂯</b>";
          "format-connected" = "󰂱";
          "interval" = 30;
          "on-click" = "hyprctl dispatch workspace 1 ; sleep 0.2 ;kitty -e bluetui";
          "format-no-controller" = "";
          "tooltip-format-connected" = "{device_alias}";
        };
      };
    };

    style = ''
      @import "colors.css";
      * {
          font-family: 'Radio Canada Big', sans-serif;
          font-weight: bold;
          border-radius: 8px;
          min-height: 25px;
      }
      /* Waybar Window Styles */
      window#waybar {
          background: @background;
          color: @on_surface;
          padding: 0;
          border-radius: 0px 0px 17px 17px;
          transition-duration: 0.5s;
          border-bottom: 0.7px solid @surface_container_high;
      }
      /* Module Layout */
      .modules-left {
          margin-left: 12px;
      }
      .modules-right {
          margin-right: 12px;
      }
      /* Workspaces Module */
      #workspaces {
          background: transparent;
          margin: 0 0 5px 0;
          font-size: 15px;
          padding: 3px 2px 3px 1px;
          border-radius: 16px;
          color: @on_background;
      }
      #workspaces button {
          font-weight: bold;
          padding: 0px 5px;
          font-size: 15px;
          margin: 0px 3px;
          border-radius: 16px;
          color: @outline_variant;
          background: @surface_bright;
          transition: all 0.3s ease-in-out;
      }
      #workspaces button.active {
          font-size: 15px;
          font-weight: bold;
          background-color: @primary;
          color: @on_primary;
          border-radius: 16px;
          min-width: 50px;
          transition: all 0.4s ease-in-out;
      }
      #workspaces button:hover {
          font-weight: bold;
          font-size: 15px;
          background-color: @surface_container;
          color: @on_surface;
          border-radius: 16px;
          min-width: 35px;
      }
      #workspaces button.urgent {
          font-weight: bold;
          background-color: @error;
          color: @on_error;
          border-radius: 16px;
          min-width: 40px;
          transition: all 0.3s ease-in-out;
          font-size: 15px;
      }
      /* CAVA (Audio Visualizer) Module */
      #cava {
          color: @on_primary_container;
          background-color: transparent;
          font-size: 15px;
          margin: 4px 0 5px 20px;
      }
      /* Window Title Module */
      #window {
          color: @inverse_surface;
          background-color: transparent;
          font-size: 17px;
          margin: 4px 0 7px 0;
      }
      /* Clock Module */
      #clock {
          color: @background;
          background-color: @inverse_surface;
          padding: 0 15px 0 15px;
          font-size: 15px;
          margin: 5px 0 7px 15px;
      }
      /* Battery Module */
      #battery {
          color: @inverse_surface;
          font-size: 15px;
          background-color: transparent;
          margin: 0 0 5px 27px;
      }
      /* Bluetooth Module */
      #bluetooth {
          color: @on_secondary_container;
          background: transparent;
          font-size: 15px;
          margin: 0px 0 0px 0;
      }
      /* Network Module */
      #user {
        margin: 0 10px 3px 0;
        color: @outline;
      }
      #network {
          color: @on_secondary_container;
          font-size: 15px;
          background: transparent;
          margin: 0 0 0px 10px;
      }
      /* Wireless Module */
      #wireless {
          background-color: @surface_variant;
          font-size: 15px;
          padding: 0 7px 0 7px;
          border-radius: 20px;
          margin: 4px 0 7px 15px;
      }
      /* Empty Window Style */
      window#waybar.empty #window {
          background-color: transparent;
      }
    '';
  };
}
