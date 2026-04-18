{ stdenv
, fetchFromGitHub
, kernel ? null
, lib
}:
stdenv.mkDerivation {
  pname = "lenovo-legion-go-wmi-fan";
  version = "unstable-20260320";

  src = fetchFromGitHub {
    owner = "honjow";
    repo = "lenovo-legion-go-wmi-fan";
    rev = "60365f1204aa97aaa0604c27197530c2474c90cd";
    hash = "sha256-MPLD+kbZSJT1tnU71QB1LJMofIoaY6LlXF2MpHku5Ck=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = /*sh*/ ''
    runHook preInstall

    # Define the target directory for the kernel module
    MOD_DEST="$out/lib/modules/${kernel.modDirVersion}/extra"
    mkdir -p "$MOD_DEST"
      
    # Copy the compiled module(s)
    find . -name "*.ko" -exec cp {} "$MOD_DEST/" \;

    runHook postInstall
  '';

  meta = with lib; {
    description = "Lenovo Legion Go WMI Fan Control Driver";
    homepage = "https://github.com/honjow/lenovo-legion-go-wmi-fan";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
