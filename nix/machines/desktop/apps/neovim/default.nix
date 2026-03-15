{ pkgs, inputs, ... }:

{
  # Installs the latest nightly version, faster releases than official nixos packages
  # Requires the overlay to be added in flake.nix
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    # language servers
    lua-language-server
    nixd
    rust-analyzer
    # plugin prerequisites
    gcc
    ripgrep
    tree-sitter
  ];

  home-manager.users.anthony.programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      nvim-treesitter.withAllGrammars
    ];
    extraLuaConfig = ''
      ${builtins.readFile ./config/init.lua}
      ${builtins.readFile ./config/options.lua}
      ${builtins.readFile ./config/keymaps.lua}
      ${builtins.readFile ./config/autocmds.lua}
    '';
  };
}
