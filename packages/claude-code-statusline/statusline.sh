#!/usr/bin/env bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
USED_TOKENS=$(echo "$input" | jq -r '(.context_window.current_usage.input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0)')
USED_K=$((USED_TOKENS / 1000))
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
EFFORT=$(echo "$input" | jq -r '.effort.level // ""')
THINKING=$(echo "$input" | jq -r '.thinking.enabled // false')

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
MAGENTA='\033[35m'
BLUE='\033[34m'
RESET='\033[0m'

# Color-coded context bar (green <70%, yellow 70-89%, red 90%+)
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /█}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

COST_FMT=$(printf '$%.2f' "$COST")
MINS=$((DURATION_MS / 60000))
SECS=$(((DURATION_MS % 60000) / 1000))

# Git status with 5s cache
DIR_HASH=$(printf '%s' "$DIR" | md5sum 2>/dev/null | cut -c1-8 || printf '%s' "$DIR" | md5 2>/dev/null | cut -c1-8)
CACHE_FILE="/tmp/claude-statusline-git-cache-${DIR_HASH}"
CACHE_MAX_AGE=5

cache_is_stale() {
  [ ! -f "$CACHE_FILE" ] || \
  [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}

if cache_is_stale; then
  if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
    STAGED=$(git -C "$DIR" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git -C "$DIR" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    echo "$BRANCH|$STAGED|$MODIFIED" > "$CACHE_FILE"
  else
    echo "||" > "$CACHE_FILE"
  fi
fi

IFS='|' read -r BRANCH STAGED MODIFIED < "$CACHE_FILE"

GIT_PART=""
if [ -n "$BRANCH" ]; then
  GIT_STATUS=""
  [ "$STAGED" -gt 0 ] && GIT_STATUS=" ${GREEN}+${STAGED}${RESET}"
  [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS} ${YELLOW}~${MODIFIED}${RESET}"
  GIT_PART=" | ${BRANCH}${GIT_STATUS}"
fi

MODEL_EXTRA=""
[ -n "$EFFORT" ] && MODEL_EXTRA=" ${MAGENTA}${EFFORT}${RESET}"
[ "$THINKING" = "true" ] && MODEL_EXTRA="${MODEL_EXTRA} ${BLUE}think${RESET}"

printf '%b' "${CYAN}[${MODEL}]${RESET}${MODEL_EXTRA} ${DIR##*/}${GIT_PART} | ${USED_K}k ${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${YELLOW}${COST_FMT}${RESET} | ${MINS}m ${SECS}s\n"
