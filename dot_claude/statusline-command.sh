#!/usr/bin/env bash
# Claude Code status line, modelled on the starship gruvbox_dark prompt.
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
# rate limits (Claude.ai subscribers; absent until the first API response)
h5=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
d7=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# directory: last 3 components, ~ for home
dir="${cwd/#$HOME/~}"
IFS='/' read -ra parts <<< "$dir"
if [ "${#parts[@]}" -gt 3 ]; then
  dir="…/${parts[-3]}/${parts[-2]}/${parts[-1]}"
fi

branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

# gruvbox colours (truecolor): orange, yellow, aqua, blue, dark bg
seg() { printf '\033[48;2;%s;38;2;251;241;199m %s \033[0m' "$1" "$2"; }

seg "214;93;14" "$(whoami)"
seg "215;153;33" "$dir"
[ -n "$branch" ] && seg "104;157;106" " $branch"
seg "69;133;136" "$model"
[ -n "$used" ] && seg "60;56;54" "ctx $(printf '%.0f' "$used")%"
[ -n "$h5" ] && seg "152;151;26" "5h $(printf '%.0f' "$h5")%"
[ -n "$d7" ] && seg "177;98;134" "7d $(printf '%.0f' "$d7")%"
echo
