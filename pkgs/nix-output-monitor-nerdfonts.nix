# Remaps symbols to nerdfonts for better support across terminals
# Source taken from https://github.com/maralorn/nix-output-monitor/issues/80#issuecomment-2495554801 with a slight tweak

{ nix-output-monitor
, lib
}:
(nix-output-monitor.overrideAttrs (old: {
  postPatch = old.postPatch or "" + ''
    sed -ie ${lib.escapeShellArg ''
      s/↓/\\xf072e/
      s/↑/\\xf0737/
      s/⏱/\\xf520/
      s/⏵/\\xf04b/
      s/✔/\\xf00c/
      s/⏸/\\xf04c/
      s/⚠/\\xf071/
      s/∅/\\xf07e2/
      s/∑/\\xf04a0/
      ''} lib/NOM/Print.hs
  '';
}))
