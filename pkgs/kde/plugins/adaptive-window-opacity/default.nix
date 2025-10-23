{ runCommand }:
# TODO: Use kpackagetool6 instead
runCommand "kwin-adaptive-window-opacity" { } ''
  mkdir -p $out/share/kwin/scripts/AdaptiveWindowOpacity
  cp -r ${./plugin}/* $out/share/kwin/scripts/AdaptiveWindowOpacity/
''
