command_not_found_handler() {
  local p="@commandNotFound@/bin/command-not-found"

  if [ -x $p -a -f "@dbPath@" ]; then
    # Run the helper program.
    $p "$@"
  else
    echo "$1: command not found" >&2
    return 127
  fi
}
