{ pkgs, lib, ... }: {
  programs.plasma.klipper.actions =
    let
      regex = string: string; # Funny highlights
      wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
      minify = lib.getExe pkgs.minify;
      sed = lib.getExe pkgs.gnused;
      cat = lib.getExe' pkgs.coreutils "cat";
    in
    {
      "Unspecified software versioning" = {
        automatic = true;
        regexp = regex ''(\w+) Version:? (\d+\.\d+\.\d+)[\s\S]*?\bStage:? (\w+)[\s\S]*?\b(\w+) Version:? (\d{4}\d{2,4}\.\d+)'';
        commands =
          let
            substituteCommon = source: pkgs.substituteAll {
              src = source;
              environmentinfo = builtins.readFile ./jira-templates/environment-info.html;
            };

            jira-template = source: ''
              ${cat} '${substituteCommon source}' |
                ${sed} -e 's/@stage@/%3/
                           s/@component1@/%1/
                           s/@version1@/%2/
                           s/@component2@/%4/
                           s/@version2@/%5/' |
                ${minify} --type text/html | 
                ${wl-copy} --type text/html
            '';
          in
          {
            "Create \"Test OK\" Jira template" = {
              command = jira-template ./jira-templates/test-ok.html;
              icon = builtins.fetchurl {
                url = "https://pf-emoji-service--cdn.us-east-1.prod.public.atl-paas.net/atlassian/check_mark_32.png";
                sha256 = "sha256:0l18354j8xm8mqa9k2abvpqwba0m023gpmmr7brhdzlmayaxcfzc";
              };
              output = "ignore";
            };
            "Create \"Test NOT OK\" Jira template" = {
              command = jira-template ./jira-templates/test-not-ok.html;
              icon = builtins.fetchurl {
                url = "https://pf-emoji-service--cdn.us-east-1.prod.public.atl-paas.net/atlassian/cross_mark_32.png";
                sha256 = "sha256:1xcq52s38d82c33hmnp1asszds1b9r5hj57pk3xiil13hc1vyfsx";
              };
              output = "ignore";
            };
          };
      };
    };
}
