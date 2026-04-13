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
        default_mode = "locked";
        # Don't set keybinds here, set them inside of extraConfig instead.
        # Main reason is I don't like having to manually convert kdl syntax to nix
        # keybinds = {};
      };
      # I don't like needing to manual convert kdl settings to nix
      extraConfig = ''
        keybinds clear-defaults=true {
          shared {
            bind "Ctrl Shift c" {
              Copy
            }
          }

          shared_among "locked" {
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


          // These are the "unlock-first" keybinds preset, where the default state is "locked"
          // Make sure `default_mode` is set to `locked` in the zellij config
          locked {
            bind "Ctrl g" { SwitchToMode "normal"; }
          }
          pane {
            bind "left" { MoveFocus "left"; }
            bind "down" { MoveFocus "down"; }
            bind "up" { MoveFocus "up"; }
            bind "right" { MoveFocus "right"; }
            bind "c" { SwitchToMode "renamepane"; PaneNameInput 0; }
            bind "d" { NewPane "down"; SwitchToMode "locked"; }
            bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "locked"; }
            bind "f" { ToggleFocusFullscreen; SwitchToMode "locked"; }
            bind "h" { MoveFocus "left"; }
            bind "i" { TogglePanePinned; SwitchToMode "locked"; }
            bind "j" { MoveFocus "down"; }
            bind "k" { MoveFocus "up"; }
            bind "l" { MoveFocus "right"; }
            bind "n" { NewPane; SwitchToMode "locked"; }
            bind "p" { SwitchToMode "normal"; }
            bind "r" { NewPane "right"; SwitchToMode "locked"; }
            bind "s" { NewPane "stacked"; SwitchToMode "locked"; }
            bind "w" { ToggleFloatingPanes; SwitchToMode "locked"; }
            bind "x" { CloseFocus; SwitchToMode "locked"; }
            bind "z" { TogglePaneFrames; SwitchToMode "locked"; }
            bind "tab" { SwitchFocus; }
          }
          tab {
            bind "left" { GoToPreviousTab; }
            bind "down" { GoToNextTab; }
            bind "up" { GoToPreviousTab; }
            bind "right" { GoToNextTab; }
            bind "1" { GoToTab 1; SwitchToMode "locked"; }
            bind "2" { GoToTab 2; SwitchToMode "locked"; }
            bind "3" { GoToTab 3; SwitchToMode "locked"; }
            bind "4" { GoToTab 4; SwitchToMode "locked"; }
            bind "5" { GoToTab 5; SwitchToMode "locked"; }
            bind "6" { GoToTab 6; SwitchToMode "locked"; }
            bind "7" { GoToTab 7; SwitchToMode "locked"; }
            bind "8" { GoToTab 8; SwitchToMode "locked"; }
            bind "9" { GoToTab 9; SwitchToMode "locked"; }
            bind "[" { BreakPaneLeft; SwitchToMode "locked"; }
            bind "]" { BreakPaneRight; SwitchToMode "locked"; }
            bind "b" { BreakPane; SwitchToMode "locked"; }
            bind "h" { GoToPreviousTab; }
            bind "j" { GoToNextTab; }
            bind "k" { GoToPreviousTab; }
            bind "l" { GoToNextTab; }
            bind "n" { NewTab; SwitchToMode "locked"; }
            bind "r" { SwitchToMode "renametab"; TabNameInput 0; }
            bind "s" { ToggleActiveSyncTab; SwitchToMode "locked"; }
            bind "t" { SwitchToMode "normal"; }
            bind "x" { CloseTab; SwitchToMode "locked"; }
            bind "tab" { ToggleTab; }
          }
          resize {
            bind "left" { Resize "Increase left"; }
            bind "down" { Resize "Increase down"; }
            bind "up" { Resize "Increase up"; }
            bind "right" { Resize "Increase right"; }
            bind "+" { Resize "Increase"; }
            bind "-" { Resize "Decrease"; }
            bind "=" { Resize "Increase"; }
            bind "H" { Resize "Decrease left"; }
            bind "J" { Resize "Decrease down"; }
            bind "K" { Resize "Decrease up"; }
            bind "L" { Resize "Decrease right"; }
            bind "h" { Resize "Increase left"; }
            bind "j" { Resize "Increase down"; }
            bind "k" { Resize "Increase up"; }
            bind "l" { Resize "Increase right"; }
            bind "r" { SwitchToMode "normal"; }
          }
          move {
            bind "left" { MovePane "left"; }
            bind "down" { MovePane "down"; }
            bind "up" { MovePane "up"; }
            bind "right" { MovePane "right"; }
            bind "h" { MovePane "left"; }
            bind "j" { MovePane "down"; }
            bind "k" { MovePane "up"; }
            bind "l" { MovePane "right"; }
            bind "m" { SwitchToMode "normal"; }
            bind "n" { MovePane; }
            bind "p" { MovePaneBackwards; }
            bind "tab" { MovePane; }
          }
          scroll {
            bind "Alt left" { MoveFocusOrTab "left"; SwitchToMode "locked"; }
            bind "Alt down" { MoveFocus "down"; SwitchToMode "locked"; }
            bind "Alt up" { MoveFocus "up"; SwitchToMode "locked"; }
            bind "Alt right" { MoveFocusOrTab "right"; SwitchToMode "locked"; }
            bind "e" { EditScrollback; SwitchToMode "locked"; }
            bind "f" { SwitchToMode "entersearch"; SearchInput 0; }
            bind "Alt h" { MoveFocusOrTab "left"; SwitchToMode "locked"; }
            bind "Alt j" { MoveFocus "down"; SwitchToMode "locked"; }
            bind "Alt k" { MoveFocus "up"; SwitchToMode "locked"; }
            bind "Alt l" { MoveFocusOrTab "right"; SwitchToMode "locked"; }
            bind "s" { SwitchToMode "normal"; }
          }
          search {
            bind "c" { SearchToggleOption "CaseSensitivity"; }
            bind "n" { Search "down"; }
            bind "o" { SearchToggleOption "WholeWord"; }
            bind "p" { Search "up"; }
            bind "w" { SearchToggleOption "Wrap"; }
          }
          session {
            bind "a" {
              LaunchOrFocusPlugin "zellij:about" {
                floating true
                move_to_focused_tab true
              }
              SwitchToMode "locked"
            }
            bind "c" {
              LaunchOrFocusPlugin "configuration" {
                floating true
                move_to_focused_tab true
              }
              SwitchToMode "locked"
            }
            bind "d" { Detach; }
            bind "o" { SwitchToMode "normal"; }
            bind "p" {
              LaunchOrFocusPlugin "plugin-manager" {
                floating true
                move_to_focused_tab true
              }
              SwitchToMode "locked"
            }
            bind "s" {
              LaunchOrFocusPlugin "zellij:share" {
                floating true
                move_to_focused_tab true
              }
              SwitchToMode "locked"
            }
            bind "w" {
              LaunchOrFocusPlugin "session-manager" {
                floating true
                move_to_focused_tab true
              }
              SwitchToMode "locked"
            }
          }
          shared_among "normal" "locked" {
            bind "Alt left" { MoveFocusOrTab "left"; }
            bind "Alt down" { MoveFocus "down"; }
            bind "Alt up" { MoveFocus "up"; }
            bind "Alt right" { MoveFocusOrTab "right"; }
            bind "Alt +" { Resize "Increase"; }
            bind "Alt -" { Resize "Decrease"; }
            bind "Alt =" { Resize "Increase"; }
            bind "Alt [" { PreviousSwapLayout; }
            bind "Alt ]" { NextSwapLayout; }
            bind "Alt f" { ToggleFloatingPanes; }
            bind "Alt h" { MoveFocusOrTab "left"; }
            bind "Alt i" { MoveTab "left"; }
            bind "Alt j" { MoveFocus "down"; }
            bind "Alt k" { MoveFocus "up"; }
            bind "Alt l" { MoveFocusOrTab "right"; }
            bind "Alt n" { NewPane; }
            bind "Alt o" { MoveTab "right"; }
            bind "Alt p" { TogglePaneInGroup; }
            bind "Alt Shift p" { ToggleGroupMarking; }
          }
          shared_except "locked" "renametab" "renamepane" {
            bind "Ctrl g" { SwitchToMode "locked"; }
            bind "Ctrl q" { Quit; }
          }
          shared_except "locked" "entersearch" {
            bind "enter" { SwitchToMode "locked"; }
          }
          shared_except "locked" "entersearch" "renametab" "renamepane" {
            bind "esc" { SwitchToMode "locked"; }
          }
          shared_except "locked" "entersearch" "renametab" "renamepane" "move" {
            bind "m" { SwitchToMode "move"; }
          }
          shared_except "locked" "entersearch" "search" "renametab" "renamepane" "session" {
            bind "o" { SwitchToMode "session"; }
          }
          shared_except "locked" "tab" "entersearch" "renametab" "renamepane" {
            bind "t" { SwitchToMode "tab"; }
          }
          shared_among "normal" "resize" "tab" "scroll" "prompt" "tmux" {
            bind "p" { SwitchToMode "pane"; }
          }
          shared_among "normal" "resize" "search" "move" "prompt" "tmux" {
            bind "s" { SwitchToMode "scroll"; }
          }
          shared_except "locked" "resize" "pane" "tab" "entersearch" "renametab" "renamepane" {
            bind "r" { SwitchToMode "resize"; }
          }
          shared_among "scroll" "search" {
            bind "PageDown" { PageScrollDown; }
            bind "PageUp" { PageScrollUp; }
            bind "left" { PageScrollUp; }
            bind "down" { ScrollDown; }
            bind "up" { ScrollUp; }
            bind "right" { PageScrollDown; }
            bind "Ctrl b" { PageScrollUp; }
            bind "Ctrl c" { ScrollToBottom; SwitchToMode "locked"; }
            bind "d" { HalfPageScrollDown; }
            bind "Ctrl f" { PageScrollDown; }
            bind "h" { PageScrollUp; }
            bind "j" { ScrollDown; }
            bind "k" { ScrollUp; }
            bind "l" { PageScrollDown; }
            bind "u" { HalfPageScrollUp; }
          }
          entersearch {
            bind "Ctrl c" { SwitchToMode "scroll"; }
            bind "esc" { SwitchToMode "scroll"; }
            bind "enter" { SwitchToMode "search"; }
          }
          renametab {
            bind "esc" { UndoRenameTab; SwitchToMode "tab"; }
          }
          shared_among "renametab" "renamepane" {
            bind "Ctrl c" { SwitchToMode "locked"; }
          }
          renamepane {
            bind "esc" { UndoRenamePane; SwitchToMode "pane"; }
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
                mode_locked        "#[fg=#D20F39,bold] ● "
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
                tab_active    "#[fg=#4C4F69,bold,reverse] {name} "
                tab_separator "#[fg=#BCC0CC] • "
              }
            }
          }
        }
      '';
    };
  };
}
