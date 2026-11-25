{ fetchFromGitHub
, fop-vscode-utils
}:
fop-vscode-utils.buildVscodeExtension rec {
  vscodeExtPublisher = "MickaelBlet";
  vscodeExtName = "highlight-regex";
  version = "2.3.3";

  src = fetchFromGitHub {
    owner = vscodeExtPublisher;
    repo = vscodeExtName;
    rev = "v${version}";
    sha256 = "sha256-8sCVX87axrS+cYIOmFA8CMB2FGdSgNPfeqRd1mmyogo=";
  };

  sourceRoot = "source";
}
