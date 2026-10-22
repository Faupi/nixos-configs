#!/usr/bin/env bash
set -euo pipefail

cd "/srv/nixos-prebuild"

echo "Updating local flake"
git fetch --prune origin
git reset --hard origin/master

configs=$(nix eval .#nixosConfigurations --apply 'builtins.attrNames' --json | jq -r '.[]')
if [ -z "$configs" ]; then
  echo "No configurations found, skipping build" >&2
  exit 0
fi

logDir="/var/log/nixos-prebuild"
mkdir -p "$logDir"
runId=$(date '+%Y%m%d-%H%M%S')
runLogDir="$logDir/$runId"
mkdir -p "$runLogDir"

declare -a succeeded=()
declare -a failed=()
declare -A exitCodes=()
declare -A errorTypes=()
declare -A errorDetails=()

classify_error() {
  local log="$1"

  if grep -Eiq 'evaluation error|while evaluating|undefined variable|attribute .* missing|does not exist|infinite recursion|error:.*option' "$log"; then
    echo "Evaluation error"
  elif grep -Eiq 'timed out|timeout|connection timed out|killed by signal|interrupted by user|signal 9' "$log"; then
    echo "Timeout/interruption"
  elif grep -Eiq 'hash mismatch|download.*failed|failed to download|unable to download|HTTP error|HTTP [45][0-9][0-9]|substitut(e|ion).*failed|cannot download' "$log"; then
    echo "Fetch/substitution error"
  elif grep -Eiq 'builder for .* failed|build of .* failed|failed to build|building .* failed|build failure' "$log"; then
    echo "Build error"
  else
    echo "General error"
  fi
}

echo "Starting builds at $(date)"

for config in $configs; do
  echo
  echo "Building $config..."

  logFile="$runLogDir/$config.log"

  if nix-fast-build \
    --flake ".#nixosConfigurations.$config.config.system.build.toplevel" \
    --no-link \
    --no-nom \
    --retries 3 \
    --skip-cached \
    --option keep-going true \
    2>&1 | tee "$logFile" | sed -u "s/^/[$config] /"; then
    echo "✅ Succeeded: $config"
    succeeded+=("$config")
  else
    buildStatus=$?
    echo "❌ Failed: $config (exit code $buildStatus)"

    failed+=("$config")
    exitCodes["$config"]="$buildStatus"
    errorTypes["$config"]="$(classify_error "$logFile")"

    details=$(grep -Ei \
      'error:|fatal:|failed|failure|timed out|timeout|killed by signal|interrupted|hash mismatch|HTTP [45][0-9][0-9]' \
      "$logFile" | tail -n 3 || true)

    if [ -z "$details" ]; then
      details=$(tail -n 3 "$logFile")
    fi

    errorDetails["$config"]="$details"
  fi
done

echo
echo "========================================"
echo "NixOS prebuild summary"
echo "Finished at: $(date)"
echo "Total:   $(printf '%s\n' "$configs" | wc -l)"
echo "Passed:  ${#succeeded[@]}"
echo "Failed:  ${#failed[@]}"
echo "Logs:    $runLogDir"
echo "========================================"

if [ "${#succeeded[@]}" -gt 0 ]; then
  echo
  echo "Successful configurations:"
  printf '  ✅ %s\n' "${succeeded[@]}"
fi

if [ "${#failed[@]}" -gt 0 ]; then
  echo
  echo "Failed configurations:"

  for config in "${failed[@]}"; do
    echo
    echo "  ❌ $config (exit ${exitCodes[$config]})"
    echo "     Type: ${errorTypes[$config]}"
    echo "     Relevant log lines:"

    while IFS= read -r line; do
      [ -n "$line" ] && printf '       %s\n' "$line"
    done <<<"${errorDetails[$config]}"
  done
fi

echo
echo "Full logs: $runLogDir"

if [ "${#failed[@]}" -gt 0 ]; then
  exit 1
fi

exit 0
