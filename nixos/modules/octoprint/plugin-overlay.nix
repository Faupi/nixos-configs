{ ... }: {
  nixpkgs.overlays = [
    (self: super: {
      octoprint = super.octoprint.override {
        packageOverrides = pyself: pysuper: {
          dashboard = pyself.buildPythonPackage {
            pname = "Dashboard";
            version = "unstable-2024-05-19";
            src = self.fetchFromGitHub {
              owner = "j7126";
              repo = "OctoPrint-Dashboard";
              rev = "de5732ae65c4be3b27b16cb89ea603b52baa3c1b";
              sha256 = "1x9hsa4lshq71850wgb45cl1iv8p758smxampvp5cbviclihlks7";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          widescreen = pyself.buildPythonPackage {
            pname = "Widescreen";
            version = "unstable-2024-05-29";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-WideScreen";
              rev = "b11ff2d0c30a6ada2cd1cbf1e388c6e7dd15224d";
              sha256 = "1qhp134as2vf10jsymkd98qcadd29p2s6axihm35w0s5dn90x89w";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          cura-thumbnails = pyself.buildPythonPackage {
            pname = "Cura Thumbnails";
            version = "unstable-2024-07-22";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-UltimakerFormatPackage";
              rev = "8f7ed0c4e875da2e06726c6968377bc91907ab0a";
              sha256 = "1xdmzz9s2li802k35vg1pb6wfc152qzmbjkq24zsqpij874zklij";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          slicer-thumbnails = pyself.buildPythonPackage {
            pname = "Slicer Thumbnails";
            version = "unstable-2024-07-22";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-PrusaSlicerThumbnails";
              rev = "719066a30eeb41e771712a59c26e8e79c7ad65d2";
              sha256 = "0wzc3p80bsfhys2hvpsz1d6d95z03qqmv6a5pbrfx8hf2lv8d065";
            };
            propagatedBuildInputs = [ pysuper.octoprint pysuper.pillow ];
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
          ui-customizer = pyself.buildPythonPackage {
            pname = "UI Customizer";
            version = "unstable-2024-02-12";
            src = self.fetchFromGitHub {
              owner = "LazeMSS";
              repo = "OctoPrint-UICustomizer";
              rev = "48317dda7768961d62c168fad86e6e22aa53ac2f";
              sha256 = "0nawym2s9g7aqndpbwvlb0i6s80hni0fla79rlfngnza307hqgs4";
            };
            patches = [
              ./ui-customizer-discoranged.patch # Add discoranged into the local files as it's yet another plugin that uses its own directory for cache
            ];
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          temp-control = pyself.buildPythonPackage {
            pname = "Consolidate Temp Control";
            version = "unstable-2024-05-29";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-ConsolidateTempControl";
              rev = "418cbbdd080768233e2051cfc8a18ac6ba082071";
              sha256 = "0hds3236gl6n95sjdz3xq151373kf1145jr4vgapsnhylszkn7qp";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
        };
      };
    })
  ];
}
