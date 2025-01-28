{ stdenv, ... }:
stdenv.mkDerivation rec {
  pname = "hhd-decky";
  version = "0.1.0";
  src = fetchTarball {
    url = "https://github.com/hhd-dev/hhd-decky/releases/download/v${version}/hhd-decky.tar.gz";
    sha256 = "15gpll079gwnx21gjf6qivb36dzpnrx58dkbpk0xnjjx2q0bcc47";
  };

  postPatch = ''
    substituteInPlace main.py \
      --replace-fail '/home/{PLUGIN_USER}' '/var/lib/handheld-daemon'
  '';

  installPhase = ''
    mkdir -p $out
    cp -a ./* $out/
  '';
}
