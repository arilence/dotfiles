{
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    inotify-tools
    inputs.expert.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
