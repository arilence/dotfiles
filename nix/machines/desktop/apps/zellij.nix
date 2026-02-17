{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;
    })
  ];

  environment.systemPackages = with pkgs; [
    zellij
  ];

  home-manager.users.anthony = {
    programs.zsh.shellAliases = {
      t = "zellij";
      tl = "zellij list-sessions";
      tk = "zellij kill-session";
      tdd = "zellij delete-all-sessions";
    };

    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
      attachExistingSession = true;
      settings = {
        on_force_close = "quit";
        simplified_ui = true; # maybe disables ligatures?
        pane_frames = false;
        theme = "catppuccin-latte";
        mouse_mode = true;
        copy_on_select = false;
        session_name = "main";
        attach_to_session = true;
        show_startup_tips = false;
        show_release_notes = false;
        default_layout = "default";
        keybinds = {
          normal = {
            "bind \"Ctrl Shift c\"" = {
              Copy = { };
            };
          };
        };
      };
    };

    # Home Manager does have `programs.zellij.layouts` but I found it mangled the .kdl too much
    xdg.configFile."zellij/layouts/default.kdl".text = ''
      layout {
        default_tab_template {
          children
          pane size=1 borderless=true {
            plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
              format_left   "{mode} #[fg=#89B4FA,bold]{session}"
              format_center "{tabs}"
              format_right  "{command_git_branch} {datetime}"
              format_space  ""

              border_enabled  "false"
              border_char     "─"
              border_format   "#[fg=#6C7086]{char}"
              border_position "top"

              hide_frame_for_single_pane "true"

              mode_normal  "#[bg=blue] "
              mode_tmux    "#[bg=#ffc387] "

              tab_normal   "#[fg=#6C7086] {name} "
              tab_active   "#[fg=#9399B2,bold,italic] {name} "

              command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
              command_git_branch_format      "#[fg=blue] {stdout} "
              command_git_branch_interval    "10"
              command_git_branch_rendermode  "static"
            }
          }
        }
      }
    '';
  };
}
