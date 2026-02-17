{ pkgs, inputs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;

    # Enable TPM emulation (for Windows 11)
    qemu = {
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;

  # TODO: make username configurable
  users.groups.libvirtd.members = [ "anthony" ];
  users.groups.kvm.members = [ "anthony" ];

  environment.systemPackages = with pkgs; [
    # VM management
    gnome-boxes
    # VM networking
    dnsmasq
  ];
}
