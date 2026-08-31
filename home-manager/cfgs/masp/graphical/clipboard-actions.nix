{ pkgs, ... }:
{
  services.clipboardActions.rules =
    let
      regex = string: string; # Funny highlights

      # Partials
      environmentinfo = builtins.readFile ./jira-templates/partials/environment-info.html;
      showcase = builtins.readFile ./jira-templates/partials/showcase.html;

      # Substition + formatter + copy wrapper
      jira-template = source: /*sh*/''
        cat '${source}' |
          sed -e 's/::stage::/%3/
                     s/::component1::/%1/
                     s/::version1::/%2/
                     s/::component2::/%4/
                     s/::version2::/%5/' |
          minify --type text/html |
          wl-copy --type text/html
      '';
    in
    [
      {
        name = "Unspecified software versioning";
        regex = regex ''(\w+) Version:? (\d+\.\d+\.\d+)[\s\S]*?\bStage:? (\w+)[\s\S]*?\b(\w+) Version:? (\d{4}\d{2,4}\.\d+)'';
        commands = [
          {
            label = "Create environment info Jira snippet";
            runtimeInputs = with pkgs; [
              coreutils
              gnused
              minify
              wl-clipboard
            ];
            command = jira-template ./jira-templates/partials/environment-info.html;
            output = "ignore";
          }

          {
            label = "Create \"Test OK\" Jira template";
            runtimeInputs = with pkgs; [
              coreutils
              gnused
              minify
              wl-clipboard
            ];
            command = jira-template (
              pkgs.replaceVars ./jira-templates/test-ok.html {
                inherit
                  environmentinfo
                  showcase;
              }
            );
            output = "ignore";
          }

          {
            label = "Create \"Test NOT OK\" Jira template";
            runtimeInputs = with pkgs; [
              coreutils
              gnused
              minify
              wl-clipboard
            ];
            command = jira-template (
              pkgs.replaceVars ./jira-templates/test-not-ok.html {
                inherit
                  environmentinfo;
              }
            );
            output = "ignore";
          }
        ];
      }

      {
        name = "Unspecified device information";
        regex = regex ''Device Type\s+(?<model>\b.+)[\s\S]*?Image Version\s+(?<version>\b.+)[\s\S]*?Serial Number\s+.*?H: (?<serial>\d+)'';
        commands = [
          {
            label = "Create device info Jira snippet";
            runtimeInputs = with pkgs; [
              coreutils
              gnused
              minify
              wl-clipboard
            ];
            command = /*sh*/''
              cat '${./jira-templates/partials/environment-device.html}' |
                sed -e 's/::model::/%1/
                           s/::serial::/%3/
                           s/::version::/%2/' |
                minify --type text/html |
                wl-copy --type text/html
            '';
            output = "ignore";
          }
        ];
      }
    ];
}
