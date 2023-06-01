{ ... }:
{
  # Define provisioner.
  libvirt.providers.default = {
    uri = "qemu+ssh://root@server_a/system?keyfile=/root/.ssh/id_ed25519&no_verify=1&no_tty=1";
  };

  libvirt.providers.backup = {
    uri = "qemu+ssh://root@server_b/system?keyfile=/root/.ssh/id_ed25519&no_verify=1&no_tty=1";
  };

  libvirt.domains.vm1 = { };

}
