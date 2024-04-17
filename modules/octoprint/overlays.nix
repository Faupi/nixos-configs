{ ... }: {
  nixpkgs.overlays = [
    (self: super: {
      octoprint = super.octoprint.override {
        packageOverrides = pyself: pysuper: {
          widescreen = pyself.buildPythonPackage {
            pname = "Widescreen";
            version = "unstable-2024-01-14";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-WideScreen";
              rev = "90f7f01f3c632ce5c672df87d22e0f2ead06531c";
              sha256 = "0d029nm8w0wahgr8whphlff91i477zqsy9dh0nbkphx380ba3p52";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          cura-thumbnails = pyself.buildPythonPackage {
            pname = "Cura Thumbnails";
            version = "unstable-2024-01-14";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-UltimakerFormatPackage";
              rev = "3289da5e4cff07678bc4ba38ea8fbcbf3ef44c3c";
              sha256 = "1y7y3n1iaicn6a3q769gsdpxx0rybh11anmkfr0jv37nhpasz8bs";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          heater-timeout = pyself.buildPythonPackage {
            pname = "Better Heater Timeout";
            version = "unstable-2020-10-25";
            src = self.fetchFromGitHub {
              owner = "tjjfvi";
              repo = "OctoPrint-BetterHeaterTimeout";
              rev = "35fe9de684a8af2db3629e1546cde1f7a94c41e3";
              sha256 = "014p63l9z7r5xz421cf5bdlnjvbzsiknjpknmnjfz17ifbibs4dl";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          pretty-gcode = pyself.buildPythonPackage {
            pname = "Pretty GCode";
            version = "unstable-2021-10-11";
            src = self.fetchFromGitHub {
              owner = "Kragrathea";
              repo = "OctoPrint-PrettyGCode";
              rev = "a121aae3958a9d76cbc576056b3341056cbda28c";
              sha256 = "0n6mslgf1mi1s03i7pgdwar21m3rr1l5a0bcdqx1s3bixqxrba1i";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          custom-css = pyself.buildPythonPackage {
            pname = "Custom CSS";
            version = "unstable-2020-12-10";
            src = self.fetchFromGitHub {
              owner = "crankeye";
              repo = "OctoPrint-CustomCSS";
              rev = "7a042b11055592b42b59298ad8d579b731081acd";
              sha256 = "15hm4j1l84jlacmdcvprgk4hr82q40pqbbzrqnsjikcakmly741p";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          exclude-region = pyself.buildPythonPackage {
            pname = "Exclude Region";
            version = "unstable-2022-12-07";
            src = self.fetchFromGitHub {
              owner = "bradcfisher";
              repo = "OctoPrint-ExcludeRegionPlugin";
              rev = "81ffc932138598e6446ad02b287f439eb03b4989";
              sha256 = "05949iix8rvl638lq85di5wjzyyh8kanfscwp0br3myqmsbbnbk1";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
        };
      };
    })
  ];
}
