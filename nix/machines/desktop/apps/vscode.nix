{ pkgs, inputs, ... }:

{
  home-manager.users.anthony.programs.vscode = {
    enable = true;
    # This needs to stay mutable so additional extensions not available on nixpkgs can be installed
    mutableExtensionsDir = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # Not all extensions are available in the nixpkgs repository unfortunately
        editorconfig.editorconfig
        vscodevim.vim
        jnoortheen.nix-ide

        # Extensions that are not available in the nixpkgs repository
        #apust.rubber-theme
        #tonsky.theme-alabaster
        #hverlin.mise-vscode
        #tombi-toml.tombi # primarily for mise
        #anthropic.claude-code
      ];
      userSettings = {
        "[typescriptreact]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[jsonc]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "chat.commandCenter.enabled" = false;
        "editor.fontFamily" = "GeistMono Nerd Font Mono, Consolas, 'Courier New', monospace";
        "editor.formatOnSave" = true;
        "editor.lineNumbers" = "relative";
        "editor.renderWhitespace" = "trailing";
        "editor.rulers" = [
          80
          120
        ];
        "editor.wordWrap" = "off";
        "explorer.confirmDelete" = false;
        "extensions.ignoreRecommendations" = true;
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.commandsToSkipShell" = [
          "workbench.action.toggleSidebarVisibility"
          "workbench.action.toggleAuxiliaryBar"
        ];
        "terminal.integrated.defaultLocation" = "editor";
        "terminal.integrated.defaultProfile.linux" = "zsh";
        "terminal.integrated.defaultProfile.windows" = "PowerShell";
        "terminal.integrated.fontFamily" = "GeistMono Nerd Font Mono, Consolas, 'Courier New', monospace";
        "update.showReleaseNotes" = false;
        "window.autoDetectColorScheme" = true;
        "window.restoreWindows" = "none";
        "window.zoomLevel" = 1;
        "workbench.activityBar.location" = "top";
        "workbench.colorTheme" = "Alabaster";
        "workbench.editor.empty.hint" = "hidden";
        "workbench.preferredDarkColorTheme" = "Rubber";
        "workbench.preferredLightColorTheme" = "Alabaster";
        "workbench.sideBar.location" = "right";
        "workbench.startupEditor" = "none";
        "workbench.tips.enabled" = false;

        # Extension related settings
        "mise.configureExtensionsAutomatically" = false;
        "claudeCode.preferredLocation" = "panel";
      };
      keybindings = [
        {
          key = "ctrl+[";
          command = "workbench.action.toggleAuxiliaryBar";
        }
        {
          key = "ctrl+b";
          command = "-workbench.action.toggleSidebarVisibility";
        }
        {
          key = "ctrl+]";
          command = "workbench.action.toggleSidebarVisibility";
        }
        {
          key = "ctrl+alt+b";
          command = "-workbench.action.toggleAuxiliaryBar";
        }
        {
          key = "shift+,";
          command = "editor.action.outdentLines";
          when = "editorTextFocus && !editorReadonly && vim.mode == 'Normal'";
        }
        {
          key = "ctrl+[";
          command = "-editor.action.outdentLines";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "shift+.";
          command = "editor.action.indentLines";
          when = "editorTextFocus && !editorReadonly && vim.mode == 'Normal'";
        }
        {
          key = "ctrl+]";
          command = "-editor.action.indentLines";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "ctrl+j";
          command = "workbench.action.quickOpenSelectNext";
          when = "inQuickInput";
        }
        {
          key = "ctrl+k";
          command = "workbench.action.quickOpenSelectPrevious";
          when = "inQuickInput";
        }
        {
          key = "ctrl+j";
          command = "-workbench.action.togglePanel";
        }
        {
          key = "ctrl+p";
          command = "-extension.vim_ctrl+p";
          when = "editorTextFocus && vim.active && vim.use<C-p> && !inDebugRepl || vim.active && vim.use<C-p> && !inDebugRepl && vim.mode == 'CommandlineInProgress' || vim.active && vim.use<C-p> && !inDebugRepl && vim.mode == 'SearchInProgressMode'";
        }
        {
          key = "ctrl+j";
          command = "workbench.action.navigateDown";
          when = "!inQuickInput";
        }
        {
          key = "ctrl+k";
          command = "workbench.action.navigateUp";
          when = "!inQuickInput";
        }
        {
          key = "ctrl+h";
          command = "workbench.action.navigateLeft";
          when = "!inQuickInput";
        }
        {
          key = "ctrl+l";
          command = "workbench.action.navigateRight";
          when = "!inQuickInput";
        }
        {
          key = "cmd+b";
          command = "workbench.action.debug.start";
          when = "debuggersAvailable && debugState == 'inactive'";
        }
        {
          key = "cmd+b";
          command = "-workbench.action.toggleSidebarVisibility";
        }
        {
          key = "ctrl+j";
          command = "selectNextSuggestion";
          when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus || suggestWidgetVisible && textInputFocus && !suggestWidgetHasFocusedSuggestion";
        }
        {
          key = "ctrl+k";
          command = "selectPrevSuggestion";
          when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus || suggestWidgetVisible && textInputFocus && !suggestWidgetHasFocusedSuggestion";
        }
        {
          key = "ctrl+1";
          command = "-workbench.action.focusFirstEditorGroup";
        }
        {
          key = "ctrl+1";
          command = "workbench.action.openEditorAtIndex1";
        }
        {
          key = "ctrl+2";
          command = "-workbench.action.focusSecondEditorGroup";
        }
        {
          key = "ctrl+2";
          command = "workbench.action.openEditorAtIndex2";
        }
        {
          key = "ctrl+3";
          command = "-workbench.action.focusThirdEditorGroup";
        }
        {
          key = "ctrl+3";
          command = "workbench.action.openEditorAtIndex3";
        }
        {
          key = "ctrl+4";
          command = "-workbench.action.focusFourthEditorGroup";
        }
        {
          key = "ctrl+4";
          command = "workbench.action.openEditorAtIndex4";
        }
        {
          key = "ctrl+5";
          command = "-workbench.action.focusFifthEditorGroup";
        }
        {
          key = "ctrl+5";
          command = "workbench.action.openEditorAtIndex5";
        }
        {
          key = "ctrl+6";
          command = "-workbench.action.focusSixthEditorGroup";
        }
        {
          key = "ctrl+6";
          command = "workbench.action.openEditorAtIndex6";
        }
        {
          key = "meta+1";
          command = "-workbench.action.focusFirstEditorGroup";
        }
        {
          key = "meta+1";
          command = "workbench.action.openEditorAtIndex1";
        }
        {
          key = "meta+2";
          command = "-workbench.action.focusSecondEditorGroup";
        }
        {
          key = "meta+2";
          command = "workbench.action.openEditorAtIndex2";
        }
        {
          key = "meta+3";
          command = "-workbench.action.focusThirdEditorGroup";
        }
        {
          key = "meta+3";
          command = "workbench.action.openEditorAtIndex3";
        }
        {
          key = "meta+4";
          command = "-workbench.action.focusFourthEditorGroup";
        }
        {
          key = "meta+4";
          command = "workbench.action.openEditorAtIndex4";
        }
        {
          key = "meta+5";
          command = "-workbench.action.focusFifthEditorGroup";
        }
        {
          key = "meta+5";
          command = "workbench.action.openEditorAtIndex5";
        }
        {
          key = "meta+6";
          command = "-workbench.action.focusSixthEditorGroup";
        }
        {
          key = "meta+6";
          command = "workbench.action.openEditorAtIndex6";
        }
        {
          key = "meta+w";
          command = "-extension.vim_ctrl+w";
          when = "editorTextFocus && vim.active && vim.use<C-w> && !inDebugRepl";
        }
      ];
    };
  };
}
