{ ... }: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "codium.desktop";
      "text/html" = "vivaldi-stable.desktop";
      "x-scheme-handler/http" = "vivaldi-stable.desktop";
      "x-scheme-handler/https" = "vivaldi-stable.desktop";
      "x-scheme-handler/about" = "vivaldi-stable.desktop";
      "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
      # TODO: add the rest
    };
  };
}
