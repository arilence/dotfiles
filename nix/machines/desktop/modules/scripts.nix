{ pkgs, ... }:

let
  e = pkgs.writeShellApplication {
    name = "e";
    text = ''
      usage() {
        echo "Usage: $0 <location>" >&2
        echo "  <location>: optionally open the specified file/directory in your editor" >&2
        echo "  otherwise opens the current directory in your editor" >&2
        exit 1
      }

      if [[ "''${1:-}" == "help" || "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
        usage
      fi

      exec "$EDITOR" "''${1:-.}"
    '';
  };

  yt-audio-tracks = pkgs.writeShellApplication {
    name = "yt-audio-tracks";
    runtimeInputs = with pkgs; [
      ffmpeg
      yt-dlp
    ];
    text = ''
      usage() {
        echo "Usage: $0 <youtube-url>" >&2
        echo "  Downloads a YouTube video as split audio tracks into the current directory." >&2
        exit 1
      }

      if [[ "$#" -ne 1 || "''${1:-}" == "help" || "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
        usage
      fi

      yt-dlp \
        -f "bestaudio/best" \
        -x --audio-format best \
        --split-chapters \
        --no-embed-thumbnail \
        --write-thumbnail \
        --write-info-json \
        --write-description \
        --embed-metadata \
        -o "%(title).200B [%(id)s].%(ext)s" \
        -o "chapter:%(section_number)02d - %(section_title).200B.%(ext)s" \
        "$1"
    '';
  };
in
{
  home-manager.users.anthony.home.packages = [
    e
    yt-audio-tracks
  ];
}
