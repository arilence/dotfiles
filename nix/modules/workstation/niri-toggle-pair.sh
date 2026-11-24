state_dir="${XDG_RUNTIME_DIR:?}/niri-pairs-${NIRI_SOCKET##*/}"
mkdir -p "$state_dir"
exec 9>"$state_dir/lock"
flock --nonblock 9 || exit 0

windows=$(niri msg --json windows)
# A shell panel can hold keyboard focus while the workspace still has an active window.
active_window_id=$(niri msg --json workspaces | jq -er '.[] | select(.is_focused) | .active_window_id') || exit 0
focused=$(jq -ce --argjson id "$active_window_id" '.[] | select(.id == $id and (.is_floating | not)
  and .layout.pos_in_scrolling_layout != null)' <<< "$windows") || exit 0
read -r focused_id workspace_id column < <(
  jq -r '[.id, .workspace_id, .layout.pos_in_scrolling_layout[0]] | @tsv' <<< "$focused"
)
state_file="$state_dir/$workspace_id"

focus() {
  niri msg action focus-window --id "$1" >/dev/null
}

if [[ -f "$state_file" ]]; then
  trap 'focus "$focused_id" || true' EXIT
  while read -r window_id previous_width; do
    if [[ -z "$previous_width" ]]; then
      echo "niri-toggle-pair: old state has no saved width for window $window_id; leaving it unchanged." >&2
      continue
    fi
    if jq -e --argjson id "$window_id" --argjson workspace "$workspace_id" '
      any(.[]; .id == $id and .workspace_id == $workspace and (.is_floating | not))
    ' <<< "$windows" >/dev/null; then
      focus "$window_id"
      niri msg action set-column-width "$previous_width" >/dev/null
    fi
  done < "$state_file"
  rm "$state_file"
  focus "$focused_id"
  niri msg action center-column >/dev/null
  trap - EXIT
  exit 0
fi

partner_id=$(jq -r --argjson workspace "$workspace_id" --argjson column "$column" '
  [.[] | select(.workspace_id == $workspace and (.is_floating | not)
    and .layout.pos_in_scrolling_layout != null)] as $windows
  | (($windows | map(select(.layout.pos_in_scrolling_layout[0] > $column))
      | min_by(.layout.pos_in_scrolling_layout))
    // ($windows | map(select(.layout.pos_in_scrolling_layout[0] < $column))
      | max_by(.layout.pos_in_scrolling_layout)))
  | .id // empty
' <<< "$windows")
[[ -n "$partner_id" ]] || exit 0

# Keep the pair recoverable if a window disappears between actions.
# Fixed column widths target window geometry, excluding niri's borders.
jq -r --argjson focused "$focused_id" --argjson partner "$partner_id" '
  .[] | select(.id == $focused or .id == $partner)
  | [.id, .layout.window_size[0]] | @tsv
' <<< "$windows" > "$state_file"
trap 'focus "$focused_id" || true' EXIT
focus "$partner_id"
niri msg action set-column-width "50%" >/dev/null
focus "$focused_id"
niri msg action set-column-width "50%" >/dev/null

# Visiting both columns after resizing brings the whole pair into view.
focus "$partner_id"
focus "$focused_id"
trap - EXIT
