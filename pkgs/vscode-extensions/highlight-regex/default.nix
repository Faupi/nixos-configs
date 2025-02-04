{ fetchFromGitHub
, fop-vscode-utils
}:
fop-vscode-utils.buildVscodeExtension rec {
  vscodeExtPublisher = "MickaelBlet";
  vscodeExtName = "highlight-regex";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = vscodeExtPublisher;
    repo = vscodeExtName;
    rev = "v${version}";
    sha256 = "sha256-0RvrU+008XouCiDD5tRqSeg+jvWRRkeLIW0NvVZl6e8=";
  };

  sourceRoot = "source";
}
