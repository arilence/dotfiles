{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # language servers
    lua-language-server
    nixd
    # plugin prerequisites
    ripgrep
    sops
  ];

  home-manager.users.anthony.xdg.configFile."nvim/lua/config".source = ./config;

  home-manager.users.anthony.programs.neovim = {
    enable = true;
    package = pkgs.nixosUnstable.neovim-unwrapped;
    defaultEditor = true;
    withRuby = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      smart-splits-nvim
      # Nix owns parser installation; keep every language available without :TSInstall.
      nvim-treesitter.withAllGrammars
    ];
    initLua = ''
      require("config")
    '';
  };
}
