{ ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "/home/theophile/Documents/sync/music";
    extraConfig = ''
      		  audio_output {
      			type "pipewire"
      			name "PipeWire"
      		  }
      		'';
  };

  services.mpdris2 = {
    enable = true;
    settings.Bling.notify = false;
  };

  programs.rmpc = {
    enable = true;
  };
}
