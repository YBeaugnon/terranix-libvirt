{ config, lib, ... }: with lib;
let
  cfg = config.libvirt;

  providerModule = {
    options.uri = mkOption
      {
        type = types.str;
        default = "qemu:///system";
        example = "qemu+ssh://root@example.com/system";
        description = mdDoc ''
          The connection [uri](https://libvirt.org/uri.html)
        '';
      };
  };
in
{
  options.libvirt.providers = lib.mkOption {
    type = types.attrsOf (types.submodule providerModule);
  };

  config.provider.libvirt = mapAttrsToList
    (alias: provider:
      provider // { inherit alias; }
    )
    cfg.providers;

  config.terraform.required_providers.libvirt.source = "dmacvicar/libvirt";
}
