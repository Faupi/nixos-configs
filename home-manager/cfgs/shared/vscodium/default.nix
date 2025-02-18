{ config, lib, pkgs, fop-utils, ... }:
let
  regex = string: string; # TODO: replace in usage with a dummy regex function from utils?

  # Make user configurations mutable
  # Depends on home-manager/modules/mutability.nix
  # https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa
  mutabilityWrapper = (builtins.fetchurl {
    url = "https://gist.githubusercontent.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa/raw/41e569ba110eb6ebbb463a6b1f5d9fe4f9e82375/vscode.nix";
    sha256 = "fed877fa1eefd94bc4806641cea87138df78a47af89c7818ac5e76ebacbd025f";
  });

  subCustomCSS = pkgs.substituteAll {
    src = ./custom-css.css;
    leafTheme = pkgs.leaf-theme-kde;
  };
  vscodium-custom-css = pkgs.vscodium.overrideAttrs (oldAttrs: {
    installPhase =
      let
        workbenchPath = "vs/code/electron-sandbox/workbench/workbench.html";
      in
      (oldAttrs.installPhase or "") + ''
        echo "Add custom CSS"
        substituteInPlace "$out/lib/vscode/resources/app/out/${workbenchPath}" \
          --replace-warn '<head>' '<head><style type="text/css">${builtins.replaceStrings [ "'" ] [ "'\\''" ] (builtins.readFile subCustomCSS)}</style>'

        echo "Update checksum of main HTML with custom CSS"
        checksum=$(${lib.getExe pkgs.nodejs} ${./print-checksum.js} "$out/lib/vscode/resources/app/out/${workbenchPath}")
        ${lib.getExe pkgs.jq} ".checksums.\"${workbenchPath}\" = \"$checksum\"" "$out/lib/vscode/resources/app/product.json" | ${lib.getExe' pkgs.moreutils "sponge"} "$out/lib/vscode/resources/app/product.json"
      '';
  });
in
{
  imports = [
    mutabilityWrapper
    ./snippets.nix
  ];

  # Needed fonts
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.liberation # #FF0
    cascadia-code # #0FF
  ];

  apparmor.profiles.vscodium.target = lib.getExe config.programs.vscode.package;

  xdg.mimeApps.associations.added = {
    "text/plain" = [ "codium.desktop" ];
    "inode/directory" = [ "codium.desktop" ];
  };

  programs = {
    vscode = fop-utils.recursiveMerge [

      #region General
      {
        enable = true;
        package = pkgs.symlinkJoin {
          name = "vscodium-custom";
          inherit (vscodium-custom-css) pname version meta;
          paths = [ vscodium-custom-css ];
          buildInputs = with pkgs; [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/codium \
              --set NIXOS_OZONE_WL 1 \
              --set NIXD_FLAGS "--semantic-tokens=true" \
              --prefix PATH : ${lib.makeBinPath (with pkgs; [
                # TODO: Add custom option for exposed packages and move wrapping there
                sass
                
                # Go - templ
                go
                templ
                gopls
              ])}
          '';
        };
        extensions =
          with pkgs.unstable;
          with vscode-extensions;
          with vscode-utils;
          [
            esbenp.prettier-vscode
            naumovs.color-highlight
            (extensionFromVscodeMarketplace {
              name = "RunOnSave";
              publisher = "emeraldwalk";
              version = "0.3.2";
              sha256 = "sha256-p1379+Klc4ZnKzlihmx0yCIp4wbALD3Y7PjXa2pAXgI=";
            })
            (extensionFromVscodeMarketplace {
              name = "direnv";
              publisher = "mkhl";
              version = "0.17.0";
              sha256 = "sha256-9sFcfTMeLBGw2ET1snqQ6Uk//D/vcD9AVsZfnUNrWNg=";
            })
          ];

        userSettings = {
          # Updates
          "update.mode" = "none";
          "extensions.autoUpdate" = false;
          "extensions.autoCheckUpdates" = false;

          # UI
          "workbench.editor.labelFormat" = "short"; # Always show directory in tab
          "breadcrumbs.enabled" = true;
          "window.titleBarStyle" = "custom";
          "window.menuBarVisibility" = "visible";
          "workbench.activityBar.location" = "top";
          "workbench.layoutControl.enabled" = false;
          "window.experimentalControlOverlay" = false; # BAD (overlay is broken and unstylable)

          # Git
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.inputValidation" = false;
          "github.gitProtocol" = "ssh";

          # Tabs
          "editor.insertSpaces" = true; # Use spaces for indentation
          "editor.tabSize" = 2; # 2 spaces
          "editor.detectIndentation" = true; # If a document is set up differently, use that format

          # Misc
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.formatOnSave" = true;
          "workbench.startupEditor" = "none"; # No welcome page
          "terminal.integrated.gpuAcceleration" = "on"; # NOTE: When enabled, it used to cut off input text on intel graphics
          "terminal.integrated.defaultProfile.linux" = "zsh";
          "terminal.integrated.scrollback" = 5000; # Increase scrollback in terminal (default 1000)

          "workbench.editor.customLabels.enabled" = true;
          "workbench.editor.customLabels.patterns" = {
            "**/default.nix" = "\${dirname}.\${extname}";
          };

          "direnv.restart.automatic" = true;

          "color-highlight.matchRgbWithNoFunction" = true;
          "color-highlight.markRuler" = false;
        };
      }

      #region Visuals
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "material-icon-theme";
            publisher = "PKief";
            version = "4.33.0";
            sha256 = "sha256-Rwpc5p7FOSodGa1WWrjgkexzAp8RlgZCYBXhep1G5Pk=";
          })
        ];
        userSettings = {
          # Workbench
          "workbench.iconTheme" = "material-icon-theme";
          "workbench.colorTheme" = "Default Dark Modern";
          "workbench.colorCustomizations" = {
            "statusBar.background" = "#007ACC";
            "statusBar.foreground" = "#F0F0F0";
            "statusBar.noFolderBackground" = "#222225";
            "statusBar.debuggingBackground" = "#511f1f";
          };

          # Explorer
          "explorer.fileNesting.enabled" = true;
          "explorer.fileNesting.expand" = false;
          "explorer.fileNesting.patterns" = {
            # TODO: Maybe find a way to update this automagically
            # updated 2025-01-18 07:16
            # https://github.com/antfu/vscode-file-nesting-config
            "*.asax" = "$(capture).*.cs, $(capture).*.vb";
            "*.ascx" = "$(capture).*.cs, $(capture).*.vb";
            "*.ashx" = "$(capture).*.cs, $(capture).*.vb";
            "*.aspx" = "$(capture).*.cs, $(capture).*.vb";
            "*.axaml" = "$(capture).axaml.cs";
            "*.bloc.dart" = "$(capture).event.dart, $(capture).state.dart";
            "*.c" = "$(capture).h";
            "*.cc" = "$(capture).hpp, $(capture).h, $(capture).hxx, $(capture).hh";
            "*.cjs" = "$(capture).cjs.map, $(capture).*.cjs, $(capture)_*.cjs";
            "*.component.ts" = "$(capture).component.html, $(capture).component.spec.ts, $(capture).component.css, $(capture).component.scss, $(capture).component.sass, $(capture).component.less";
            "*.cpp" = "$(capture).hpp, $(capture).h, $(capture).hxx, $(capture).hh";
            "*.cs" = "$(capture).*.cs";
            "*.cshtml" = "$(capture).cshtml.cs";
            "*.csproj" = "*.config, *proj.user, appsettings.*, bundleconfig.json";
            "*.css" = "$(capture).css.map, $(capture).*.css";
            "*.cxx" = "$(capture).hpp, $(capture).h, $(capture).hxx, $(capture).hh";
            "*.dart" = "$(capture).freezed.dart, $(capture).g.dart";
            "*.db" = "*.db-shm, *.db-wal";
            "*.ex" = "$(capture).html.eex, $(capture).html.heex, $(capture).html.leex";
            "*.fs" = "$(capture).fs.js, $(capture).fs.js.map, $(capture).fs.jsx, $(capture).fs.ts, $(capture).fs.tsx, $(capture).fs.rs, $(capture).fs.php, $(capture).fs.dart";
            "*.go" = "$(capture)_test.go";
            "*.java" = "$(capture).class";
            "*.js" = "$(capture).js.map, $(capture).*.js, $(capture)_*.js, $(capture).d.ts, $(capture).js.flow";
            "*.jsx" = "$(capture).js, $(capture).*.jsx, $(capture)_*.js, $(capture)_*.jsx, $(capture).module.css, $(capture).less, $(capture).module.less, $(capture).module.less.d.ts, $(capture).scss, $(capture).module.scss, $(capture).module.scss.d.ts";
            "*.master" = "$(capture).*.cs, $(capture).*.vb";
            "*.md" = "$(capture).*";
            "*.mjs" = "$(capture).mjs.map, $(capture).*.mjs, $(capture)_*.mjs";
            "*.module.ts" = "$(capture).resolver.ts, $(capture).controller.ts, $(capture).service.ts";
            "*.mts" = "$(capture).mts.map, $(capture).*.mts, $(capture)_*.mts";
            "*.pubxml" = "$(capture).pubxml.user";
            "*.py" = "$(capture).pyi";
            "*.razor" = "$(capture).razor.cs, $(capture).razor.css, $(capture).razor.scss";
            "*.resx" = "$(capture).*.resx, $(capture).designer.cs, $(capture).designer.vb";
            "*.tex" = "$(capture).acn, $(capture).acr, $(capture).alg, $(capture).aux, $(capture).bbl, $(capture).bbl-SAVE-ERROR, $(capture).bcf, $(capture).blg, $(capture).fdb_latexmk, $(capture).fls, $(capture).glg, $(capture).glo, $(capture).gls, $(capture).idx, $(capture).ind, $(capture).ist, $(capture).lof, $(capture).log, $(capture).lot, $(capture).nav, $(capture).out, $(capture).run.xml, $(capture).snm, $(capture).synctex.gz, $(capture).toc, $(capture).xdv";
            "*.ts" = "$(capture).js, $(capture).d.ts.map, $(capture).*.ts, $(capture)_*.js, $(capture)_*.ts";
            "*.tsx" = "$(capture).ts, $(capture).*.tsx, $(capture)_*.ts, $(capture)_*.tsx, $(capture).module.css, $(capture).less, $(capture).module.less, $(capture).module.less.d.ts, $(capture).scss, $(capture).module.scss, $(capture).module.scss.d.ts, $(capture).css.ts";
            "*.vbproj" = "*.config, *proj.user, appsettings.*, bundleconfig.json";
            "*.vue" = "$(capture).*.ts, $(capture).*.js, $(capture).story.vue";
            "*.w" = "$(capture).*.w, I$(capture).w";
            "*.wat" = "$(capture).wasm";
            "*.xaml" = "$(capture).xaml.cs";
            "+layout.svelte" = "+layout.ts,+layout.ts,+layout.js,+layout.server.ts,+layout.server.js,+layout.gql";
            "+page.svelte" = "+page.server.ts,+page.server.js,+page.ts,+page.js,+page.gql";
            ".clang-tidy" = ".clang-format, .clangd, compile_commands.json";
            ".env" = "*.env, .env.*, .envrc, env.d.ts";
            ".gitignore" = ".gitattributes, .gitmodules, .gitmessage, .mailmap, .git-blame*";
            ".project" = ".classpath";
            "BUILD.bazel" = "*.bzl, *.bazel, *.bazelrc, bazel.rc, .bazelignore, .bazelproject, WORKSPACE";
            "CMakeLists.txt" = "*.cmake, *.cmake.in, .cmake-format.yaml, CMakePresets.json, CMakeCache.txt";
            "Cargo.toml" = ".clippy.toml, .rustfmt.toml, cargo.lock, clippy.toml, cross.toml, rust-toolchain.toml, rustfmt.toml";
            "Dockerfile" = "*.dockerfile, .devcontainer.*, .dockerignore, captain-definition, compose.*, docker-compose.*, dockerfile*";
            "I*.cs" = "$(capture).cs";
            "Makefile" = "*.mk";
            "Pipfile" = ".editorconfig, .flake8, .isort.cfg, .python-version, Pipfile, Pipfile.lock, requirements*.in, requirements*.pip, requirements*.txt, tox.ini";
            "README*" = "AUTHORS, Authors, BACKERS*, Backers*, CHANGELOG*, CITATION*, CODEOWNERS, CODE_OF_CONDUCT*, CONTRIBUTING*, CONTRIBUTORS, COPYING*, CREDITS, Changelog*, Citation*, Code_Of_Conduct*, Codeowners, Contributing*, Contributors, Copying*, Credits, GOVERNANCE.MD, Governance.md, HISTORY.MD, History.md, LICENSE*, License*, MAINTAINERS, Maintainers, README-*, README_*, RELEASE_NOTES*, ROADMAP.MD, Readme-*, Readme_*, Release_Notes*, Roadmap.md, SECURITY.MD, SPONSORS*, Security.md, Sponsors*, authors, backers*, changelog*, citation*, code_of_conduct*, codeowners, contributing*, contributors, copying*, credits, governance.md, history.md, license*, maintainers, readme-*, readme_*, release_notes*, roadmap.md, security.md, sponsors*";
            "Readme*" = "AUTHORS, Authors, BACKERS*, Backers*, CHANGELOG*, CITATION*, CODEOWNERS, CODE_OF_CONDUCT*, CONTRIBUTING*, CONTRIBUTORS, COPYING*, CREDITS, Changelog*, Citation*, Code_Of_Conduct*, Codeowners, Contributing*, Contributors, Copying*, Credits, GOVERNANCE.MD, Governance.md, HISTORY.MD, History.md, LICENSE*, License*, MAINTAINERS, Maintainers, README-*, README_*, RELEASE_NOTES*, ROADMAP.MD, Readme-*, Readme_*, Release_Notes*, Roadmap.md, SECURITY.MD, SPONSORS*, Security.md, Sponsors*, authors, backers*, changelog*, citation*, code_of_conduct*, codeowners, contributing*, contributors, copying*, credits, governance.md, history.md, license*, maintainers, readme-*, readme_*, release_notes*, roadmap.md, security.md, sponsors*";
            "ansible.cfg" = "ansible.cfg, .ansible-lint, requirements.yml";
            "app.config.*" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, react-router.config.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";
            "artisan" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, react-router.config.*, rspack.config.*, server.php, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, webpack.mix.js, windi.config.*";
            "astro.config.*" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, react-router.config.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";
            "build-wrapper.log" = "build-wrapper*.log, build-wrapper-dump*.json, build-wrapper-win*.exe, build-wrapper-linux*, build-wrapper-macosx*";
            "composer.json" = ".php*.cache, composer.lock, phpunit.xml*, psalm*.xml";
            "default.nix" = "shell.nix";
            "deno.json*" = "*.env, .env.*, .envrc, api-extractor.json, deno.lock, env.d.ts, import-map.json, import_map.json, jsconfig.*, tsconfig.*, tsdoc.*";
            "flake.nix" = "flake.lock";
            "gatsby-config.*" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, gatsby-browser.*, gatsby-node.*, gatsby-ssr.*, gatsby-transformer.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, react-router.config.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";
            "gemfile" = ".ruby-version, gemfile.lock";
            "go.mod" = ".air*, go.sum";
            "go.work" = "go.work.sum";
            "hatch.toml" = ".editorconfig, .flake8, .isort.cfg, .python-version, hatch.toml, requirements*.in, requirements*.pip, requirements*.txt, tox.ini";
            "mix.exs" = ".credo.exs, .dialyzer_ignore.exs, .formatter.exs, .iex.exs, .tool-versions, mix.lock";
            "next.config.*" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, next-env.d.ts, next-i18next.config.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, react-router.config.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";
            "nuxt.config.*" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .nuxtignore, .nuxtrc, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, react-router.config.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";
            "package.json" = "*.code-workspace, .browserslist*, .circleci*, .commitlint*, .cspell*, .cursorrules, .cz-config.js, .czrc, .dlint.json, .dprint.json*, .editorconfig, .eslint*, .firebase*, .flowconfig, .github*, .gitlab*, .gitmojirc.json, .gitpod*, .huskyrc*, .jslint*, .knip.*, .lintstagedrc*, .ls-lint.yml, .markdownlint*, .node-version, .nodemon*, .npm*, .nvmrc, .pm2*, .pnp.*, .pnpm*, .prettier*, .pylintrc, .release-please*.json, .releaserc*, .ruff.toml, .sentry*, .simple-git-hooks*, .stackblitz*, .styleci*, .stylelint*, .tazerc*, .textlint*, .tool-versions, .travis*, .versionrc*, .vscode*, .watchman*, .xo-config*, .yamllint*, .yarnrc*, Procfile, apollo.config.*, appveyor*, azure-pipelines*, biome.json*, bower.json, build.config.*, bun.lock, bun.lockb, bunfig.toml, colada.options.ts, commitlint*, crowdin*, cspell*, dangerfile*, dlint.json, dprint.json*, electron-builder.*, eslint*, firebase.json, grunt*, gulp*, jenkins*, knip.*, lerna*, lint-staged*, nest-cli.*, netlify*, nixpacks*, nodemon*, npm-shrinkwrap.json, nx.*, package-lock.json, package.nls*.json, phpcs.xml, pm2.*, pnpm*, prettier*, pullapprove*, pyrightconfig.json, release-please*.json, release-tasks.sh, release.config.*, renovate*, rolldown.config.*, rollup.config.*, rspack*, ruff.toml, sentry.*.config.ts, simple-git-hooks*, sonar-project.properties, stylelint*, tslint*, tsup.config.*, turbo*, typedoc*, unlighthouse*, vercel*, vetur.config.*, webpack*, workspace.json, wrangler.toml, xo.config.*, yarn*";
            "pubspec.yaml" = ".metadata, .packages, all_lint_rules.yaml, analysis_options.yaml, build.yaml, pubspec.lock, pubspec_overrides.yaml";
            "pyproject.toml" = ".commitlint*, .cspell*, .dlint.json, .dprint.json*, .editorconfig, .eslint*, .flake8, .flowconfig, .isort.cfg, .jslint*, .lintstagedrc*, .ls-lint.yml, .markdownlint*, .pdm-python, .pdm.toml, .prettier*, .pylintrc, .python-version, .ruff.toml, .stylelint*, .textlint*, .xo-config*, .yamllint*, MANIFEST.in, Pipfile, Pipfile.lock, biome.json*, commitlint*, cspell*, dangerfile*, dlint.json, dprint.json*, eslint*, hatch.toml, lint-staged*, pdm.lock, phpcs.xml, poetry.lock, poetry.toml, prettier*, pyproject.toml, pyrightconfig.json, requirements*.in, requirements*.pip, requirements*.txt, ruff.toml, setup.cfg, setup.py, stylelint*, tox.ini, tslint*, uv.lock, uv.toml, xo.config.*";
            "quasar.conf.js" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, quasar.extensions.json, react-router.config.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";
            "readme*" = "AUTHORS, Authors, BACKERS*, Backers*, CHANGELOG*, CITATION*, CODEOWNERS, CODE_OF_CONDUCT*, CONTRIBUTING*, CONTRIBUTORS, COPYING*, CREDITS, Changelog*, Citation*, Code_Of_Conduct*, Codeowners, Contributing*, Contributors, Copying*, Credits, GOVERNANCE.MD, Governance.md, HISTORY.MD, History.md, LICENSE*, License*, MAINTAINERS, Maintainers, README-*, README_*, RELEASE_NOTES*, ROADMAP.MD, Readme-*, Readme_*, Release_Notes*, Roadmap.md, SECURITY.MD, SPONSORS*, Security.md, Sponsors*, authors, backers*, changelog*, citation*, code_of_conduct*, codeowners, contributing*, contributors, copying*, credits, governance.md, history.md, license*, maintainers, readme-*, readme_*, release_notes*, roadmap.md, security.md, sponsors*";
            "remix.config.*" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, react-router.config.*, remix.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";
            "requirements.txt" = ".editorconfig, .flake8, .isort.cfg, .python-version, requirements*.in, requirements*.pip, requirements*.txt, tox.ini";
            "rush.json" = "*.code-workspace, .browserslist*, .circleci*, .commitlint*, .cspell*, .cursorrules, .cz-config.js, .czrc, .dlint.json, .dprint.json*, .editorconfig, .eslint*, .firebase*, .flowconfig, .github*, .gitlab*, .gitmojirc.json, .gitpod*, .huskyrc*, .jslint*, .knip.*, .lintstagedrc*, .ls-lint.yml, .markdownlint*, .node-version, .nodemon*, .npm*, .nvmrc, .pm2*, .pnp.*, .pnpm*, .prettier*, .pylintrc, .release-please*.json, .releaserc*, .ruff.toml, .sentry*, .simple-git-hooks*, .stackblitz*, .styleci*, .stylelint*, .tazerc*, .textlint*, .tool-versions, .travis*, .versionrc*, .vscode*, .watchman*, .xo-config*, .yamllint*, .yarnrc*, Procfile, apollo.config.*, appveyor*, azure-pipelines*, biome.json*, bower.json, build.config.*, bun.lock, bun.lockb, bunfig.toml, colada.options.ts, commitlint*, crowdin*, cspell*, dangerfile*, dlint.json, dprint.json*, electron-builder.*, eslint*, firebase.json, grunt*, gulp*, jenkins*, knip.*, lerna*, lint-staged*, nest-cli.*, netlify*, nixpacks*, nodemon*, npm-shrinkwrap.json, nx.*, package-lock.json, package.nls*.json, phpcs.xml, pm2.*, pnpm*, prettier*, pullapprove*, pyrightconfig.json, release-please*.json, release-tasks.sh, release.config.*, renovate*, rolldown.config.*, rollup.config.*, rspack*, ruff.toml, sentry.*.config.ts, simple-git-hooks*, sonar-project.properties, stylelint*, tslint*, tsup.config.*, turbo*, typedoc*, unlighthouse*, vercel*, vetur.config.*, webpack*, workspace.json, wrangler.toml, xo.config.*, yarn*";
            "sanity.config.*" = "sanity.cli.*, sanity.types.ts, schema.json";
            "setup.cfg" = ".editorconfig, .flake8, .isort.cfg, .python-version, MANIFEST.in, requirements*.in, requirements*.pip, requirements*.txt, setup.cfg, tox.ini";
            "setup.py" = ".editorconfig, .flake8, .isort.cfg, .python-version, MANIFEST.in, requirements*.in, requirements*.pip, requirements*.txt, setup.cfg, setup.py, tox.ini";
            "shims.d.ts" = "*.d.ts";
            "svelte.config.*" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, houdini.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, mdsvex.config.js, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, react-router.config.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vite.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";
            "vite.config.*" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, react-router.config.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";
            "vue.config.*" = "*.env, .babelrc*, .codecov, .cssnanorc*, .env.*, .envrc, .htmlnanorc*, .lighthouserc.*, .mocha*, .postcssrc*, .terserrc*, api-extractor.json, ava.config.*, babel.config.*, capacitor.config.*, content.config.*, contentlayer.config.*, cssnano.config.*, cypress.*, env.d.ts, formkit.config.*, formulate.config.*, histoire.config.*, htmlnanorc.*, i18n.config.*, ionic.config.*, jasmine.*, jest.config.*, jsconfig.*, karma*, lighthouserc.*, panda.config.*, playwright.config.*, postcss.config.*, puppeteer.config.*, react-router.config.*, rspack.config.*, sst.config.*, svgo.config.*, tailwind.config.*, tsconfig.*, tsdoc.*, uno.config.*, unocss.config.*, vitest.config.*, vuetify.config.*, webpack.config.*, windi.config.*";

            # Custom
            "*.scss" = "\${capture}.css";
            "*.templ" = "\${capture}_templ.go";
            "devenv.nix" = ".devenv.flake.nix, devenv.lock, devenv.yaml";
          };

          # Editor 
          "editor.fontFamily" = "LiterationMono Nerd Font Mono, monospace"; # #FF0
          "editor.fontLigatures" = true;
          "editor.minimap.showSlider" = "always";
          "editor.minimap.renderCharacters" = false;
          "editor.suggest.preview" = true;
          "editor.acceptSuggestionOnEnter" = "off"; # TAB is enough, good to keep enter for newline
          "workbench.editor.wrapTabs" = true;

          # Terminal
          "terminal.integrated.fontFamily" = "Cascadia Mono NF SemiBold, monospace"; # #0FF
          "terminal.integrated.fontSize" = 14;
          "terminal.integrated.minimumContrastRatio" = 1; # Disable color tweaking
        };
      }

      # Spell check - TODO: Check if it's really worth using, Nix needs a ton of specific words added
      # {
      #   extensions = with pkgs.vscode-extensions; [ streetsidesoftware.code-spell-checker ];
      #   userSettings = {
      #     "cSpell.checkOnlyEnabledFileTypes" = false; # Disable filetypes with `"cSpell.enableFiletypes": ["!filetype"]`
      #     "cSpell.showAutocompleteSuggestions" = true;
      #     "cSpell.ignorePaths" = [
      #       "package-lock.json"
      #       "node_modules"
      #       "vscode-extension"
      #       ".git/objects"
      #       ".vscode"
      #       ".vscode-insiders"
      #       "result"
      #     ];
      #     "cSpell.userWords" = [
      #       "faupi"
      #     ];
      #   };
      # }

      #region Nix-IDE
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "nix-ide";
            publisher = "jnoortheen";
            version = "0.3.5";
            sha256 = "sha256-hiyFZVsZkxpc2Kh0zi3NGwA/FUbetAS9khWxYesxT4s=";
          })
        ];
        userSettings =
          let
            nixfmt-path = lib.getExe (with pkgs; with unstable;
              nixpkgs-fmt);
          in
          {
            "[nix]" = { "editor.defaultFormatter" = "jnoortheen.nix-ide"; };
            "nix.formatterPath" = nixfmt-path; # Fallback for LSP
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = lib.getExe (fop-utils.wrapPkgBinary {
              inherit pkgs;
              package = with pkgs; with unstable; nixd;
              nameAffix = "vscodium";
              variables.NIXD_FLAGS = "--semantic-tokens=true";
            });
            "nix.serverSettings" = {
              "nil" = {
                "formatting" = {
                  "command" = [ nixfmt-path ];
                };
                "nix" = {
                  "maxMemoryMB" = 4096;
                  "flake" = {
                    "autoArchive" = true;
                    "autoEvalInputs" = false;
                  };
                };
              };
              "nixd" = {
                "formatting" = {
                  "command" = [ nixfmt-path ];
                };
                "diagnostic" = {
                  "suppress" = [
                    "sema-escaping-with" # No "nested with" warnings, seems too finicky
                  ];
                };
                # Nixpkgs and options linking to be done per project
              };
            };

            # Suppress common (semi-random) errors 
            "nix.hiddenLanguageServerErrors" = [
              "textDocument/definition"
              "textDocument/documentSymbol"
            ];
          };
      }

      #region Shell
      {
        extensions =
          with pkgs.unstable;
          with vscode-extensions;
          with vscode-utils;
          [
            # Dependency for shfmt
            (editorconfig.editorconfig)

            (extensionFromVscodeMarketplace {
              name = "shfmt";
              publisher = "mkhl";
              version = "1.3.0";
              sha256 = "sha256-lmhCROQfVYdBO/fC2xIAXSa3CHoKgC3BKUYCzTD+6U0=";
            })
          ];

        userSettings = {
          "[shellscript]" = { "editor.defaultFormatter" = "mkhl.shfmt"; };
          "shfmt.executablePath" = lib.getExe (with pkgs;
            shfmt);
          "shfmt.executableArgs" = [ "--indent" "2" ];
        };
      }

      #region Sops
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "signageos-vscode-sops";
            publisher = "signageos";
            version = "0.9.1";
            sha256 = "sha256-b1Gp+tL5/e97xMuqkz4EvN0PxI7cJOObusEkcp+qKfM=";
          })
        ];
        userSettings = {
          "sops.binPath" = lib.getExe (with pkgs; with unstable;
            sops);
        };
      }

      #region Todo Tree
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          gruntfuggly.todo-tree
        ];
        userSettings = {
          "todo-tree.general.tags" = [ "BUG" "HACK" "FIXME" "TODO" "XXX" ];
        };
      }

      #region XML
      {
        extensions =
          with pkgs.unstable;
          with vscode-extensions;
          with vscode-utils;
          [
            redhat.vscode-xml
            (extensionFromVscodeMarketplace {
              name = "xml";
              publisher = "DotJoshJohnson";
              version = "2.5.1";
              sha256 = "sha256-ZwBNvbld8P1mLcKS7iHDqzxc8T6P1C+JQy54+6E3new=";
            })
          ];
        userSettings =
          let
            lemminxBinary = lib.getExe (with pkgs; with unstable;
              lemminx);
          in
          {
            "[xml]" = { "editor.defaultFormatter" = "DotJoshJohnson.xml"; };
            "redhat.telemetry.enabled" = false;
            "xml.server.binary.path" = lemminxBinary;
            "xml.server.binary.trustedHashes" = [ (builtins.hashFile "sha256" lemminxBinary) ];
            "xml.symbols.maxItemsComputed" = 30000;
          };
      }

      #region GitLens
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          eamodio.gitlens
        ];
      }

      #region Python
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          ms-python.python
        ];
        userSettings = {
          "[python]" = { "editor.defaultFormatter" = "ms-python.python"; };
          "python.formatting.blackPath" = lib.getExe (with pkgs;
            black);
          "python.formatting.blackArgs" = [ "--line-length 120" ];
        };
      }

      #region Markdown
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "markdown-inline-preview-vscode";
            publisher = "domdomegg";
            version = "1.1.0";
            sha256 = "sha256-mi9Skn3tVJfoQaRxsOV3WRVNXhnunDOMyu/oQV2ZiWs=";
          })
        ];

        # Taken from the expansion's recommended settings
        userSettings = {
          "[markdown]" = {
            "editor.autoClosingBrackets" = "never";
            "editor.bracketPairColorization.enabled" = false;
            "editor.cursorBlinking" = "phase";
            "editor.fontFamily" = "Fira Sans";
            "editor.fontSize" = 13;
            "editor.guides.indentation" = false;
            "editor.indentSize" = "tabSize";
            "editor.insertSpaces" = false;
            "editor.lineHeight" = 1.5;
            "editor.lineNumbers" = "off";
            "editor.matchBrackets" = "never";
            "editor.padding.top" = 20;
            "editor.quickSuggestions" = { comments = false; other = false; strings = false; };
            "editor.tabSize" = 6;
            "editor.wrappingStrategy" = "advanced";
          };
          "editor.tokenColorCustomizations" = {
            "[Default Dark Modern]" = {
              textMateRules = [
                {
                  scope = "punctuation.definition.list.begin.markdown";
                  settings = { foreground = "#777"; };
                }
              ];
            };
          };
        };
      }

      #region Golang
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "Go";
            publisher = "golang";
            version = "0.45.0";
            sha256 = "sha256-w/74OCM1uAJzjlJ91eDoac6knD1+Imwfy6pXX9otHsY=";
          })
          (extensionFromVscodeMarketplace {
            name = "templ";
            publisher = "a-h";
            version = "0.0.29";
            sha256 = "sha256-RZ++wxL2OqBh3hiLAwKIw5QLjU/imsK7irQUHbJ/tqM=";
          })
        ];

        userSettings = {
          "[templ]" = {
            "editor.defaultFormatter" = "a-h.templ";
          };
        };
      }

      #region Hyperscript
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "vscode-hyperscript-org";
            publisher = "dz4k";
            version = "0.1.5";
            sha256 = "sha256-SrLsP4jzg8laA8LQnZ8QzlBOypVZb/e05OAW2jobyPw=";
          })
        ];
      }

      #region HTMX
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "htmx-attributes";
            publisher = "CraigRBroughton";
            version = "0.8.0";
            sha256 = "sha256-TsemPZkq2Z13/vahRaP7z206BJaCZ1TR6OVv6aeDvyk=";
          })
        ];
      }

      #region Highlight regex
      {
        extensions = [
          pkgs.vscode-extensions.highlight-regex
        ];

        userSettings =
          let
            colorDefault = "#fff";
            colorDefaultBG = "#77F2";
            colorTag = "#666";

            colorAnchor = "#B40";
            colorQuantifier = "#1899f4";
            colorBackreference = "#ff3dff";

            colorEscapingChar = "#da70d6FF";
            colorEscapedChar = "#ffbffcff";

            colorGroupExpression = "#0F0F";
            colorGroupBracket = "#0B0F";
            colorGroupBGFirst = "#00FF0020";
            colorGroupBGOther = "#00FF0015";
            colorGroupOverline = "#00FF0050";

            colorCharClass = "#F90F";
            colorCharSet = colorCharClass;
            colorCharSetBG = "#b26b00AA";

            noEscape = regex ''(?<=(?:^|[^\\])(?:\\\\)*)'';
          in
          {
            "highlight.regex.regexes" = [
              {
                languageIds = [ "nix" ];
                name = "Regular expressions";
                regexes = [
                  {
                    "_name" = "Main regular expression";
                    regex = regex ''(?<tag>regex)\s*(?<quote>\'\'|'|")(?<regex>.*?)((?<=[^\\](\\\\)*)\k<quote>\s*;)'';
                    regexFlag = "g";
                    regexLimit = 1000;
                    decorations = [
                      {
                        index = "tag";
                        color = colorTag;
                      }
                      {
                        index = "regex";
                        color = colorDefault;
                        backgroundColor = colorDefaultBG;
                      }
                    ];
                    regexes = [

                      #region Quantifiers
                      {
                        "_name" = "Quantifiers";
                        index = "regex";
                        regex = regex ''[+?*|]|(\{\d+(,\d*)?\})'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorQuantifier;
                            index = 0;
                          }
                        ];
                      }

                      #region Anchors
                      {
                        "_name" = "Anchors";
                        index = "regex";
                        regex = regex ''${noEscape}(\\[bB]|[$^])'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorAnchor;
                            index = 0;
                          }
                        ];
                      }

                      #region Character sets
                      {
                        "_name" = "Character sets";
                        index = "regex";
                        regex = regex ''${noEscape}(?<bracketL>\[\^?)(?<contents>.*?)((?<=[^\\](\\\\)*)(?<bracketR>]))'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            index = 0;
                            backgroundColor = colorCharSetBG;
                          }
                          {
                            index = "bracketL";
                            color = colorCharSet;
                          }
                          {
                            index = "bracketR";
                            color = colorCharSet;
                          }
                        ];
                        regexes = [
                          # Exceptions for character sets
                          {
                            "_name" = "Character set exceptions";
                            index = "contents";
                            # NOTE: Turns out catching any escaped character might just be enough
                            regex = regex ''(?<others>\\[\s\S])*(?<literals>[\s\S])'';
                            regexFlag = "g";
                            decorations = [
                              {
                                index = "literals";
                                color = colorDefault;
                              }
                            ];
                          }
                        ];
                      }

                      #region Escaped characters
                      {
                        "_name" = "Escaped characters";
                        index = "regex";
                        regex = regex ''(?<escape>\\)(?<char>.)'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            "color" = colorEscapingChar;
                            "index" = "escape";
                          }
                          {
                            "color" = colorEscapedChar;
                            "index" = "char";
                          }
                        ];
                      }

                      #region Backreferences
                      {
                        "_name" = "Backreferences";
                        index = "regex";
                        regex = regex ''${noEscape}\\(\d+|k<(?<groupName>[A-Za-z0-9_]+)>)'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            index = 0;
                            color = colorBackreference;
                          }
                          {
                            "index" = "groupName";
                            "fontStyle" = "italic";
                          }
                        ];
                      }

                      #region Character classes
                      {
                        "_name" = "Character classes";
                        index = "regex";
                        regex = regex ''${noEscape}(\.|\\[wWdDsS])'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorCharClass;
                            index = 0;
                          }
                        ];
                      }

                      #region Brackets
                      {
                        # Level 1
                        "_name" = "Brackets";
                        index = "regex";
                        # Note: Existing bracket formatting will break on this as it has more nesting levels than the regex itself supports ofc
                        regex = regex ''${noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L3>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L4>\(.*?(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
                        regexFlag = "g";
                        regexLimit = 10000;
                        decorations = [
                          {
                            index = "L1";
                            backgroundColor = colorGroupBGFirst;
                            textDecoration = "overline ${colorGroupOverline} solid 0.2em";
                          }
                        ];
                        regexes = [
                          # Nesting (background)
                          {
                            # Level 2
                            index = "L1c";
                            regex = regex ''${noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L3>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
                            regexFlag = "g";
                            regexLimit = 10000;
                            decorations = [
                              {
                                index = "L1";
                                backgroundColor = colorGroupBGOther;
                                textDecoration = "overline ${colorGroupOverline} solid 0.25em";
                              }
                            ];
                            regexes = [
                              {
                                # Level 3
                                index = "L1c";
                                regex = regex ''${noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
                                regexFlag = "g";
                                regexLimit = 10000;
                                decorations = [
                                  {
                                    index = "L1";
                                    backgroundColor = colorGroupBGOther;
                                    textDecoration = "overline ${colorGroupOverline} solid 0.375em";
                                  }
                                ];
                                regexes = [
                                  {
                                    # Level 4
                                    index = "L1c";
                                    regex = regex ''${noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*))(?<=(?:[^\\])(?:\\\\)*)\))'';
                                    regexFlag = "g";
                                    regexLimit = 10000;
                                    decorations = [
                                      {
                                        index = "L1";
                                        backgroundColor = colorGroupBGOther;
                                        textDecoration = "overline ${colorGroupOverline} solid 0.5em";
                                      }
                                    ];
                                  }
                                ];
                              }
                            ];
                          }

                          # Expressions (font)
                          {
                            "_name" = "Expressions (font)";
                            index = 0;
                            regex = regex ''${noEscape}\(\?(=|!|<=|<!|:|<(?<groupName>[A-Za-z0-9_]+)>)'';
                            regexFlag = "g";
                            regexLimit = 1000;
                            decorations = [
                              {
                                index = "groupName";
                                fontStyle = "italic";
                              }
                              {
                                index = 0;
                                color = colorGroupExpression;
                              }
                            ];
                          }

                          # Brackets (font)
                          {
                            "_name" = "Brackets (font)";
                            index = 0;
                            regex = regex ''${noEscape}[()]'';
                            regexFlag = "g";
                            regexLimit = 1000;
                            decorations = [
                              {
                                color = colorGroupBracket;
                                index = 0;
                              }
                            ];
                          }
                        ];
                      }

                      #region Nix substitions
                      {
                        "_name" = "Nix substitions";
                        index = "regex";
                        # Fun fact! This should show as NOT a substition and look broken!
                        regex = regex ''(?<!\'\')\''${.*?}'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorBackreference;
                            index = 0;
                          }
                        ];
                      }
                    ];
                  }
                ];
              }
            ];
          };
      }
    ];
  };
}
