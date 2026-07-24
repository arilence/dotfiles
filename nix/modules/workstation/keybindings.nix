{ lib, ... }:

{
  options.arilence.workstation.keybindings.primaryModifier = lib.mkOption {
    type = lib.types.enum [
      "Alt"
      "Super"
    ];
    default = "Alt";
    description = ''
      Modifier used for workstation-level shortcuts. Use "Super" on Apple
      keyboards to keep shortcuts on the key directly beside the space bar.
    '';
  };
}
