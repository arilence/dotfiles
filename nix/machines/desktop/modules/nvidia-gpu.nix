{
  config,
  inputs,
  pkgs,
  ...
}:

let
  # GTX 1060 is Pascal/GP10x. NVIDIA's 580 legacy series is the last Linux
  # branch that supports Pascal, so pin the newest patched 580 driver instead
  # of following the moving `latest` alias into an unsupported branch.
  latestPascalDriver = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "580.159.03";
    sha256_64bit = "sha256-MshdmbD2QMlQH2GzndrSCP0CiNAVxPvF/QQ1wHeD+nc=";
    openSha256 = "sha256-HlGJyfcmXWqKJw1NRjp35clLucQtCIWAxjJvicgI4zM=";
    settingsSha256 = "sha256-kP3J87uUVPOOJHmTdRNm4+GdIyniZYrtgehrYSXcX9A=";
    persistencedSha256 = "sha256-cQ+qz4aSYeonKviufdQOHo0quun8yPBTSgOvRkdN6og=";
  };
in
{
  # Enable Hardware Acceleration
  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct"; # required for nvidia-vaapi-driver on recent kernels
    MOZ_DISABLE_RDD_SANDBOX = "1"; # Firefox: allows VA-API in the RDD process
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver # VA-API via NVDEC
      libvdpau-va-gl # VDPAU → VA-API bridge
    ];
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

    # Latest supported branch for the GTX 1060.
    package = latestPascalDriver;
  };
}
