{
  # Where hhd configuration (token and state.yaml) are stored
  hhdConfigPath ? null
, stdenv
, lib
}:
stdenv.mkDerivation rec {
  pname = "hhd-decky";
  version = "0.1.0";
  src = fetchTarball {
    url = "https://github.com/hhd-dev/hhd-decky/releases/download/v${version}/hhd-decky.tar.gz";
    sha256 = "15gpll079gwnx21gjf6qivb36dzpnrx58dkbpk0xnjjx2q0bcc47";
  };

  # With recent changes to HHD, `token` was renamed to `.token` when used under /etc.
  postPatch =
    (lib.strings.optionalString (hhdConfigPath != null) ''
      substituteInPlace main.py \
        --replace-fail 'HHD_TOKEN_PATH = f"/home/{PLUGIN_USER}/.config/hhd/token"' 'HHD_TOKEN_PATH = "${hhdConfigPath}/.token"' \
        --replace-fail 'HHD_STATE_PATH = f"/home/{PLUGIN_USER}/.config/hhd/state.yml"' 'HHD_STATE_PATH = "${hhdConfigPath}/state.yml"'
    '');

  installPhase = ''
    mkdir -p $out
    cp -a ./* $out/
  '';
}
