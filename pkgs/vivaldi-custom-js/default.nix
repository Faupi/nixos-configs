{ scriptFiles ? [ ]
, vivaldi
, linkFarm
, ...
}@args:
let
  wrapperOnlyArgs = [ "scriptFiles" "vivaldi" "linkFarm" ];
  vivaldiBase = vivaldi.override (builtins.removeAttrs args wrapperOnlyArgs);
in
vivaldiBase.overrideAttrs (old: {
  postInstall =
    let
      resDirRel = "opt/vivaldi/resources/vivaldi";
      windowRel = "${resDirRel}/window.html";
      windowDir = builtins.dirOf windowRel;
      modsDirRel = "${windowDir}/js-mods";

      jsBundle = linkFarm "vivaldi-js-mods"
        (map (p: { name = builtins.baseNameOf (toString p); path = p; }) scriptFiles);
    in
    (old.postInstall or "") + /*sh*/''
      mkdir -p "$out/${modsDirRel}"

      tags=""
      for f in ${jsBundle}/*; do
        [ -e "$f" ] || continue
        base="$(basename "$f")"
        install -m0644 "$f" "$out/${modsDirRel}/$base"
        tags="$tags<script src=\"js-mods/$base\"></script>"
      done

      substituteInPlace "$out/${windowRel}" \
        --replace-fail '<body>' "<body>''${tags}"
    '';
})
