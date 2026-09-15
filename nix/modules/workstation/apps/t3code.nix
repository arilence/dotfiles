{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  agentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  # renovate: datasource=github-release-attachments depName=pingdotgg/t3code
  releaseVersion = "v0.0.41-nightly.20260911.1564";
  version = lib.removePrefix "v" releaseVersion;

  src = pkgs.fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/${releaseVersion}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256:dfbb9486ba81e8145fda79e2bd9e14007077487c962a2660341f38f54e6a935d";
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
      wrapProgram $out/bin/t3code \
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
