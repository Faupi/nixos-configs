{ config, pkgs, lib, ... }: {
  nixpkgs.overlays = with lib; [(self: super: {
    octoprint = super.octoprint.override {
      packageOverrides = pyself: pysuper: {
        widescreen = pyself.buildPythonPackage rec {
          pname = "Widescreen";
          version = "0.1.4";
          src = self.fetchFromGitHub {
            owner = "jneilliii";
            repo = "OctoPrint-WideScreen";
            rev = "${version}";
            sha256 = "sha256-y0yINi03e8YutsdHckSfjZtob8Je3Ff1aSbQxtLnbgw=";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
        };
        cura-thumbnails = pyself.buildPythonPackage rec {
          pname = "Cura Thumbnails";
          version = "1.0.2";
          src = self.fetchFromGitHub {
            owner = "jneilliii";
            repo = "OctoPrint-UltimakerFormatPackage";
            rev = "${version}";
            sha256 = "sha256-EvD3apeFV4WbeCdxBwFOtv4Luaid7RojQg6XYUTY2NQ=";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
        };
        heater-timeout = pyself.buildPythonPackage rec {
          pname = "Better Heater Timeout";
          version = "1.3.0";
          src = self.fetchFromGitHub {
            owner = "tjjfvi";
            repo = "OctoPrint-BetterHeaterTimeout";
            rev = "v${version}";
            sha256 = "sha256-tBG94nLxhO+krXZeaWfUf21paVvFsSDI7yWfn+gwlwQ=";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
        };
        pretty-gcode = pyself.buildPythonPackage rec {
          pname = "Pretty GCode";
          version = "1.2.4";
          src = self.fetchFromGitHub {
            owner = "Kragrathea";
            repo = "OctoPrint-PrettyGCode";
            rev = "v${version}";
            sha256 = "sha256-q/B2oEy+D6L66HqmMkvKfboN+z3jhTQZqt86WVhC2vQ=";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
        };
        custom-css = pyself.buildPythonPackage rec {
          pname = "Custom CSS";
          version = "master";
          src = self.fetchFromGitHub {
            owner = "crankeye";
            repo = "OctoPrint-CustomCSS";
            rev = "7a042b11055592b42b59298ad8d579b731081acd";
            sha256 = "sha256-N5DjaZ2KzSi1xfmvhS8gWKAMyXz5btYqU1QSRIMkFZY=";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
        };
      };
    };
  })];
}