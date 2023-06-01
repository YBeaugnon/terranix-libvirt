{ config, lib, ... }: with lib;
let
  cfg = config.libvirt;

  domainModule = { name, ... }: {
    options.name = mkOption {
      type = types.str;
      default = name;
      description = mdDoc ''
        A unique name for the resource, required by libvirt.
        Changing this forces a new resource to be created.
      '';
    };

    options.description = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        The description for domain.
        Changing this forces a new resource to be created.
        This data is not used by libvirt in any way,
        it can contain any information the user wants.
      '';
    };

    options.vcpu = mkOption {
      type = types.ints.unsigned;
      default = 1;
      description = mdDoc ''
        The amount of virtual CPUs.
      '';
    };

    options.memory = mkOption {
      type = types.ints.unsigned;
      default = 512;
      description = mdDoc ''
        The amount of memory in MiB.
      '';
    };

    options.running = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc ''
        Turn on/off the instance.
      '';
    };

    options.autostart = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc ''
        Should the domain be started on host boot up.
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
  options.libvirt.domains = mkOption {
    type = types.attrsOf (types.submodule domainModule);
    default = { };
    description = ''
      A set of libvirt domains.
    '';
  };
  config.resource.libvirt_domain = mapAttrs
    (name: domain:
      domain
    )
    cfg.domains;
}