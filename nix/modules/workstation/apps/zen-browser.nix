{ inputs, ... }:

{
  environment.etc."1password/custom_allowed_browsers" = {
    # Zen must be explicitly allowed to be used with 1Password
    text = ''
      zen
      zen-beta
      .zen
      .zen-wrapped
      .zen-beta
      .zen-wrapped
    '';
    mode = "0755";
  };

  home-manager.users.anthony =
    {
      config,
      pkgs,
      ...
    }:
    let
      zenUrlbarKeybindingsConfig = pkgs.writeText "zen-urlbar-keybindings.cfg" ''
        // Use Vim-style navigation while the URL bar results are open.
        pref("anthony.zen.urlbar-keybindings.config-loaded", true);

        if (!Services.appinfo.inSafeMode) {
          Services.console.logStringMessage(
            "[zen-urlbar-keybindings] config loaded"
          );

          const urlbarKeybindings = {
            observe(window) {
              window.addEventListener(
                "load",
                (event) => {
                  const browserWindow = event.target.defaultView;
                  if (
                    browserWindow.location.href !==
                      "chrome://browser/content/browser.xhtml" ||
                    !browserWindow.gURLBar?.controller
                  ) {
                    return;
                  }

                  const controller = browserWindow.gURLBar.controller;
                  const handleKeyNavigation =
                    controller.handleKeyNavigation;

                  controller.handleKeyNavigation = function (
                    keyEvent,
                    executeAction = true
                  ) {
                    if (
                      this.view.isOpen &&
                      keyEvent.ctrlKey &&
                      !keyEvent.altKey &&
                      !keyEvent.metaKey &&
                      !keyEvent.shiftKey &&
                      (keyEvent.key === "j" || keyEvent.key === "k")
                    ) {
                      if (executeAction) {
                        this.userSelectionBehavior = "arrow";
                        this.view.selectBy(1, {
                          reverse: keyEvent.key === "k",
                        });
                      }
                      keyEvent.preventDefault();
                      return;
                    }

                    return handleKeyNavigation.call(
                      this,
                      keyEvent,
                      executeAction
                    );
                  };
                },
                { once: true }
              );
            },
          };

          Services.obs.addObserver(
            urlbarKeybindings,
            "chrome-document-global-created"
          );
        }
      '';

      zenAutoconfigPrefs = pkgs.writeText "zen-autoconfig-prefs.js" ''
        pref("anthony.zen.urlbar-keybindings.bootstrap-loaded", true);
        pref("general.config.filename", "zen-urlbar.cfg");
        pref("general.config.obscure_value", 0);
        pref("general.config.sandbox_enabled", false);
      '';
    in
    {
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;
        nativeMessagingHosts = [ pkgs.firefoxpwa ];
        policies = {
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DontCheckDefaultBrowser = true;
          OfferToSaveLogins = false;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          SanitizeOnShutdown = {
            FormData = true;
            Cache = true;
          };
          Preferences = {
            "gfx.webrender.all" = {
              Value = true;
              Locked = true;
            };
          };
        };
        profiles.default = {
          settings = {
            "zen.view.sidebar-expanded" = true;
            "zen.view.use-single-toolbar" = false;
            "zen.urlbar.behavior" = "float";
            "zen.mediacontrols.enabled" = false;
          };
          # Find shortcut IDs in ~/.config/zen/default/zen-keyboard-shortcuts.json
          # Get version from about:config -> zen.keyboard.shortcuts.version
          # Activation fails if version changes (prevents silent breakage).
          #
          # Use this command:
          # jq -c '.shortcuts[] | {id, key, keycode, action}' ~/.config/zen/default/zen-keyboard-shortcuts.json | fzf
          keyboardShortcuts = [
            {
              id = "zen-compact-mode-toggle";
              key = "[";
              modifiers = {
                accel = true;
              };
            }
          ];
          # In order to avoid breaking changes here, sometimes when you upgrade you should be asked
          # to bump this version
          keyboardShortcutsVersion = 19;
        };

        # HACK: This is a hack to add keybindings to the URL bar.
        # Zen's declarative keyboardShortcuts only remap global commands. URL result navigation is
        # handled by the browser UI. Zen resolves its executable symlink before looking up
        # defaults/pref, so the autoconfig files must be added to the unwrapped package.
        package =
          let
            zenConfig = config.programs.zen-browser;
            zenBase = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta-unwrapped.override {
              inherit (zenConfig) policies enablePrivateDesktopEntry;
            };
            zen = zenBase.overrideAttrs (oldAttrs: {
              postInstall = (oldAttrs.postInstall or "") + ''
                chmod u+w \
                  "$out/lib/${zenBase.libName}" \
                  "$out/lib/${zenBase.libName}/defaults" \
                  "$out/lib/${zenBase.libName}/defaults/pref"
                install -m644 ${zenUrlbarKeybindingsConfig} \
                  "$out/lib/${zenBase.libName}/zen-urlbar.cfg"
                install -m644 ${zenAutoconfigPrefs} \
                  "$out/lib/${zenBase.libName}/defaults/pref/config-prefs.js"
              '';
            });
          in
          pkgs.wrapFirefox zen {
            icon = "zen-browser";
            inherit (zenConfig) nativeMessagingHosts;
            extraPolicies = zenConfig.policies;
          };
      };

      # Zen can set itself as the default browser but it won't work without setting
      # `xdg.mimeApps.enable` = true even when `programs.zen-browser.setAsDefaultBrowser` is true.
      xdg.mimeApps.enable = true;
    };
}
