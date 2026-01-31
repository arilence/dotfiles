{
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    inotify-tools
    inputs.expert.packages.${pkgs.system}.default
  ];
}
