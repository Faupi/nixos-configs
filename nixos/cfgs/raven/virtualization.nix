{ ... }: {
  programs.virt-manager.enable = true;

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      swtpm.enable = true;
      runAsRoot = false;
    };
  };

  users.users.faupi.extraGroups = [
    "libvirtd"
    "kvm"
  ];
}
