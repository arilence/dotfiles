{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  # Only used for home-manager. The global nixos `config` gets shadowed by home-manager's `config`.
  # This is available to access the global value while nested inside of home-manager.
  nixosConfig = config;

  prismLauncherWithExtraJdks =
    extraJdks:
    pkgs.prismlauncher.overrideAttrs (oldAttrs: {
      # Preserve Prism Launcher's default JDKs and add the requested ones to its search path.
      qtWrapperArgs =
        oldAttrs.qtWrapperArgs
        ++ lib.optionals (extraJdks != [ ]) [
          "--prefix PRISMLAUNCHER_JAVA_PATHS : ${lib.makeSearchPath "bin/java" extraJdks}"
        ];
    });
in
{
  imports = [
    ./disk-config.nix

    ./apps/android.nix
    ./apps/appimage.nix
    ./apps/codex.nix
    ./apps/godot.nix
    ./apps/heroic.nix
    ./apps/kitty.nix
    ./apps/mise.nix
    ./apps/neovim
    ./apps/pia.nix
    ./apps/vscode.nix
    ./apps/wsf.nix
    ./apps/zed-editor.nix
    ./apps/zmx.nix
    ./dev/elixir.nix
    ./modules/nvidia-gpu.nix
    ./modules/scripts.nix
    ./modules/virtual-machines.nix
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

    # Larger buffer just makes download large packages easier
    # And removes the warning "download buffer is full; consider increasing the 'download-buffer-size' setting"
    download-buffer-size = 536870912; # 512 MiB

    extra-substituters = [
      "https://cache.numtide.com"
      "https://codex-desktop-linux.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "codex-desktop-linux.cachix.org-1:nX/xy6AdK9hQE24A8ALGjkCKj2ObFmcnemiL5Cid4nk="
    ];
  };

  boot = {
    consoleLogLevel = 3;

    initrd = {
      systemd.enable = true;
      verbose = false;

      luks = {
        # Better SSD performance
        # Must match the name of the LUKS device in disk-config.nix
        devices."crypted".bypassWorkqueues = true;
        devices."crypted-storage".bypassWorkqueues = true;

        # When using initrd.systemd, this is the default behaviour and will
        # result in an error if explicitely set.
        # Otherwise, enable this to only require entering the password once
        # for multiple disks
        # reusePassphrases = true;
      };
    };

    kernelParams = [
      "quiet"
      "splash"
      # Reduces text spam during boot. Remove this if need to debug boot issues.
      "loglevel=3"
      # As per: https://discourse.nixos.org/t/how-to-configure-a-graphical-boot-screen-with-luks-unlock/63357/5
      # Possibly fixes BIOS crash
      "intremap=on"
      # Misc
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      # Enable zswap, compresses pages inside of ram
      "zswap.enabled=1"
      "zswap.compressor=lz4" # lz4 potentially has less CPU overhead that zstd
      "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
      "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
    ];

    kernel.sysctl = {
      "vm.swappiness" = 35;
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };

    # LUKS password graphical interface
    plymouth = {
      enable = true;
    };
  };

  # Periodically optimises the nix store (cleans up disk usage)
  nix.optimise.automatic = true;
  #nix.optimise.dates = [ "03:45" ];

  # This sets the kernel to the latest, but I ran into compilation issues with
  # the NVIDIA proprietary driver against the bleeding-edge kernels.
  # So we're gonna use the default that nixpkgs provides for now.
  #
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Allows this machine (x86-64) to build aarch64 packages
  # I primarily have this set so I can build NixOS for my Raspberry Pi
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;

  # Sops for secrets
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets.sops.yaml;
  sops.age.generateKey = false;
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

  # Disable hibernation
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };

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
      53317 # LocalSend
      57621 # Spotify
    ];
    allowedUDPPorts = [
      53317 # LocalSend
      5353 # Spotify
    ];
  };

  # Set /storage to world-writable so that the non-root users can access files
  systemd.tmpfiles.rules = [
    # The value of this is important and needs to match the mountpoint of the secondary drive specified in disk-config.nix
    "d /storage 1777 root root -"
  ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.fstrim = {
    enable = true;
    interval = "weekly";
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
          # Use the following command to find the name of .desktop file:
          # ls /run/current-system/sw/share/applications/ | grep -i <appname>
          favorite-apps = [
            "org.gnome.Nautilus.desktop"
            "zen-beta.desktop"
            "obsidian.desktop"
            "todoist.desktop"
            "discord-ptb.desktop"
            "spotify.desktop"
            "feishin.desktop"
            "kitty.desktop"
            "codex-desktop.desktop"
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
        "org/gnome/desktop/peripherals/touchpad" = {
          click-method = "fingers";
          speed = 0.19;
          tap-to-click = true;
          natural-scroll = true;
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
          height-fraction = 1.0;
          extend-height = false;
          dash-max-icon-size = lib.gvariant.mkInt32 48;
          show-running = true;
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
          click-action = "focus-minimize-or-appspread";
        };

        # Desktop Wallpaper
        # TODO: Declaratively set the wallpaper...
        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file:///home/anthony/Pictures/Wallpapers/eric-sloane-connecticut-spring.jpg";
          picture-uri-dark = "file:///home/anthony/Pictures/Wallpapers/eric-sloane-connecticut-spring.jpg";
        };
        "org/gnome/desktop/screensaver" = {
          picture-uri = "file:///home/anthony/Pictures/Wallpapers/eric-sloane-connecticut-spring.jpg";
        };

        # Keybindings
        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = [ "<Control><Alt>h" ];
          toggle-tiled-right = [ "<Control><Alt>l" ];
        };
        "org/gnome/shell/keybindings" = {
          show-screenshot-ui = [ "<Shift><Super>s" ];
          toggle-overview = [ "<Alt>space" ];
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
    nerd-fonts.monaspace
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

  ## Start Programs Section ##

  # https://github.com/NixOS/nixpkgs/issues/149812
  # The issue mentions Plasma but I ran into this issue on GNOME too
  # Fixes error: 'org.gtk.Settings.FileChooser' is not installed
  environment.sessionVariables.XDG_DATA_DIRS = [
    "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # CLI Tools
    nixfmt
    inotify-tools
    eza
    fd
    starship
    wl-clipboard
    cliphist
    fzf
    ripgrep
    dig # nslookup successor
    devcontainer

    # Gui Apps
    gnomeExtensions.appindicator # adds system tray icons to gnome
    gnomeExtensions.dash-to-dock
    kopia-ui # requires ludusavi
    ludusavi # game save backup tool, required by kopia
    awscli2 # for managing s3 server
    versitygw # also for s3 server
    cryptomator
    spotify
    feishin
    moonlight-qt
    code-cursor
    jetbrains.idea
    ghostty
    vlc
    lazygit
    todoist-electron
    meld
    bottles
    localsend # android airdrop
    bruno # rest api client
    itch # itch.io desktop client
    # pureref # reference image organizer (broken on nixos 26.05)
    (obsidian.override {
      # Fixes rendering/performance issues by forcing Wayland
      commandLineArgs = lib.concatStringsSep " " [
        "--ozone-platform=wayland"
        "--enable-wayland-ime=true"
        "--wayland-text-input-version=3"
        "--enable-features=WaylandWindowDecorations"
        "--enable-gpu-rasterization"
        "--ignore-gpu-blocklist"
      ];
    })
    (discord-ptb.override {
      # Fixes rendering/performance issues by forcing Wayland
      commandLineArgs = lib.concatStringsSep " " [
        "--ozone-platform=wayland"
        "--enable-wayland-ime=true"
        "--enable-features=WaylandWindowDecorations"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--ignore-gpu-blocklist"
      ];
    })
    (prismLauncherWithExtraJdks [
      # Add JDK packages not already included by Prism Launcher here.
      # pkgs.jdk11
    ])
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
  programs.steam.protontricks.enable = true;

  ## End Programs Section ##

  ## Start Home Manager ##
  # This should eventually be moved to a separate file
  # A nice tool to search all options: https://home-manager-options.extranix.com/

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.anthony =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        imports = [
          inputs.zen-browser.homeModules.beta
        ];

        # This should probably be set to the same version as the NixOS release
        home.stateVersion = "25.11";

        # Creates home directories like Desktop, Document, Downloads, Pictures, etc.
        xdg.userDirs = {
          enable = true;
          createDirectories = true;
          setSessionVariables = false;
        };
        # This makes them show up in the sidebar of the Nautilus file manager.
        xdg.configFile."gtk-3.0/bookmarks".force = true;
        gtk = {
          enable = true;
          gtk3.bookmarks = [
            "file://${config.home.homeDirectory}/code Code"
            "file://${config.xdg.userDirs.desktop}"
            "file://${config.xdg.userDirs.documents}"
            "file://${config.xdg.userDirs.download}"
            "file://${config.xdg.userDirs.pictures}"
            "file://${config.xdg.userDirs.music}"
            "smb://10.0.10.10/files/ NAS Files"
            "smb://10.0.10.10/media/ NAS Media"
          ];
        };

        editorconfig = {
          enable = true;
          settings = {
            "*" = {
              charset = "utf-8";
              end_of_line = "lf";
              indent_size = 2;
              indent_style = "space";
              insert_final_newline = true;
              trim_trailing_whitespace = true;
            };

            "Makefile" = {
              indent_style = "tab";
            };

            "*.rs" = {
              charset = "utf-8";
              end_of_line = "lf";
              indent_size = 4;
              indent_style = "space";
              insert_final_newline = true;
              max_line_length = 100;
              trim_trailing_whitespace = true;
            };

            "*.{ex,exs,heex,eex,leex}" = {
              indent_size = 2;
              indent_style = "space";
            };

            "*.yml" = {
              indent_size = 2;
              indent_style = "space";
            };

            "*.{md,markdown,txt}" = {
              indent_style = "space";
              trim_trailing_whitespace = false;
            };
          };
        };

        programs.ssh = {
          enable = true;
          # Lets us use 1Password with SSH
          extraConfig = ''
            Host *
              IdentityAgent ~/.1password/agent.sock
          '';
          includes = [
            nixosConfig.sops.secrets.ssh-extra-config.path
          ];
          # default values is being deprecated
          enableDefaultConfig = false;
          # this is the current value of what enableDefaultConfig does
          settings."*" = {
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
            env_var.ZMX_SESSION = {
              format = "[zmx:$env_value]($style) ";
              style = "bold yellow";
            };
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
          clearDefaultKeybinds = true;
          settings = {
            theme = "dark:TokyoNight Moon,light:Catppuccin Latte";
            font-family = "MonaspiceNe Nerd Font Mono";
            # Disables font ligatures
            font-feature = "-calt, -liga, -dlig";
            # Fixes `WARNING: terminal is not fully functional` when using SSH
            # See: https://ghostty.org/docs/help/terminfo#ssh
            shell-integration-features = "ssh-env";
            window-width = 120;
            window-height = 40;
            cursor-style = "block";
            # Disable dimming unfocused splits
            unfocused-split-opacity = 1;
            keybind = [
              "ctrl+shift+c=copy_to_clipboard"
              "copy=copy_to_clipboard"
              "ctrl+shift+v=paste_from_clipboard"
              "paste=paste_from_clipboard"
              "ctrl+|=new_split:right"
              "ctrl+shift+-=new_split:down"
              "ctrl+shift+t=new_tab"
              "alt+1=goto_tab:1"
              "alt+2=goto_tab:2"
              "alt+3=goto_tab:3"
              "alt+4=goto_tab:4"
              "alt+5=goto_tab:5"
              "alt+6=goto_tab:6"
              # TODO: Figure out how to achieve something like
              # smart-splits.nvim or vim-tmux-navigator within Ghostty
              "performable:ctrl+h=goto_split:left"
              "performable:ctrl+j=goto_split:down"
              "performable:ctrl+k=goto_split:up"
              "performable:ctrl+l=goto_split:right"
            ];
          };
        };

        programs.lazygit = {
          enable = true;
          enableZshIntegration = true;
          settings = {
            promptToReturnFromSubprocess = false;
          };
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
            # Tells shell to expand any aliases when using sudo. To be honest I don't get why this works.
            # But without this, I can't use `sudo vim` because root doesn't have the same aliases.
            sudo = "sudo "; # trailing space is intentional

            ls = "eza --group-directories-first";
            vim = "nvim";
            lg = "lazygit";
            gs = "git status";
            gc = "git commit";
            ga = "git add";
            gd = "git diff";
            gl = "git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            start = "xdg-open";
            open = "xdg-open";
            c = "code";
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
            export SOPS_AGE_KEY_CMD='op read "op://Personal/3sspl4mcj6marm3iugininsub4/AGE Secret Key"'
          '';

          siteFunctions = {
            # "nix develop" uses bash by default, this changes it to use $SHELL
            # NOTE: this may cause issues in the future if a nix develop setup expects Bash
            nix = ''
              if [[ "$1" == "develop" ]]; then
                shift
                local zsh_path=$(which zsh)
                # We tell nix develop to export the variable AND then exec zsh
                # Otherwise nix develop starts in zsh but with $SHELL set to bash
                command nix develop "$@" -c env SHELL="$zsh_path" zsh
              else
                command nix "$@"
              fi
            '';

            # "nix-shell" uses bash by default, this changes it to use $SHELL
            # NOTE: this may cause issues in the future if a nix-shell setup expects Bash
            nix-shell = ''
              local zsh_path=$(which zsh)
              # We tell nix-shell to export the variable AND then exec zsh
              # Otherwise nix-shell starts in zsh but with $SHELL set to bash
              command nix-shell "$@" --command "export SHELL=$zsh_path; exec zsh"
            '';

            # Fixes "'xterm-kitty': unknown terminal type" on remote SSH sessions.
            # Similar to Ghostty's "shell-integration-features = ssh-env"
            # See: https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-or-functional-keys-like-arrow-keys-don-t-work
            ssh = ''
              if [[ "$TERM" == "xterm-kitty" ]]; then
                if command -v kitten >/dev/null 2>&1; then
                  command kitten ssh "$@"
                else
                  TERM=xterm-256color command ssh "$@"
                fi
              else
                command ssh "$@"
              fi
            '';
          };
        };

        programs.git = {
          enable = true;
          includes = [
            # I may want to setup sops-nix within home-manager to symlink this locally
            # Instead of it being in /run/secrets
            { path = nixosConfig.sops.secrets.git-options.path; }
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
            merge.conflictStyle = "zdiff3";
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

        # "Better" Git diff viewer
        programs.delta = {
          enable = true;
          enableGitIntegration = true;
          options = {
            line-numbers = true;
            hyperlinks = true;
            hyperlinks-file-link-format = "vscode://file/{path}:{line}";
          };
        };

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
              # Start NVIDIA Hardware Acceleration
              # These prefs are required when using NVIDIA for HW Accel
              # See: https://wiki.nixos.org/wiki/Accelerated_Video_Playback#NVIDIA
              "media.ffmpeg.vaapi.enabled" = {
                Value = true;
                Locked = true;
              };
              "media.hardware-video-decoding.force-enabled" = {
                Value = true;
                Locked = true;
              };
              "media.rdd-ffmpeg.enabled" = {
                Value = true;
                Locked = true;
              };
              "gfx.x11-egl.force-enabled" = {
                Value = true;
                Locked = true;
              };
              "widget.dmabuf.force-enabled" = {
                Value = true;
                Locked = true;
              };
              # Enable this if your GPU supports AV1, my GTX 1060 does not
              "media.av1.enabled" = {
                Value = false;
                Locked = true;
              };
              # End NVIDIA Hardware Acceleration
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

        xdg.mimeApps =
          let
            textEditor = "org.gnome.TextEditor.desktop";
            textFileMimeTypes = [
              "application/json"
              "application/toml"
              "application/x-shellscript"
              "application/x-yaml"
              "application/yaml"
              "text/csv"
              "text/markdown"
              "text/plain"
              "text/x-markdown"
              "text/yaml"
            ];
          in
          {
            # Zen can set itself as the default browser but it won't work without setting
            # `xdg.mimeApps.enable` = true even when `programs.zen-browser.setAsDefaultBrowser` is true.
            enable = true;

            # For some reason Zen overwrites opening plain text files, where I still want them to
            # open in Text Editor.
            defaultApplications = lib.genAttrs textFileMimeTypes (_: textEditor);
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
