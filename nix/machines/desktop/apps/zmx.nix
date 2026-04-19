{ pkgs, inputs, ... }:

{
  environment.systemPackages = [
    inputs.zmx.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
