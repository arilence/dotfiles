{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.mission-center ];

  home-manager.users.anthony.dconf.settings."io/missioncenter/MissionCenter" = {
    # Include child activity so busy process groups sort above idle parent processes.
    apps-page-merged-process-stats = true;
    # Use the same 0–100% scale as overall CPU usage.
    apps-page-core-count-affects-percentages = false;

    apps-page-remember-sorting = true;
    apps-page-sorting-column-name = "cpu";
    apps-page-sorting-order = "Descending";
  };
}
