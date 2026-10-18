{ ... }:

{
  services.hyprsunset = {
    enable = true;

    settings = {
      max-gamma = 150;

      profile = [
        {
          time = "7:30";
          identity = true;
        }
        {
          time = "20:00";
          temperature = 5500;
          gamma = 0.8;
        }
      ];
    };
  };
}
