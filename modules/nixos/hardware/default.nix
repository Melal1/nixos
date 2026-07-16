# All hardware feature modules are imported unconditionally and are
# activated per host through my.hardware.* enable options.
{
  imports = [
    ./bluetooth.nix
    ./battery-opt.nix
    ./performance.nix
    ./gpu/amd.nix
    ./gpu/intel.nix
    ./gpu/nvidia.nix
    ./input/touchpad.nix
  ];
}
