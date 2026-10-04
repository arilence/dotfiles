{ pkgs, inputs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [ "virbr0" ];

    # Enable TPM emulation (for Windows 11)
    qemu = {
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;

  # TODO: make username configurable
  users.groups.libvirtd.members = [ "anthony" ];
  users.groups.kvm.members = [ "anthony" ];

  # Disable Remmina's start on user login
  home-manager.users.anthony.xdg.configFile."autostart/remmina-applet.desktop" = {
    force = true;
    text = ''
      [Desktop Entry]
      Name=Remmina Applet
      Exec=remmina -i
      Icon=org.remmina.Remmina
      Terminal=false
      Type=Application
      Hidden=true
    '';
  };

  environment.systemPackages = with pkgs; [
    # RDP client for connecting to VMs
    remmina

    # VM networking
    dnsmasq
  ];
}
