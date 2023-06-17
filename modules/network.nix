{ config, lib, ... }: with lib;
let
  cfg = config.libvirt;

  networkModule = { name, ... }: {
    options.name = mkOption {
      type = types.str;
    };
    config.name = name;

    options.addresses = mkOption {
      type = types.listOf (types.str);
      default = [ ];
    };

    options.mode = mkOption {
      type = types.enum [ "none" "nat" "route" "open" "bridge" ];
      default = "nat";
    };

    options.bridge = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    options.autostart = mkOption {
      type = types.bool;
      default = true;
    };

    options.provider = mkOption {
      type = types.str;
      default = "libvirt.default";
    };
    options.id = mkOption {
      type = types.str;
      description = ''
        The variable usable as reference to the id of this ressource.
      '';
    };
    config.id = "\${libvirt_network.${name}.id}";

  };
in
{
  options.libvirt.networks = mkOption {
    type = types.attrsOf (types.submodule networkModule);
    default = { };
  };

  config.resource.libvirt_network = mapAttrs
    (name: network: {
      name = network.name;
      addresses = network.addresses;
      mode = network.mode;
      bridge = network.bridge;
      autostart = network.autostart;
      provider = network.provider;
    })
    cfg.networks;
}
