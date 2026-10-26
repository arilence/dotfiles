{ pkgs }:

let
  source = pkgs.replaceVars ./session.py {
    zmx = "${pkgs.nixosUnstable.zmx}/bin/zmx";
    kitten = "${pkgs.nixosUnstable.kitty}/bin/kitten";
  };
in
pkgs.runCommand "zmx-session" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
  install -Dm444 ${source} $out/lib/zmx_session.py
  install -Dm444 ${./kitty.py} $out/lib/zmx_kitty.py
  makeWrapper ${pkgs.python3}/bin/python3 $out/bin/zmx-session \
    --add-flags $out/lib/zmx_session.py
''
