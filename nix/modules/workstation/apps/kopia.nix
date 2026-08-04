{ pkgs, ... }:

let
  kopia-btrfs-snapshot = pkgs.writeShellApplication {
    name = "kopia-btrfs-snapshot";
    runtimeInputs = with pkgs; [
      btrfs-progs
      coreutils
      util-linux
    ];
    text = ''
      umask 0077
      export LC_ALL=C

      source_subvolume=/home
      snapshot_mount=/.snapshots
      snapshot_base=/.snapshots/kopia
      lock_file=/run/lock/kopia-btrfs-snapshot.lock
      stale_seconds=86400
      partial_id_dir=
      partial_snapshot=

      die() {
        echo "kopia-btrfs-snapshot: $*" >&2
        exit 1
      }

      valid_id() {
        [[ "$1" =~ ^([0-9]{1,20}|[0-9a-f]{16})$ ]]
      }

      root_owned_directory() {
        local path=$1
        [[ -d "$path" && ! -L "$path" && "$(stat --format=%u -- "$path")" == 0 ]]
      }

      root_owned_marker() {
        local path=$1
        [[ -f "$path" && ! -L "$path" && "$(stat --format=%u -- "$path")" == 0 ]]
      }

      readonly_subvolume() {
        local path=$1
        [[ -d "$path" && ! -L "$path" ]] \
          && btrfs subvolume show "$path" >/dev/null 2>&1 \
          && [[ "$(btrfs property get -ts "$path" ro)" == "ro=true" ]]
      }

      expected_id_contents() {
        local id_dir=$1
        local entry name

        for entry in "$id_dir"/.[!.]* "$id_dir"/..?* "$id_dir"/*; do
          [[ -e "$entry" || -L "$entry" ]] || continue
          name=''${entry##*/}
          [[ "$name" == created-at || "$name" == home ]] || return 1
        done
      }

      decimal_less_than() {
        local left=$1
        local right=$2

        while [[ "$left" == 0* && ''${#left} -gt 1 ]]; do
          left=''${left#0}
        done

        if [[ ''${#left} -lt ''${#right} ]]; then
          return 0
        fi
        if [[ ''${#left} -gt ''${#right} ]]; then
          return 1
        fi
        [[ "$left" < "$right" ]]
      }

      validate_layout() {
        local source_type snapshot_type source_uuid snapshot_uuid

        [[ -d "$source_subvolume" && ! -L "$source_subvolume" ]] \
          || die "$source_subvolume is not a directory"
        btrfs subvolume show "$source_subvolume" >/dev/null 2>&1 \
          || die "$source_subvolume is not a Btrfs subvolume"

        [[ -d "$snapshot_mount" && ! -L "$snapshot_mount" ]] \
          || die "$snapshot_mount is not a directory"

        source_type=$(findmnt --noheadings --raw --output FSTYPE --target "$source_subvolume")
        snapshot_type=$(findmnt --noheadings --raw --output FSTYPE --target "$snapshot_mount")
        [[ "$source_type" == btrfs && "$snapshot_type" == btrfs ]] \
          || die "$source_subvolume and $snapshot_mount must both be Btrfs mounts"

        source_uuid=$(findmnt --noheadings --raw --output UUID --target "$source_subvolume")
        snapshot_uuid=$(findmnt --noheadings --raw --output UUID --target "$snapshot_mount")
        [[ -n "$source_uuid" && "$source_uuid" == "$snapshot_uuid" ]] \
          || die "$source_subvolume and $snapshot_mount are not on the same Btrfs filesystem"
      }

      ensure_snapshot_base() {
        if [[ -e "$snapshot_base" || -L "$snapshot_base" ]]; then
          root_owned_directory "$snapshot_base" \
            || die "$snapshot_base is not a root-owned directory"
        fi

        install --directory --owner=root --group=root --mode=0711 -- "$snapshot_base"
        root_owned_directory "$snapshot_base" \
          || die "failed to create a safe snapshot base"
        [[ "$(stat --format=%g -- "$snapshot_base")" == 0 ]] \
          || die "$snapshot_base is not root-group-owned"
        [[ "$(stat --format=%a -- "$snapshot_base")" == 711 ]] \
          || die "$snapshot_base does not have mode 0711"
      }

      release_existing() {
        local id=$1
        local id_dir="$snapshot_base/$id"
        local marker="$id_dir/created-at"
        local snapshot="$id_dir/home"

        if [[ ! -e "$id_dir" && ! -L "$id_dir" ]]; then
          return 0
        fi

        root_owned_directory "$id_dir" \
          || die "refusing to release unsafe snapshot directory $id_dir"
        expected_id_contents "$id_dir" \
          || die "refusing to release snapshot directory with unexpected contents $id_dir"
        readonly_subvolume "$snapshot" \
          || die "refusing to release invalid snapshot $snapshot"

        if [[ -e "$marker" || -L "$marker" ]]; then
          root_owned_marker "$marker" \
            || die "refusing to remove unsafe marker $marker"
        fi

        btrfs subvolume delete --commit-after "$snapshot" \
          || die "failed to delete snapshot $snapshot"
        if [[ -e "$marker" ]]; then
          rm -- "$marker" \
            || die "failed to remove marker $marker"
        fi
        rmdir -- "$id_dir" \
          || die "failed to remove snapshot directory $id_dir"
      }

      cleanup_stale_snapshots() {
        local now cutoff entry id id_dir marker snapshot created_at

        now=$(date +%s)
        cutoff=$((now - stale_seconds))

        shopt -s nullglob dotglob
        for entry in "$snapshot_base"/*; do
          id=''${entry##*/}
          if ! valid_id "$id"; then
            echo "kopia-btrfs-snapshot: leaving unknown entry $entry untouched" >&2
            continue
          fi

          id_dir="$snapshot_base/$id"
          marker="$id_dir/created-at"
          snapshot="$id_dir/home"

          if ! root_owned_directory "$id_dir"; then
            echo "kopia-btrfs-snapshot: leaving unsafe directory $id_dir untouched" >&2
            continue
          fi
          if ! expected_id_contents "$id_dir"; then
            echo "kopia-btrfs-snapshot: leaving snapshot with unexpected contents $id_dir untouched" >&2
            continue
          fi
          if ! root_owned_marker "$marker"; then
            echo "kopia-btrfs-snapshot: leaving snapshot with unsafe marker $id_dir untouched" >&2
            continue
          fi
          if ! readonly_subvolume "$snapshot"; then
            echo "kopia-btrfs-snapshot: leaving invalid snapshot $snapshot untouched" >&2
            continue
          fi

          created_at=$(<"$marker")
          if [[ ! "$created_at" =~ ^[0-9]{1,20}$ ]]; then
            echo "kopia-btrfs-snapshot: leaving snapshot with invalid timestamp $id_dir untouched" >&2
            continue
          fi

          if decimal_less_than "$created_at" "$cutoff"; then
            echo "kopia-btrfs-snapshot: releasing stale snapshot $id" >&2
            release_existing "$id" \
              || die "failed to release stale snapshot $id"
          fi
        done
        shopt -u nullglob dotglob
      }

      cleanup_partial_snapshot() {
        local status=$?
        local snapshot_removed=true
        trap - EXIT
        set +e

        if [[ "$status" -ne 0 && -n "$partial_id_dir" ]]; then
          echo "kopia-btrfs-snapshot: cleaning up incomplete snapshot" >&2

          if [[ -n "$partial_snapshot" && -d "$partial_snapshot" && ! -L "$partial_snapshot" ]] \
            && btrfs subvolume show "$partial_snapshot" >/dev/null 2>&1; then
            if ! btrfs subvolume delete --commit-after "$partial_snapshot" >&2; then
              echo "kopia-btrfs-snapshot: failed to remove incomplete subvolume" >&2
              snapshot_removed=false
            fi
          elif [[ -n "$partial_snapshot" ]] && root_owned_directory "$partial_snapshot"; then
            if ! rmdir -- "$partial_snapshot"; then
              echo "kopia-btrfs-snapshot: failed to remove incomplete snapshot directory" >&2
              snapshot_removed=false
            fi
          elif [[ -n "$partial_snapshot" && ( -e "$partial_snapshot" || -L "$partial_snapshot" ) ]]; then
            echo "kopia-btrfs-snapshot: refusing to remove an unexpected incomplete snapshot path" >&2
            snapshot_removed=false
          fi

          if [[ "$snapshot_removed" == true ]] && root_owned_directory "$partial_id_dir"; then
            local marker="$partial_id_dir/created-at"
            if root_owned_marker "$marker"; then
              rm -- "$marker"
            fi
            rmdir -- "$partial_id_dir"
          fi
        fi

        exit "$status"
      }

      prepare_snapshot() {
        local id=$1
        local id_dir="$snapshot_base/$id"
        local marker="$id_dir/created-at"
        local snapshot="$id_dir/home"
        local redirect="$snapshot/anthony"

        validate_layout
        ensure_snapshot_base
        cleanup_stale_snapshots

        [[ ! -e "$id_dir" && ! -L "$id_dir" ]] \
          || die "snapshot ID $id already exists"

        install --directory --owner=root --group=root --mode=0711 -- "$id_dir"
        partial_id_dir=$id_dir
        trap cleanup_partial_snapshot EXIT

        date +%s >"$marker"
        chown root:root -- "$marker"
        chmod 0600 -- "$marker"

        partial_snapshot=$snapshot
        btrfs subvolume snapshot -r "$source_subvolume" "$snapshot"
        readonly_subvolume "$snapshot" \
          || die "created snapshot is not a read-only Btrfs subvolume"

        ${pkgs.util-linux}/bin/runuser -u anthony -- ${pkgs.coreutils}/bin/test -r "$redirect" \
          || die "$redirect is not readable by anthony"
        ${pkgs.util-linux}/bin/runuser -u anthony -- ${pkgs.coreutils}/bin/test -r "$redirect/.kopiaignore" \
          || die "$redirect/.kopiaignore is not readable by anthony"

        partial_id_dir=
        partial_snapshot=
        trap - EXIT
      }

      [[ $# -eq 2 ]] \
        || die "usage: kopia-btrfs-snapshot {prepare|release} SNAPSHOT_ID"

      operation=$1
      snapshot_id=$2
      valid_id "$snapshot_id" \
        || die "snapshot ID must be 1-20 decimal digits or 16 lowercase hexadecimal characters"

      exec 9>"$lock_file"
      flock --exclusive 9

      case "$operation" in
        prepare)
          prepare_snapshot "$snapshot_id"
          ;;
        release)
          validate_layout
          ensure_snapshot_base
          release_existing "$snapshot_id"
          ;;
        *)
          die "operation must be prepare or release"
          ;;
      esac
    '';
  };

  kopia-btrfs-before-snapshot = pkgs.writeShellApplication {
    name = "kopia-btrfs-before-snapshot";
    text = ''
      export LC_ALL=C

      [[ "''${KOPIA_ACTION:-}" == before-snapshot-root ]] \
        || { echo "kopia-btrfs-before-snapshot: unexpected KOPIA_ACTION" >&2; exit 1; }
      [[ "''${KOPIA_SOURCE_PATH:-}" == /home/anthony ]] \
        || { echo "kopia-btrfs-before-snapshot: unexpected KOPIA_SOURCE_PATH" >&2; exit 1; }

      snapshot_id=''${KOPIA_SNAPSHOT_ID:-}
      [[ "$snapshot_id" =~ ^([0-9]{1,20}|[0-9a-f]{16})$ ]] \
        || { echo "kopia-btrfs-before-snapshot: invalid KOPIA_SNAPSHOT_ID" >&2; exit 1; }

      /run/wrappers/bin/sudo -n ${kopia-btrfs-snapshot}/bin/kopia-btrfs-snapshot prepare "$snapshot_id" >&2
      echo "KOPIA_SNAPSHOT_PATH=/.snapshots/kopia/$snapshot_id/home/anthony"
    '';
  };

  kopia-before-snapshot = pkgs.writeShellApplication {
    name = "kopia-before-snapshot";
    text = ''
      export LC_ALL=C

      [[ "''${KOPIA_ACTION:-}" == before-snapshot-root ]] \
        || { echo "kopia-before-snapshot: unexpected KOPIA_ACTION" >&2; exit 1; }
      [[ "''${KOPIA_SOURCE_PATH:-}" == /home/anthony ]] \
        || { echo "kopia-before-snapshot: unexpected KOPIA_SOURCE_PATH" >&2; exit 1; }
      [[ "''${KOPIA_SNAPSHOT_ID:-}" =~ ^([0-9]{1,20}|[0-9a-f]{16})$ ]] \
        || { echo "kopia-before-snapshot: invalid KOPIA_SNAPSHOT_ID" >&2; exit 1; }

      ludusavi_action=/home/anthony/.config/kopia/actions/ludusavi-backup
      if [[ -e "$ludusavi_action" || -L "$ludusavi_action" ]]; then
        [[ -x "$ludusavi_action" ]] \
          || { echo "kopia-before-snapshot: Ludusavi action is not executable" >&2; exit 1; }
        "$ludusavi_action" >&2
      fi

      exec ${kopia-btrfs-before-snapshot}/bin/kopia-btrfs-before-snapshot
    '';
  };

  kopia-btrfs-after-snapshot = pkgs.writeShellApplication {
    name = "kopia-btrfs-after-snapshot";
    text = ''
      export LC_ALL=C

      [[ "''${KOPIA_ACTION:-}" == after-snapshot-root ]] \
        || { echo "kopia-btrfs-after-snapshot: unexpected KOPIA_ACTION" >&2; exit 1; }
      [[ "''${KOPIA_SOURCE_PATH:-}" == /home/anthony ]] \
        || { echo "kopia-btrfs-after-snapshot: unexpected KOPIA_SOURCE_PATH" >&2; exit 1; }

      snapshot_id=''${KOPIA_SNAPSHOT_ID:-}
      [[ "$snapshot_id" =~ ^([0-9]{1,20}|[0-9a-f]{16})$ ]] \
        || { echo "kopia-btrfs-after-snapshot: invalid KOPIA_SNAPSHOT_ID" >&2; exit 1; }

      expected_path="/.snapshots/kopia/$snapshot_id/home/anthony"
      [[ "''${KOPIA_SNAPSHOT_PATH:-}" == "$expected_path" ]] \
        || { echo "kopia-btrfs-after-snapshot: unexpected KOPIA_SNAPSHOT_PATH" >&2; exit 1; }

      /run/wrappers/bin/sudo -n ${kopia-btrfs-snapshot}/bin/kopia-btrfs-snapshot release "$snapshot_id" >&2
    '';
  };
in
{
  security.sudo.extraRules = [
    {
      users = [ "anthony" ];
      commands = [
        {
          command = "${kopia-btrfs-snapshot}/bin/kopia-btrfs-snapshot";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  home-manager.users.anthony = {
    xdg.configFile = {
      "kopia/actions/before-snapshot".source = "${kopia-before-snapshot}/bin/kopia-before-snapshot";
      "kopia/actions/btrfs-before-snapshot".source =
        "${kopia-btrfs-before-snapshot}/bin/kopia-btrfs-before-snapshot";
      "kopia/actions/btrfs-after-snapshot".source =
        "${kopia-btrfs-after-snapshot}/bin/kopia-btrfs-after-snapshot";
    };

    systemd.user.services.kopia-ui = {
      Unit = {
        Description = "Kopia backup UI";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kopia-ui}/bin/kopia-ui";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
