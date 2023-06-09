{ config, lib, ... }: with lib;
let
  cfg = config.libvirt;

  volumeModule = { name, ... }: {
    options.name = mkOption {
      type = types.str;
      default = name;
      description = mdDoc ''
        A unique name for the resource, required by libvirt.
        Changing this forces a new resource to be created.
      '';
    };

    options.size = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = mdDoc ''
        The size of the volumes in bytes.
        It is infered when possible.
      '';
    };

    options.source = mkOption {
      type = types.path;
      description = ''
        Optional, the path to the image that will copied to create this volume.
        The source must either be a local path or a https uri.
      '';
    };

    options.provider = mkOption {
      type = types.str;
      default = "libvirt.default";
      description = mdDoc ''
        Which provider should be used for this ressource.
      '';
    };
  };
in
{
  options.libvirt.volumes = mkOption {
    type = types.attrsOf (types.submodule volumeModule);
  };

  config.resource.libvirt_volume = cfg.volumes;
}
