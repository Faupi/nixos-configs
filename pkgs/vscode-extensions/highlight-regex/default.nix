{ fetchFromGitHub
, fop-vscode-utils
}:
fop-vscode-utils.buildVscodeExtension rec {
  vscodeExtPublisher = "MickaelBlet";
  vscodeExtName = "highlight-regex";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = vscodeExtPublisher;
    repo = vscodeExtName;
    rev = "v${version}";
    sha256 = "sha256-ty6E5BMOL6ACxlTAnCrvJsSDm7XuNrrJ9Val2QUPP7A=";
  };

  sourceRoot = "source";
}
