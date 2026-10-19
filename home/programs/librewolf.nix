{ pkgs, inputs, ... }:

{
  programs.librewolf = {
    enable = true;

    profiles = {
      default = {
        id = 0;
        name = "Default";
        isDefault = true;

        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          bitwarden
        ];

        bookmarks = {
          force = true;
          settings = [
            {
              name = "Toolbar";
              toolbar = true;
              bookmarks = [
                {
                  name = "GitHub";
                  url = "https://github.com";
                }
                {
                  name = "Mail";
                  url = "https://ksuite.infomaniak.com/mail";
                }
                {
                  name = "Claude";
                  url = "https://claude.ai/new";
                }
                {
                  name = "ChatGPT";
                  url = "https://chatgpt.com/";
                }
                {
                  name = "Emg";
                  bookmarks = [
                    {
                      name = "GitHub";
                      url = "https://github.com/Ecole-Mathias-Grunewald/emg-web";
                    }
                    {
                      name = "Moodle 13e";
                      url = "https://13eclasse.fr";
                    }
                    {
                      name = "Dev platform";
                      url = "localhost:3000";
                    }
                    {
                      name = "Dev cursus";
                      url = "localhost:3001";
                    }
                  ];
                }
                {
                  name = "Nix";
                  bookmarks = [
                    {
                      name = "NixOS Search";
                      url = "https://search.nixos.org/packages";
                    }
                    {
                      name = "My Nixos";
                      url = "https://mynixos.com";
                    }
                  ];
                }
                {
                  name = "Local";
                  bookmarks = [
                    {
                      name = "Syncthing";
                      url = "http://localhost:8384";
                    }
                    {
                      name = "Printing";
                      url = "http://localhost:631";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
    };

    settings = {
      "webgl.disabled" = false;
      "privacy.resistFingerprinting" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;

      "extensions.autoDisableScopes" = 0;
      "extensions.enabledScopes" = 15;
      "extensions.activeThemeID" = "default-theme@mozilla.org";

      "layout.css.prefers-color-scheme.content-override" = 2;

      "ui.key.menuAccessKeyFocuses" = false;

      "browser.startup.page" = 3;
      "browser.fullscreen.autohide" = false;
      "browser.translation.enable" = false;
      "browser.translations.automaticallyPopup" = false;
      "geo.enabled" = false;

      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.archive.enabled" = false;

      "dom.battery.enabled" = false;
    };
  };
}
