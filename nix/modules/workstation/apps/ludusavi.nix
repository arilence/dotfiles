{ pkgs, ... }:

let
  ludusavi-backup = pkgs.writeShellApplication {
    name = "ludusavi-backup";
    runtimeInputs = [ pkgs.ludusavi ];
    text = ''
      echo "Starting Ludusavi Backup..."
      ludusavi backup --force
      echo "Finished Ludusavi Backup..."
    '';
  };
in
{
  environment.systemPackages = [ pkgs.ludusavi ];

  home-manager.users.anthony.xdg.configFile."kopia/actions/ludusavi-backup" = {
    source = "${ludusavi-backup}/bin/ludusavi-backup";
    force = true;
  };
}
