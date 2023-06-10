{ config, lib, ... }: with lib;
let
  cfg = config.libvirt;

  poolModule = { name, ... }: {
    options.name = mkOption {
      type = types.str;
      description = ''
        Unique name for the ressource, required by libvirt.
      '';
    };
    config.name = name;

    options.type = mkOption {
      type = types.str;
      description = ''
        Type of the pool, for now, only dir is supported.
      '';
    };

    config.type = "dir";

    options.path = mkOption {
      type = types.str;
      example = "/var/lib/libvirt/images";
      description = ''
        Path to the directory that shall be used as a pool.
        Only needed and required for type=dir;
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
    };
    config.id = "\${libvirt_pool.${name}.id}";

  };
in
{
  options.libvirt.pools = mkOption {
    type = types.attrsOf (types.submodule poolModule);
    default = { };
    description = ''
      A set of libvirt pool, only dir type are supported.
    '';
  };

  config.resource.libvirt_pool = mapAttrs
    (name: pool: {
      name = pool.name;
      description = pool.description;
      type = pool.type;
      path = pool.path;
      provider = pool.provider;
    })
    cfg.pools;
}
