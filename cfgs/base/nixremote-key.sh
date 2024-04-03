# Nix substitions - comment out if run directly
function ssh-keygen() { @sshKeygen@ $@; }

keyDir="/root/.ssh"
keyName="nixremote"
keyPath="$keyDir/$keyName"

set -o errexit

if [[ ! -e "$keyPath" ]]; then
  echo "NixRemote SSH key not found, generating a new one.."
  mkdir -p -m600 "$keyDir"
  ssh-keygen -t rsa -f "$keyPath" -q -N \"\"

  # Print-out
  echo -e "\033[1;34mPublic NixRemote SSH key:"
  cat "$keyPath.pub"
  echo -e "---\033[0m"
fi
