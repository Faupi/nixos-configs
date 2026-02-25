#!/usr/bin/env sh
set -euo pipefail

port=${VM_SSH_PORT:-2222}
user=${VM_SSH_USER:-test}
askpass=/tmp/ssh-askpass.sh

cat >"$askpass" <<'PASS'
#!/usr/bin/env sh
echo "test"
PASS
chmod +x "$askpass"

SSH_ASKPASS="$askpass" SSH_ASKPASS_REQUIRE=force DISPLAY=:0 setsid -w ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -p "$port" "$user"@localhost \
  "$@"
