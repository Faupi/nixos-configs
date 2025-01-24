{ fetchFromGitHub
, fop-vscode-utils
}:
fop-vscode-utils.buildVscodeExtension rec {
  vscodeExtPublisher = "MickaelBlet";
  vscodeExtName = "highlight-regex";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = vscodeExtPublisher;
    repo = vscodeExtName;
    rev = "v${version}";
    sha256 = "sha256-uzoHxZ4OxNghWsK1/zY2/V486EUqZtlq4Bn8k4OiRY4=";
  };

  sourceRoot = "source";
}
