#!/usr/bin/env bash

set -euo pipefail

# Shared helpers for Git hooks in this repo.
#
# Intended usage:
# - source this file from a hook
# - call hook_init "<hook-name>"
# - call hook_run / hook_run_timed for one or more commands
# - call hook_finish "<hook-name>" to decide the final exit status
#
# Globals set by hook_init:
# - REPO_ROOT: absolute path to repository root
# - GIT_DIR: absolute path to the repo's .git directory (or worktree gitdir)
# - LOG_FILE: log file path for this hook
# - HOOK_FAILURES: number of commands that failed via hook_run*

hook_init() {
  local hook_name="${1:?hook name required}"

  # If we can't resolve the repo root, don't block the caller.
  REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || return 0
  cd "$REPO_ROOT" || return 1

  local git_dir
  git_dir="$(git rev-parse --git-dir)"
  case "$git_dir" in
    /*) GIT_DIR="$git_dir" ;;
    *) GIT_DIR="$REPO_ROOT/$git_dir" ;;
  esac

  LOG_FILE="$GIT_DIR/$hook_name.log"

  # Tee to the log and stderr so CLI users still see output.
  exec > >(tee -a "$LOG_FILE" >&2) 2>&1

  echo "=== $hook_name $(date -Is) ==="
  echo "repo: $REPO_ROOT"

  HOOK_FAILURES=0
}

# Print a helpful footer on unexpected errors (not for handled command failures).
hook_trap_fail() {
  local hook_name="${1:?hook name required}"
  trap 'echo "'"$hook_name"' FAILED ($(date -Is)). See: '"$LOG_FILE"'"' ERR
}

# Print a success footer.
hook_ok() {
  local hook_name="${1:?hook name required}"
  echo "$hook_name OK ($(date -Is)). See: $LOG_FILE"
}

# Read stdin and log it with a label (useful for pre-push ref lines).
hook_log_stdin() {
  local label="${1:?label required}"
  local content
  content="$(cat || true)"
  if [[ -n "${content//[[:space:]]/}" ]]; then
    echo "$label:"
    echo "$content"
  fi
}

# Run a command but continue even if it fails. Increments HOOK_FAILURES on failure.
hook_run() {
  [[ $# -gt 0 ]] || { echo "hook_run: missing command" >&2; return 2; }
  local cmd_str="$*"

  echo "running: $cmd_str"

  set +e
  "$@"
  local rc=$?
  set -e

  if (( rc != 0 )); then
    echo "FAILED ($rc): $cmd_str"
    HOOK_FAILURES=$((HOOK_FAILURES + 1))
  fi

  return 0
}

# Like hook_run but wraps the command in `time` for rough duration info in logs.
hook_run_timed() {
  [[ $# -gt 0 ]] || { echo "hook_run_timed: missing command" >&2; return 2; }
  local cmd_str="$*"

  echo "running (timed): $cmd_str"

  set +e
  time "$@"
  local rc=$?
  set -e

  if (( rc != 0 )); then
    echo "FAILED ($rc): $cmd_str"
    HOOK_FAILURES=$((HOOK_FAILURES + 1))
  fi

  return 0
}

# Exit non-zero if any hook_run* commands failed; otherwise print hook_ok.
hook_finish() {
  local hook_name="${1:?hook name required}"
  if (( HOOK_FAILURES > 0 )); then
    echo "$hook_name FAILED: $HOOK_FAILURES command(s) failed. See: $LOG_FILE"
    return 1
  fi
  hook_ok "$hook_name"
}
