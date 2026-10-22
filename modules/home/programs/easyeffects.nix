{
  config,
  lib,
  osConfig ? null,
  ...
}:
{
  config = lib.mkIf config.services.easyeffects.enable {
    assertions = [
      {
        assertion =
          osConfig == null || (osConfig.programs.dconf.enable && osConfig.services.pipewire.enable);
        message = "EasyEffects requires NixOS dconf and PipeWire support.";
      }
    ];
  };
}
