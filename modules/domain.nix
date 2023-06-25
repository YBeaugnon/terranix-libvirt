{ config, lib, ... }: with lib;
let
  cfg = config.libvirt;

  diskModule = {
    options.volume_id = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    options.block_device = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    options.scsi = mkOption {
      type = types.bool;
      default = true;
    };
  };

  networkInterfaceModule = {
    options.network_id = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    options.network_name = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    options.addresses = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = [ ];
    };

    options.hostname = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    options.mac = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    options.wait_for_lease = mkOption {
      type = types.bool;
      default = false;
    };

    options.bridge = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    options.macvtap = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  fileSystemModule = {
    options.source = mkOption {
      type = types.str;
    };

    options.target = mkOption {
      type = types.str;
    };

    options.readonly = mkOption {
      type = types.bool;
      default = true;
    };
  };

  domainModule = { name, ... }: {
    options.name = mkOption {
      type = types.str;
      description = mdDoc ''
        A unique name for the resource, required by libvirt.
        Changing this forces a new resource to be created.
      '';
    };
    config.name = name;

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

    options.disks = mkOption {
      type = types.listOf (types.submodule diskModule);
      description = mdDoc ''
        A list of disk to be attached to the domain.
      '';
      default = [ ];
    };

    options.fileSystems = mkOption {
      type = types.listOf (types.submodule fileSystemModule);
      description = mdDoc ''
        A list of file system to be passed as 9p virtio-fs.
      '';
      default = [ ];
    };

    options.networkInterfaces = mkOption {
      type = types.listOf (types.submodule networkInterfaceModule);
      default = [ ];
    };

    options.id = mkOption {
      type = types.str;
    };
    config.id = "\${libvirt_domain.${name}.id}";
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
    (name: domain: {
      name = domain.name;
      description = domain.description;
      vcpu = domain.vcpu;
      memory = domain.memory;
      running = domain.running;
      autostart = domain.autostart;
      disk = domain.disks;
      filesystem = domain.fileSystems;
      network_interface = domain.networkInterfaces;
      provider = domain.provider;
    })
    cfg.domains;
}
