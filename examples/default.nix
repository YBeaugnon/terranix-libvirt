{ config, pkgs, images, ... }: with pkgs; {
  libvirt.providers.default.uri = "qemu:///system";

  libvirt.volumes.nixos = {
    source = "${images.nixos-base}/nixos.qcow2";
  };

  libvirt.domains.vm-test = { };
}
