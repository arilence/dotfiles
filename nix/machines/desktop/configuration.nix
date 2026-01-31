{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    ./disk-config.nix
    ./apps/mise.nix
    ./dev/elixir.nix
    ./apps/neovim
    ./apps/zed-editor.nix
    ./apps/android.nix
    ./apps/godot.nix
  ];

  nix.settings = {
    # Let's us rebuild remotely using additional users
    # Potentially dangerous
    trusted-users = [
      "root"
      "anthony"
    ];

    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    # Reduces text spam during boot. Remove this if need to debug boot issues.
    "loglevel=3"
    "quiet"
    # Enables ZSwap to compress portions of ram before it is swapped to disk
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.max_pool_percent=20"
    "zswap.shrinker_enabled=1"
  ];
  boot.kernel.sysctl = {
    "vm.swappiness" = 35;
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Better SSD performance
  # Must match the name of the LUKS device in disk-config.nix
  boot.initrd.luks.devices."crypted".bypassWorkqueues = true;

  # Sops for secrets
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets.sops.yaml;
  sops.age.generateKey = true;
  sops.secrets.user-password.neededForUsers = true;
  sops.secrets.git-options = {
    mode = "0444";
  };
  sops.secrets.ssh-extra-config = {
    mode = "0444";
  };
  sops.secrets.syncthing-gui-password = {
    mode = "0444";
  };
  sops.secrets.syncthing-key = {
    mode = "0444";
  };
  sops.secrets.syncthing-cert = {
    mode = "0444";
  };
  sops.secrets.syncthing-untrusted-device-password = {
    mode = "0444";
  };

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "anthony-desktop";

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.autoSuspend = false;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.anthony = {
    isNormalUser = true;
    description = "Anthony Smith";
    hashedPasswordFile = config.sops.secrets.user-password.path;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      # personal key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICji8slXLeYN6Zody5rqrVilgmt8RiGfVkr777WYNm1A"
    ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      challengeResponseAuthentication = false;
    };
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';
  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # SSH
      57621 # Spotify
    ];
    allowedUDPPorts = [
      5353 # Spotify
    ];
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.flatpak.enable = true;

  services.syncthing = {
    enable = true;
    dataDir = "/home/anthony";
    configDir = "/home/anthony/.local/state/syncthing";
    user = "anthony";
    key = config.sops.secrets.syncthing-key.path;
    cert = config.sops.secrets.syncthing-cert.path;
    guiPasswordFile = config.sops.secrets.syncthing-gui-password.path;
    openDefaultPorts = true;
    overrideFolders = true;
    overrideDevices = true;
    settings = {
      gui = {
        user = "anthony";
      };
      devices = {
        "anthony-lt" = {
          id = "PALIULZ-KG5PMCV-2JBB7EY-AONGCPR-7ECDILT-KFDSWSQ-JOMKDQT-4UKERA4";
        };
        "anthony-phone" = {
          id = "7OR6DQX-QLG6LKG-MGWC3CF-6HOC2RC-CN42TRC-QWW2OVM-ML7CSTN-I2F6DA5";
        };
        "app-platform" = {
          id = "GRZAOW2-SUEULUK-CE7IZ6S-Z7KVQG5-JU2ITIF-YP2ICKR-M46DM5F-7FVACAY";
        };
      };
      folders = {
        "Digital Garden" = {
          id = "xxs3w-cfqrj";
          path = "/home/anthony/Digital Garden";
          devices = [
            "anthony-lt"
            "anthony-phone"
            # App-platform should only have an encrypted copy of this data
            {
              name = "app-platform";
              encryptionPasswordFile = config.sops.secrets.syncthing-untrusted-device-password.path;
            }
          ];
        };
      };
    };
  };

  # Configure GNOME settings
  programs.dconf.profiles.user.databases = [
    {
      lockAll = true; # prevents overriding
      settings = {
        "org/gnome/mutter" = {
          experimental-features = [
            "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
            "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
            "autoclose-xwayland" # automatically terminates Xwayland if all relevant X11 clients are gone
          ];
        };
        "org/gnome/shell" = {
          last-selected-power-profile = "performance";
          disable-user-extensions = false;
          disabled-extensions = "disabled";
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "dash-to-dock@micxgx.gmail.com"
          ];
          # Sets the apps to show in the "dock"
          favorite-apps = [
            "org.gnome.Nautilus.desktop"
            "zen-beta.desktop"
            "com.mitchellh.ghostty.desktop"
            "obsidian.desktop"
            "todoist.desktop"
            "discord-ptb.desktop"
            "spotify.desktop"
          ];
        };
        "org/gnome/desktop/session" = {
          idle-delay = lib.gvariant.mkUint32 0; # Disable screen timeout
        };
        "org/gnome/desktop/interface" = {
          enable-hot-corners = false;
          clock-show-date = true;
          clock-show-weekday = true;
        };
        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          speed = 0.35;
        };
        "org/gtk/settings/file-chooser" = {
          clock-format = "24h";
        };
        "org/gnome/nautilus/preferences" = {
          show-image-thumbnails = "always";
        };
        "org/gnome/shell/extensions/dash-to-dock" = {
          multi-monitor = false;
          dock-position = "BOTTOM";
          intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
          height-fraction = 0.9;
          extend-height = false;
          dash-max-icon-size = lib.gvariant.mkUint32 64;
          isolate-workspaces = false;
          custom-theme-shrink = false;
          disable-overview-on-startup = true;
          apply-custom-theme = false;
          hot-keys = false;
          dock-fixed = false;
          require-pressure-to-show = true;
          intellihide = true;
          show-mounts-network = false;
          show-mounts-only-mounted = true;
        };

        # Keybindings
        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = [ "<Control><Alt>h" ];
          toggle-tiled-right = [ "<Control><Alt>l" ];
        };
        "org/gnome/shell/keybindings" = {
          show-screenshot-ui = [ "<Shift><Super>s" ];
        };
        "org/gnome/desktop/wm/keybindings" = {
          # Disable default keybindings
          activate-window-menu = [ "disable" ];
          begin-move = [ "disable" ];
          begin-resize = [ "disable" ];
          minimize = [ "disable" ];
          toggle-maximized = [ "disable" ];
          switch-applications = [ "disable" ];
          switch-applications-backward = [ "disable" ];
          # Customize keybindings
          maximize = [ "<Control><Alt>k" ];
          unmaximize = [ "<Control><Alt>j" ];
          move-to-center = [ "<Control><Alt>space" ];
          switch-windows = [ "<Alt>Tab" ];
          switch-windows-backward = [ "<Shift><Alt>Tab" ];
        };
      };
    }
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.geist-mono
  ];

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    daemon.settings = {
      default-address-pools = [
        {
          base = "172.17.0.0/12";
          size = 20;
        }
      ];
    };
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
  # Disable docker from starting on boot
  systemd.services.docker.wantedBy = lib.mkForce [ ];
  systemd.sockets.docker.wantedBy = lib.mkForce [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  ## Start NVIDIA Stuff ##
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Use the Nvidia open source kernel module.
    # Must be set to false with my old GTX 1060, otherwise it should be set to true for newer GPUs.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  ## End NVIDIA Stuff ##

  ## Start Programs Section ##

  # This is a workaround to allow programs that need dynamic libraries to work
  # Such as: Mise, Handy.Computer, etc.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  environment.systemPackages = with pkgs; [
    # CLI Tools
    nixfmt-rfc-style
    inotify-tools
    eza
    fd
    starship
    wl-clipboard
    cliphist
    ydotool # for most STT tools
    fzf
    dig # nslookup successor
    claude-code

    # Gui Apps
    gnomeExtensions.appindicator # adds system tray icons to gnome
    gnomeExtensions.dash-to-dock
    kopia-ui
    awscli2 # for managing s3 server
    versitygw # also for s3 server
    discord-ptb
    spotify
    feishin
    moonlight-qt
    code-cursor
    jetbrains.idea
    obsidian
    ghostty
    vlc
    lazygit
    todoist-electron
    zellij
    meld
    gearlever # appimage launcher
    bottles
    localsend # android airdrop
    bruno # rest api client
    (prismlauncher.override (default: {
      # According to the wiki, Prism Launcher already comes with JDK 8, 17, and 21
      # Is there a way to only provide the ones we want in addition to that?
      # Rather than having to list all of them.
      jdks = [
        pkgs.jdk8
        pkgs.jdk17
        pkgs.jdk21
        pkgs.jdk25
      ];
    }))
  ];

  # This also needs to be set as the user's default shell in the user section
  programs.zsh.enable = true;

  programs.firefox.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "anthony" ];
  };
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

  programs.steam.enable = true;

  programs.talon.enable = true;

  ## End Programs Section ##

  ## Start Home Manager ##
  # This should eventually be moved to a separate file

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.anthony =
      { pkgs, lib, ... }:
      {
        imports = [
          inputs.zen-browser.homeModules.beta
          ./dotfiles.nix
        ];

        # This should probably be set to the same version as the NixOS release
        home.stateVersion = "25.11";

        programs.ssh = {
          enable = true;
          # Lets us use 1Password with SSH
          extraConfig = ''
            Host *
              IdentityAgent ~/.1password/agent.sock
          '';
          includes = [
            config.sops.secrets.ssh-extra-config.path
          ];
          # default values is being deprecated
          enableDefaultConfig = false;
          # this is the current value of what enableDefaultConfig does
          matchBlocks."*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };
        };

        programs.zoxide = {
          enable = true;
          enableZshIntegration = true;
          options = [ "--cmd j" ];
        };

        programs.starship = {
          enable = true;
          enableZshIntegration = true;
          settings = {
            add_newline = false;
          };
        };

        programs.atuin = {
          enable = true;
          enableZshIntegration = true;
          flags = [ "--disable-up-arrow" ];
        };

        programs.ghostty = {
          enable = true;
          enableZshIntegration = true;
          settings = {
            font-family = "GeistMono Nerd Font Mono";
            # Fixes `WARNING: terminal is not fully functional` when using SSH
            # See: https://ghostty.org/docs/help/terminfo#ssh
            shell-integration-features = "ssh-env";
            window-width = 120;
            window-height = 40;
          };
        };

        programs.lazygit = {
          enable = true;
          enableZshIntegration = true;
        };

        programs.zellij = {
          enable = true;
          enableZshIntegration = false;
        };

        programs.fzf = {
          enable = true;
          enableZshIntegration = true;
          defaultCommand = "FZF_CTRL_T_COMMAND='' fd --type f";
        };

        programs.zsh = {
          enable = true;
          enableCompletion = true;
          autocd = true;

          shellAliases = {
            ls = "eza --group-directories-first";
            vim = "nvim";
            lg = "lazygit";
            gs = "git status";
            gc = "git commit";
            ga = "git add";
            gd = "git diff";
            gl = "git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            t = "zellij attach --create";
            tn = "zellij";
            tl = "zellij list-sessions";
            tk = "zellij kill-session";
            tdd = "zellij delete-all-sessions";
            start = "xdg-open";
            open = "xdg-open";
            nixd = "nix develop -c $SHELL";
          };

          initContent = lib.mkOrder 1200 ''
            # auto-complete ".." into "../"
            zstyle ':completion:*' special-dirs true

            ## case insensitive path-completion
            zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
            zstyle ':completion:*' menu select
          '';

          envExtra = ''
            export EDITOR='nvim'
            export VISUAL='nvim'
            export LANG='en_US.UTF-8'
          '';
        };

        programs.git = {
          enable = true;
          includes = [
            # I may want to setup sops-nix within home-manager to symlink this locally
            # Instead of it being in /run/secrets
            { path = config.sops.secrets.git-options.path; }
          ];
          settings = {
            user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICji8slXLeYN6Zody5rqrVilgmt8RiGfVkr777WYNm1A";
            init.defaultBranch = "main";
            pull.ff = "only";
            commit.gpgsign = true;
            commit.verbose = true;
            gpg.format = "ssh";
            column.ui = "auto";
            branch.sort = "-committerdate";
            tag.sort = "version:refname";
            diff.algorithm = "histogram";
            diff.colorMoved = "plain";
            diff.mnemonicprefix = true;
            diff.renames = true;
            push.default = "simple";
            push.autoSetupRemote = true;
            push.followTags = true;
            fetch.prune = true;
            fetch.pruneTags = true;
            fetch.all = true;
            help.autocorrect = "prompt";
            rebase.autoSquash = true;
            rebase.autoStash = true;
            rebase.updateRefs = true;
            # TODO: this breaks installing packages through rust cargo
            url."git@github.com:".insteadOf = [
              "https://github.com/"
              "git://github.com/"
              "github:"
            ];
            gpg."ssh".program = "${pkgs._1password-gui}/bin/op-ssh-sign";
          };
        };

        programs.zen-browser = {
          enable = true;
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
            };
          };
        };

        # Set Zen as the default browser
        xdg.configFile."mimeapps.list".force = true;
        xdg.mimeApps =
          let
            # options for system are: 'x86_64-linux', 'aarch64-linux' and 'aarch64-darwin'
            value =
              let
                zen-browser = inputs.zen-browser.packages.x86_64-linux.beta;
              in
              zen-browser.meta.desktopFileName;

            associations = builtins.listToAttrs (
              map
                (name: {
                  inherit name value;
                })
                [
                  "application/x-extension-shtml"
                  "application/x-extension-xhtml"
                  "application/x-extension-html"
                  "application/x-extension-xht"
                  "application/x-extension-htm"
                  "x-scheme-handler/unknown"
                  "x-scheme-handler/mailto"
                  "x-scheme-handler/chrome"
                  "x-scheme-handler/about"
                  "x-scheme-handler/https"
                  "x-scheme-handler/http"
                  "application/xhtml+xml"
                  "application/json"
                  "text/plain"
                  "text/html"
                ]
            );
          in
          {
            associations.added = associations;
            defaultApplications = associations;
            enable = true;
          };

        xdg.configFile = {
          # Autostart apps on login
          "autostart/1password.desktop" = {
            text = ''
              [Desktop Entry]
              Name=1Password
              Exec=${pkgs._1password-gui}/bin/1password --silent
              Terminal=false
              Type=Application
              Icon=1password
              StartupWMClass=1Password
              Comment=Password manager and secure wallet
              MimeType=x-scheme-handler/onepassword;x-scheme-handler/onepassword8;
              Categories=Office;
            '';
          };

          "autostart/kopia-ui.desktop" = {
            text = ''
              [Desktop Entry]
              Name=Kopia
              Exec=${pkgs.kopia-ui}/bin/kopia-ui
              Terminal=false
              Type=Application
              Icon=kopia
              Comment=Backup and restore tool
              Categories=Utility;Archiving;
            '';
          };
        };

        services.cliphist = {
          enable = true;
        };

      };
  };
  ## End Home Manager ##
}
