{ lib
, swig
, blender
}:
let
  py-slvs = pythonPkgs:
    pythonPkgs.buildPythonPackage {
      pname = "py-slvs";
      version = "1.0.6";

      src = pythonPkgs.fetchPypi {
        pname = "py_slvs";
        version = "1.0.6";
        sha256 = "sha256-U6T/aXy0JTC1ptL5oBmch0ytSPmIkRA8XOi31NpArnI=";
      };

      nativeBuildInputs = [ swig ];
      pyproject = true;

      propagatedBuildInputs = with pythonPkgs; [
        cmake
        ninja
        setuptools
        scikit-build
      ];

      dontUseCmakeConfigure = true;

      meta = with lib; {
        description = "Python binding of SOLVESPACE geometry constraint solver";
        homepage = "https://github.com/realthunder/slvs_py";
        license = licenses.gpl3;
      };
    };

  blenderWithPySlvs = blender.withPackages (p: [ (py-slvs p) ]);
  finalBlender = blenderWithPySlvs.overrideAttrs (oldAttrs: {
    pname = "cad-blender";
  });
in
finalBlender
