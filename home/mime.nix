{ ... }:

{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # PDFs
      "application/pdf" = "org.pwmt.zathura.desktop";

      # Web content
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "text/html" = "librewolf.desktop";

      # Images
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/jpg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/tiff" = "imv.desktop";

      # Videos
      "video/*" = "mpv.desktop";
    };
  };
}
