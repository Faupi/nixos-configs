#!@bash@

@curl@ -Ls "$1" |
  @htmlq@ --text body |
  @grep@ -oP "Redirecting you to \K.*"
