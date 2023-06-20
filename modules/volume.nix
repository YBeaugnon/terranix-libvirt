{ config, lib, ... }: with lib;
let
  cfg = config.libvirt;

  volumeModule = { name, config, ... }: {
    options.name = mkOption {
      type = types.str;
      description = mdDoc ''
        A unique name for the resource, required by libvirt.
        Changing this forces a new resource to be created.
      '';
    };
    config.name = name;

    options.size = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = mdDoc ''
        The size of the volumes in bytes.
        It is infered when possible.
      '';
    };

    options.source = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Optional, the path to the image that will copied to create this volume.
        The source must be a local path.
      '';
    };

    options.provider = mkOption {
      type = types.str;
      default = "libvirt.default";
      description = mdDoc ''
        Which provider should be used for this ressource.
      '';
    };

    options.id = mkOption {
      type = types.str;
      description = ''
        The variable usable as reference to the id of this ressource.
      '';
    };
    config.id = "\${libvirt_volume.${name}.id}";
  };
in
{
  options.libvirt.volumes = mkOption {
    type = types.attrsOf (types.submodule volumeModule);
    default = {};
  };

  config.resource.libvirt_volume = mapAttrs
    (name: volume: {
      name = mkIf (volume.source != null)
        "${builtins.hashString "sha256" volume.source}-${volume.name}";
      size = volume.size;
      source = volume.source;
      provider = volume.provider;
    })
    cfg.volumes;
}
