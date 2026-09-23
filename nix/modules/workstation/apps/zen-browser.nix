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

      mkExtensionSettings = builtins.mapAttrs (
        _: addonSlug: {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${addonSlug}/latest.xpi";
          installation_mode = "force_installed";
        }
      );
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
          ExtensionSettings = mkExtensionSettings {
            "{d634138d-c276-4fc8-924b-40a0ea21d284}" = "1password-x-password-manager";
            # "{ab779d78-7270-4ee8-9ee8-369d73508298}" = "arxiv-utils";
            "frankerfacez@frankerfacez.com" = "frankerfacez";
            "search@kagi.com" = "kagi-search-for-firefox";
            # "team@readwise.io" = "readwise-highlighter";
            "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = "refined-github-";
            # "{531906d3-e22f-4a6c-a102-8057b88a1a63}" = "single-file";
            "firefox-extension@steamdb.info" = "steam-database";
            "uBlock0@raymondhill.net" = "ublock-origin";
            # "{88664789-f91e-40e1-adb9-e4e9a8c48867}" = "urls-list";
            # "{799c0914-748b-41df-a25c-22d008f9e83f}" = "web-scrobbler";
          };
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
            "media.suspend-background-video.enabled" = false;
            "services.sync.engine.spaces" = true;
            "zen.view.sidebar-expanded" = true;
            "zen.view.use-single-toolbar" = false;
            "zen.urlbar.behavior" = "float";
            "zen.mediacontrols.enabled" = false;
          };
          extensionButtons."nav-bar" = [
            "search@kagi.com" # Kagi Search for Firefox
            "{d634138d-c276-4fc8-924b-40a0ea21d284}" # 1Password
            "team@readwise.io" # Readwise Highlighter
          ];
          mods = [
            "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
            "ad97bb70-0066-4e42-9b5f-173a5e42c6fc" # SuperPins
          ];
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
            # Firefox also assigns Ctrl+[ to its secondary Back shortcut. Having both
            # active makes Zen's shortcut ordering decide which command wins.
            {
              id = "goBackKb2";
              disabled = true;
            }
          ];
          # In order to avoid breaking changes here, sometimes when you upgrade you should be asked
          # to bump this version
          keyboardShortcutsVersion = 20;
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
