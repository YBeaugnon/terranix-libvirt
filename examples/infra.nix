{ config, pkgs, images, ... }: with pkgs; let
  cfg = config.libvirt;
in
{
  libvirt.providers.default.uri = "qemu:///system";

  libvirt.volumes.nixos = {
    source = "${images.nixos-base}/nixos.qcow2";
  };

  libvirt.domains.vm-test = {
    disks = [
      { volume_id = cfg.volumes.nixos.id; }
    ];
    fileSystems = [
      { source = "/tmp"; target = "tmp"; }
    ];
  };

  libvirt.networks.net-test = {
    mode = "none";
  };
}
