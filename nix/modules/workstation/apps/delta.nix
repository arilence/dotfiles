{
  lib,
  pkgs,
  ...
}:

let
  version = "0.6.0";

  src = pkgs.requireFile {
    name = "delta-linux-x86_64.tar.gz";
    url = "https://delta.dev/download";
    hash = "sha256-geR2EcmiM7CmtvaR/6AvBMft297T2ijRrDegm5tMESY=";
  };

  delta-unwrapped = pkgs.stdenvNoCC.mkDerivation {
    pname = "delta-unwrapped";
    inherit version src;

    sourceRoot = "Delta";
    dontBuild = true;
    # Keep the vendor bundle's $ORIGIN/../lib RPATH. Nix's generic fixup
    # otherwise removes it and breaks transitive bundled X11 dependencies.
    dontPatchELF = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r bin lib share $out/

      runHook postInstall
    '';
  };

  # Delta downloads and runs agent tooling, so use the same FHS approach as
  # zed-editor-fhs. This also provides the conventional ELF loader expected by
  # the vendor-provided binary without modifying the signed-in application data.
  delta-app = pkgs.buildFHSEnv {
    name = "delta-app";
    runScript = "${delta-unwrapped}/bin/delta";

    targetPkgs =
      pkgs': with pkgs'; [
        alsa-lib
        fontconfig
        glibc
        libGL
        libcap
        libx11
        libxcb
        libxext
        libxkbcommon
        openssl
        vulkan-loader
        wayland
        xkeyboard_config
        zlib
      ];

    extraBwrapArgs = [
      "--bind-try /etc/nixos /etc/nixos"
      "--ro-bind-try /etc/xdg /etc/xdg"
    ];

    extraInstallCommands = ''
      cp -r ${delta-unwrapped}/share $out/share
      chmod u+w $out/share/applications/dev.zed.Delta.desktop
      substituteInPlace $out/share/applications/dev.zed.Delta.desktop \
        --replace-fail "Name=Delta" "Name=Delta (Zed Beta)" \
        --replace-fail "Exec=delta cli open %U" "Exec=delta-app %U"
    '';

    meta = {
      description = "AI-native collaborative agent workspace by the creators of Zed";
      homepage = "https://delta.dev";
      license = lib.licenses.unfree;
      mainProgram = "delta-app";
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  environment.systemPackages = [ delta-app ];
}
