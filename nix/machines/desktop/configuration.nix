{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./disk-config.nix
  ];

  # Let's us rebuild remotely using additional users
  # Potentially dangerous
  nix.settings.trusted-users = [
    "root"
    "anthony"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    # Reduces text spam during boot. Remove this if need to debug boot issues.
    "loglevel=3"
    "quiet"
  ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Better SSD performance
  # Must match the name of the LUKS device in disk-config.nix
  boot.initrd.luks.devices."crypted".bypassWorkqueues = true;

  # Sops for secrets
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets.sops.yaml;
  sops.age.generateKey = true;
  sops.secrets.user_password.neededForUsers = true;
  sops.secrets.git_options = {
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
    hashedPasswordFile = config.sops.secrets.user_password.path;
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

  environment.systemPackages = with pkgs; [
    discord-ptb
    kopia-ui
    gnomeExtensions.appindicator # adds system tray icons to gnome
    spotify
  ];

  # This also needs to be set as the user's default shell in the user section
  programs.zsh.enable = true;

  programs.firefox.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "anthony" ];
  };
  environment.etc."1password/custom_allowed_browsers" = {
    # Zen must be explicitly allowed to be used with 1Password
    text = ''
      .zen-wrapped
    '';
    mode = "0755";
  };

  programs.steam.enable = true;

  ## End Programs Section ##

  ## Start Home Manager ##
  # This should eventually be moved to a separate file

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.anthony =
      { pkgs, ... }:
      {
        imports = [
          inputs.zen-browser.homeModules.beta
        ];

        # This should probably be set to the same version as the NixOS release
        home.stateVersion = "25.11";

        programs.zsh.enable = true;

        programs.ssh = {
          enable = true;
          # Lets us use 1Password with SSH
          extraConfig = ''
            Host *
              IdentityAgent ~/.1password/agent.sock
          '';
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

        programs.git = {
          enable = true;
          includes = [
            # I may want to setup sops-nix within home-manager to symlink this locally
            # Instead of it being in /run/secrets
            { path = config.sops.secrets.git_options.path; }
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

      };
  };
  ## End Home Manager ##
}
