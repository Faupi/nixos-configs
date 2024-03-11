{ stdenv, fetchurl, nixosTests, jre_headless }:
stdenv.mkDerivation {
  pname = "minecraft-server-fabric";
  version = "1.20.4-0.15.7";

  src = fetchurl {
    url = "https://meta.fabricmc.net/v2/versions/loader/1.20.4/0.15.7/1.0.0/server/jar";
    sha256 = "sha256:0hfvimh190z50qigzjyl0iyzg629zv2l76001v78rl6nnbyl59w9";
  };

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp -v $src $out/lib/minecraft/server.jar

    cat > $out/bin/minecraft-server << EOF
    #!/bin/sh
    exec ${jre_headless}/bin/java \$@ -jar $out/lib/minecraft/server.jar nogui
    EOF

    chmod +x $out/bin/minecraft-server
  '';

  dontUnpack = true;

  passthru = {
    tests = { inherit (nixosTests) minecraft-server; };
  };
}
