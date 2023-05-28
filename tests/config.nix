{ ... }:
{
  # Define provisioner.
  libvirt.providers.libvirt = {
    uri = "qemu+ssh://root@server_a/system";
  };

  libvirt.providers.backup = {
    uri = "qemu+ssh://root@server_b/system";
  };

}
