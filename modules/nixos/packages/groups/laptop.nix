{ pkgs, config, lib, ... }: {
  config = lib.mkIf config.my.groups.laptop.enable {
    environment.systemPackages = with pkgs; [
      brightnessctl acpi btop
    ];
  };
}
