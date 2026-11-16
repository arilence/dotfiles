{
  inputs,
  configurationName,
  configurationRepository,
  ...
}:

{
  imports = [ inputs.nix-host-updater.nixosModules.default ];

  services.nix-host-updater = {
    enable = true;
    repository = configurationRepository;
    branch = "main";
    inherit configurationName;
  };
}
