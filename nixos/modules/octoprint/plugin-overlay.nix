{ ... }: {
  nixpkgs.overlays = [
    (self: super: {
      octoprint = super.octoprint.override {
        packageOverrides = pyself: pysuper: {
          dashboard = pyself.buildPythonPackage {
            pname = "Dashboard";
            version = "unstable-2024-10-06";
            src = self.fetchFromGitHub {
              owner = "j7126";
              repo = "OctoPrint-Dashboard";
              rev = "1f4ddb836e8481f54d3748bf92cba2f1daf4d8c4";
              sha256 = "0iv87bqnqdhc5spq1jwyjzaswlw0i9zgk021mygnckq502f3z7p3";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          widescreen = pyself.buildPythonPackage {
            pname = "Widescreen";
            version = "unstable-2024-09-19";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-WideScreen";
              rev = "afa395fc62eaed433c7bdc67f3b024424d305ae3";
              sha256 = "0cdvbhhia2iaqw82mld2igip85s1wv4bfzmlnp0lldzmlrdza7v4";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          cura-thumbnails = pyself.buildPythonPackage {
            pname = "Cura Thumbnails";
            version = "unstable-2024-09-19";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-UltimakerFormatPackage";
              rev = "2267f91ce2984497f9d37c717b980337d1b1f0d1";
              sha256 = "1m9clwlqwl1msx2wa7v59h11kxq0h2261sk7z1wvjhjwaz3isrqf";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
          slicer-thumbnails = pyself.buildPythonPackage {
            pname = "Slicer Thumbnails";
            version = "unstable-2024-11-13";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-PrusaSlicerThumbnails";
              rev = "2275d22d1ce814fc8758af0feef71646f30cc15d";
              sha256 = "0nw5z05n42cid65ynbiyf68zzzw46xmf47wjnqbqam5pi3mk2dg5";
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
            version = "unstable-2024-09-19";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-ConsolidateTempControl";
              rev = "42e4c66b07c218d1e1adb69d7ae65e4d8ada394a";
              sha256 = "1h6cf34mymr23lxmgsdv54r8j4vp3pmxsnacm002mjzbvxb7s6pa";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
            doCheck = false;
          };
        };
      };
    })
  ];
}
