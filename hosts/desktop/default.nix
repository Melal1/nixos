{
  imports = [
    ./hardware/configuration.nix
    ./users/melal.nix
    ./structure.nix
    ./kernel.nix
  ];
  networking.hostName = "alpha";
  systemd.services.fix-suspend = {
  description = "Fix for the suspend issue";
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "/bin/sh -c 'echo GPP0 > /proc/acpi/wakeup'";
  };
};

}
