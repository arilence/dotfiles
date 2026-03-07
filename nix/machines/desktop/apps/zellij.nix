{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;
    })
    (final: prev: {
      zjstatus-hints = inputs.zjstatus-hints.packages.${prev.stdenv.hostPlatform.system}.default;
    })
    (final: prev: {
      vim-zellij-navigator =
        inputs.vim-zellij-navigator.packages.${prev.stdenv.hostPlatform.system}.default;
    })
  ];

  environment.systemPackages = with pkgs; [
    zellij
  ];

  home-manager.users.anthony = {
    programs.zsh = {
      shellAliases = {
        t = "zellij";
        tl = "zellij list-sessions";
        tk = "zellij kill-session";
        tdd = "zellij delete-all-sessions";
      };

      # Autostart zellij when terminal starts
      initContent = lib.mkOrder 1500 ''
        export ZELLIJ_AUTO_EXIT=true
        eval "$(zellij setup --generate-auto-start zsh)"

        # Dynamically rename zellij tabs
        function _zellij_tab_cwd() {
          [[ -n $ZELLIJ ]] && zellij action rename-tab "$(basename ''${PWD:l})"
        }
        function _zellij_tab_cmd() {
          local cmd="''${1%% *}"
          [[ -n $ZELLIJ ]] && zellij action rename-tab "''${cmd:l}"
        }
        add-zsh-hook chpwd _zellij_tab_cwd
        add-zsh-hook precmd _zellij_tab_cwd
        add-zsh-hook preexec _zellij_tab_cmd
      '';
    };

    # Tell nix/home-manager to force create the config file even if one already exists.
    # If you open zellij without a config file it will auto generate a default one and causes issues.
    xdg.configFile."zellij/config.kdl".force = true;

    programs.zellij = {
      enable = true;
      # Unfortunately, enabling this breaks the "session_name" option of zellij,
      # For now I've added an autostart command to `initContent` as a workaround.
      enableZshIntegration = false;
      settings = {
        on_force_close = "detach";
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
        # Don't set keybinds here, set them inside of extraConfig instead.
        # Main reason is I don't like having to manually convert kdl syntax to nix
        # keybinds = {};
      };
      # I don't like needing to manual convert kdl settings to nix
      extraConfig = ''
        plugins {
          zjstatus-hints location="file:${pkgs.zjstatus-hints}/bin/zjstatus-hints.wasm" {
            // Maximum number of characters to display
            max_length 50 // 0 = unlimited
            // String to append when truncated
            overflow_str "..." // default
            // Name of the pipe for zjstatus integration
            pipe_name "zjstatus_hints" // default
            // Hide hints in base mode (a.k.a. default mode)
            hide_in_base_mode true
          }
        }

        load_plugins {
          zjstatus-hints
        }

        keybinds {
          shared_except "locked" {
            bind "Ctrl Shift c" {
              Copy
            }

            bind "Ctrl h" {
              MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                name "move_focus";
                payload "left";
              };
            }

            bind "Ctrl j" {
              MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                name "move_focus";
                payload "down";
                passthrough_commands "nvim,vim,atuin,fzf";
              };
            }

            bind "Ctrl k" {
              MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                name "move_focus";
                payload "up";
                passthrough_commands "nvim,vim,atuin,fzf";
              };
            }

            bind "Ctrl l" {
              MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                name "move_focus";
                payload "right";
              };
            }

            bind "Alt h" {
              MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                name "resize";
                payload "left";
                resize_mod "alt";
              };
            }

            bind "Alt j" {
              MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                name "resize";
                payload "down";
                resize_mod "alt";
              };
            }

            bind "Alt k" {
              MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                name "resize";
                payload "up";
                resize_mod "alt";
              };
            }

            bind "Alt l" {
              MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                name "resize";
                payload "right";
                resize_mod "alt";
              };
            }
          }
        }
      '';
    };

    # Home Manager does have `programs.zellij.layouts` but I found it mangled the .kdl too much
    xdg.configFile."zellij/layouts/default.kdl" = {
      force = true;
      # TODO: Add dark mode colours
      text = ''
        layout {
          default_tab_template {
            children
            pane size=1 borderless=true {
              plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                // TODO: enable zjstatus-hints when it support better dynamic widths
                format_left   "{mode}#[fg=#6C6F85]"
                format_center "{tabs}"
                format_right  "{session} "
                format_space  ""

                // Note: this is necessary to show zjstatus-hints
                // or else zjstatus won't render the pipe:
                pipe_zjstatus_hints_format "{output}"

                border_enabled  "false"
                border_char     "─"
                border_format   "#[fg=#BCC0CC]{char}"
                border_position "top"

                hide_frame_for_single_pane "true"

                mode_normal        "#[fg=#1E66F5] ● "
                mode_locked        "#[fg=#D20F39,bold] locked "
                mode_resize        "#[fg=#FE640B,bold] resize "
                mode_pane          "#[fg=#40A02B,bold] pane "
                mode_tab           "#[fg=#DF8E1D,bold] tab "
                mode_scroll        "#[fg=#8839EF,bold] scroll "
                mode_enter_search  "#[fg=#04A5E5,bold] search "
                mode_search        "#[fg=#04A5E5,bold] search "
                mode_rename_tab    "#[fg=#DF8E1D,bold] rename "
                mode_rename_pane   "#[fg=#40A02B,bold] rename "
                mode_session       "#[fg=#179299,bold] session "
                mode_move          "#[fg=#DD7878,bold] move "
                mode_prompt        "#[fg=#04A5E5,bold] prompt "
                mode_tmux          "#[fg=#FE640B,bold] tmux "

                tab_normal    "#[fg=#ACB0BE] {name} "
                tab_active    "#[fg=#4C4F69,bold] {name} "
                tab_separator "#[fg=#BCC0CC] • "
              }
            }
          }
        }
      '';
    };
  };
}
