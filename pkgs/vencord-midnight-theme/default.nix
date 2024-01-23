{ stdenv
, fetchFromGitHub
}: stdenv.mkDerivation {
  pname = "vencord-midnight-theme";
  version = "20230123";

  src = fetchFromGitHub {
    owner = "refact0r";
    repo = "midnight-discord";
    rev = "b5209194988505877c79a2475800e42498073b56";
    hash = "sha256-9LgTq0z7791em6EL2KH3rxi0sO/n5sQMzUpv4UyrAjU=";
  };

  patches = [
    ./colors.patch
    ./extras.patch
  ];

  # Yes, this is dumb - too bad!
  postPatch = ''
    cp midnight.theme.css $out
  '';
}
