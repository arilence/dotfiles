{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  agentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  version = "0.0.33-nightly.20260808.1029";

  src = pkgs.fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256:6541338281b3e3bf5d4b4b38183600308982edb828fbbc619bee9245a7d91878";
  };

  appimageContents = pkgs.appimageTools.extractType2 {
    pname = "t3code";
    inherit version src;
  };

  t3codeAppimage = pkgs.appimageTools.wrapType2 {
    pname = "t3code";
    inherit version src;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/t3code.desktop \
        $out/share/applications/t3code.desktop
      substituteInPlace $out/share/applications/t3code.desktop \
        --replace-fail "Exec=AppRun" "Exec=t3code"
      cp -r ${appimageContents}/usr/share/icons $out/share/
    '';
  };

  t3code = pkgs.symlinkJoin {
    name = "t3code-${version}";
    paths = [ t3codeAppimage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # --add-flags is a temp fix on Niri WM: https://github.com/pingdotgg/t3code/pull/2916
      wrapProgram $out/bin/t3code \
        --add-flags "--password-store=gnome-libsecret" \
        --prefix PATH : ${
          lib.makeBinPath [
            agentPackages.claude-code
            agentPackages.codex
            agentPackages.opencode
            pkgs.nixosUnstable.github-cli
            pkgs.git
          ]
        }
    '';
  };
in
{
  home-manager.users.anthony.home.packages = [
    # Keep the tools available to standalone AppImages and T3's terminal too.
    agentPackages.claude-code
    agentPackages.codex
    agentPackages.opencode
    pkgs.nixosUnstable.github-cli
    t3code
  ];
}
