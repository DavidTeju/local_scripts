#!/bin/bash
# Status line: project | branch* | context window | session cost | session time | dev server | tasks

input=$(cat)

# One jq pass — spawning jq per field added ~10 forks to every status refresh.
eval "$(printf '%s' "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // "")",
  @sh "used_pct=\(.context_window.used_percentage // "")",
  @sh "remaining_pct=\(.context_window.remaining_percentage // "")",
  @sh "total_cost=\(.cost.total_cost_usd // "")",
  @sh "duration_ms=\(.cost.total_duration_ms // "")",
  @sh "transcript_path=\(.transcript_path // "")",
  @sh "task_total=\(.tasks.total // 0)",
  @sh "task_completed=\(.tasks.completed // 0)"
')"

cd "$cwd" 2>/dev/null || exit 0

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BLUE='\033[34m'
MAGENTA='\033[35m'
DIM='\033[2m'
RESET='\033[0m'

project=""
if [ -f "package.json" ]; then
  project=$(jq -r '.name // empty' package.json 2>/dev/null)
fi
[ -z "$project" ] && project=$(basename "$cwd")

# Git: single porcelain call gets branch + dirty status.
git_info=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  status=$(git status --porcelain=v2 --branch 2>/dev/null)
  branch=$(printf '%s\n' "$status" | awk '/^# branch.head/ { print $3; exit }')
  [ -z "$branch" ] || [ "$branch" = "(detached)" ] && branch=$(git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=""
    if printf '%s\n' "$status" | grep -q '^[12u? ]'; then
      # any tracked-change or untracked line means dirty
      if printf '%s\n' "$status" | grep -qv '^#'; then
        dirty="${RED}*${RESET}"
      fi
    fi
    git_info="${GREEN}${branch}${RESET}${dirty}"
  fi
fi

# Context window bar
context_info=""
if [ -n "$used_pct" ] && [ -n "$remaining_pct" ]; then
  bar_width=20
  used_int=${used_pct%.*}
  used_bars=$(( used_int * bar_width / 100 ))
  [ "$used_bars" -lt 0 ] && used_bars=0
  [ "$used_bars" -gt "$bar_width" ] && used_bars=$bar_width
  remaining_bars=$((bar_width - used_bars))

  if [ "$used_int" -ge 80 ]; then
    bar_color=$RED
  elif [ "$used_int" -ge 60 ]; then
    bar_color=$YELLOW
  else
    bar_color=$GREEN
  fi

  printf -v bar '%*s' "$used_bars" ''; bar=${bar// /█}
  printf -v empty '%*s' "$remaining_bars" ''; empty=${empty// /░}
  context_info="${bar_color}${bar}${DIM}${empty}${RESET} ${bar_color}${used_int}%${RESET}"
fi

# Session cost
cost_info=""
if [ -n "$total_cost" ] && [ "$total_cost" != "0" ]; then
  # Compare without bc: split on decimal, treat cents.
  int_part=${total_cost%%.*}
  if [ "$int_part" = "0" ] || [ -z "$int_part" ]; then
    # under $1 — check if under $0.01
    frac=${total_cost#*.}
    if [ "${frac:0:2}" = "00" ]; then
      cost_display=$(printf "%.4f" "$total_cost")
    else
      cost_display=$(printf "%.2f" "$total_cost")
    fi
  else
    cost_display=$(printf "%.2f" "$total_cost")
  fi
  cost_info="${MAGENTA}\$${cost_display}${RESET}"
fi

# Session time
session_time=""
if [ -n "$duration_ms" ] && [ "$duration_ms" != "0" ]; then
  duration=$((duration_ms / 1000))
elif [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    creation_time=$(stat -f %B "$transcript_path" 2>/dev/null)
  else
    creation_time=$(stat -c %W "$transcript_path" 2>/dev/null)
  fi
  if [ -n "$creation_time" ] && [ "$creation_time" != "0" ]; then
    duration=$(( $(date +%s) - creation_time ))
  fi
fi
if [ -n "${duration:-}" ] && [ "$duration" -gt 0 ]; then
  hours=$((duration / 3600))
  minutes=$(((duration % 3600) / 60))
  if [ "$hours" -gt 0 ]; then
    session_time="${BLUE}${hours}h${minutes}m${RESET}"
  elif [ "$minutes" -gt 0 ]; then
    session_time="${BLUE}${minutes}m${RESET}"
  else
    session_time="${BLUE}<1m${RESET}"
  fi
fi

# Dev server: single lsof scans all three ports at once instead of 3 sequential calls.
dev_status="${DIM}no server${RESET}"
listening=$(lsof -iTCP:3000,3001,5173 -sTCP:LISTEN -P -n 2>/dev/null | awk 'NR>1 { print $9 }' | grep -oE '[0-9]+$' | head -1)
if [ -n "$listening" ]; then
  dev_status="${GREEN}:${listening} ✓${RESET}"
fi

# Tasks
task_info=""
if [ "$task_total" != "0" ] && [ "$task_total" != "null" ]; then
  if [ "$task_completed" = "$task_total" ]; then
    task_info="${GREEN}${task_completed}/${task_total} tasks${RESET}"
  else
    task_info="${YELLOW}${task_completed}/${task_total} tasks${RESET}"
  fi
fi

line1="${CYAN}${project}${RESET}"
[ -n "$git_info" ] && line1="${line1} ${DIM}|${RESET} ${git_info}"
[ -n "$dev_status" ] && line1="${line1} ${DIM}|${RESET} ${dev_status}"
[ -n "$task_info" ] && line1="${line1} ${DIM}|${RESET} ${task_info}"

line2=""
[ -n "$context_info" ] && line2="${context_info}"
[ -n "$cost_info" ] && line2="${line2}${line2:+ ${DIM}|${RESET} }${cost_info}"
[ -n "$session_time" ] && line2="${line2}${line2:+ ${DIM}|${RESET} }${session_time}"

printf "%b\n" "$line1"
[ -n "$line2" ] && printf "%b\n" "$line2"
