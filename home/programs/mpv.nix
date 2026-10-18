{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;

    scripts = with pkgs.mpvScripts; [
      uosc
      sponsorblock
      thumbfast
    ];

    config = {
      cache = "yes";

      demuxer-max-bytes = "1GiB";
      demuxer-max-back-bytes = "200MiB";

      hwdec = "auto-safe";

      profile = "high-quality";

      ytdl-format = "bestvideo+bestaudio/best";
    };
  };
}
