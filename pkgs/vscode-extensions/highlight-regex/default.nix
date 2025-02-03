{ fetchFromGitHub
, fop-vscode-utils
}:
fop-vscode-utils.buildVscodeExtension rec {
  vscodeExtPublisher = "faupi";
  vscodeExtName = "highlight-regex";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = vscodeExtPublisher;
    repo = vscodeExtName;
    rev = "d73f3f7664d578f1e9e65ef31e9e4f4dc431c438";
    sha256 = "sha256-qZSsD/PvUzCfgJ7KTlTyrKoy6yEspAl7zE8NvLHM3V4=";
  };

  sourceRoot = "source";
}
