{ ... }: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "codium.desktop";
      "text/html" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
      # TODO: add the rest
    };
  };
}
