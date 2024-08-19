jq="@jq@/bin/jq"
package=$1
attrPath="nixos.$package"

fullJson=$(nix-env -qaA "$attrPath" --json --meta 2>/dev/null | cat)
# TODO: Gather info into an object and format better
info=$(echo "$fullJson" | tr '\r\n' ' ' | $jq -Cr ".\"$attrPath\" | (.pname + \" v\" + .version + \"\n\" + .meta.description + \"\\n\\n\" + .meta.homepage)")

echo "$info"
