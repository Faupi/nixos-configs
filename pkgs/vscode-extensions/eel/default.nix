{ fetchFromGitHub
, fop-vscode-utils
}:
fop-vscode-utils.buildVscodeExtension {
  vscodeExtPublisher = "eclairevoyant";
  vscodeExtName = "eel";
  version = "unstable-20251107";

  src = fetchFromGitHub {
    owner = "Faupi";
    repo = "eel";
    rev = "d482eac384387612cf304014eaf036aeb8dcd72a";
    hash = "sha256-sfsNtdO93wo0s84mmOrTvQPgf2GbmYlDUboH5ixWfUU=";
  };

  sourceRoot = "source";
}
