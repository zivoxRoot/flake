{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    enablePrivateDesktopEntry = true;
    nativeMessagingHosts = [ pkgs.firefoxpwa ];

    profiles.${config.home.username} = rec {
      isDefault = true;
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "zen.workspaces.natural-scroll" = true;
        "zen.view.compact.hide-tabbar" = true;
        "zen.view.compact.hide-toolbar" = true;
        "zen.view.compact.animate-sidebar" = true;
        "zen.welcome-screen.seen" = true;
        "zen.urlbar.behavior" = "float";

        "zen.view.window.scheme" = 2;
        "layout.css.prefers-color-scheme.content-override" = 2;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.translations.enable" = false;
        "browser.translations.automaticallyPopup" = false;
        "layout.spellcheckdefault" = 0;
      };

      # Matugen-generated colors. The files live in the persisted state dir so
      # they survive reboots; switch-theme.sh regenerates them on theme change.
      userChrome = ''@import "matugen/userChrome.css";'';
      userContent = ''@import "matugen/userContent.css";'';

      mods = [
        "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
        "4ab93b88-151c-451b-a1b7-a1e0e28fa7f8" # No Sidebar Scrollbar
        "7190e4e9-bead-4b40-8f57-95d852ddc941" # Tab title fixes
        "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
        "c6813222-6571-4ba6-8faf-58f3343324f6" # Disable Rounded Corners
        "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
        "d8b79d4a-6cba-4495-9ff6-d6d30b0e94fe" # Better Active Tab
        "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
        "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
        "fd24f832-a2e6-4ce9-8b19-7aa888eb7f8e" # Quietify
        "79dde383-4fe7-404a-a8e6-9be440022542" # Tidy popups
      ];

      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
      ];

      pinsForce = true;
      pins = {
        # Essential pins (visible on all spaces)
        "Mail" = {
          id = "48e8a119-5a14-4826-9545-91c8e8dd3bf6";
          url = "https://ksuite.infomaniak.com/1118659/mail";
          position = 101;
          isEssential = true;
        };
        "Claude" = {
          id = "42e8a119-5a14-4826-9545-91c8e8dd3bf6";
          url = "https://claude.ai/new";
          position = 102;
          isEssential = true;
        };
        "ChatGPT" = {
          id = "22e8a119-5a14-4826-9545-91c8e8dd3bf6";
          url = "https://chatgpt.com";
          position = 103;
          isEssential = true;
        };

        # School 42
        "Github" = {
          id = "42e8a419-5a14-4827-9545-91c8e8dd3bf6";
          url = "https://github.com";
          position = 104;
          workspace = spaces."School42".id;
          isEssential = false;
        };
        "Intra" = {
          id = "42e8a419-5a14-4827-9545-91c8b8dd3bf6";
          url = "https://profile.intra.42.fr";
          position = 105;
          workspace = spaces."School42".id;
          isEssential = false;
        };
        "Doc" = {
          id = "42e8a419-5a14-4827-9545-91c8b8ud3bf6";
          url = "https://docs.42mulhouse.fr";
          position = 106;
          workspace = spaces."School42".id;
          isEssential = false;
        };
        "Slack" = {
          id = "2b255698-e7da-48a4-9e3a-21833d60cc8f";
          url = "https://app.slack.com";
          position = 107;
          workspace = spaces."School42".id;
          isEssential = false;
        };

        # EMG pins
        "Github EMG" = {
          title = "Github";
          id = "42i8a219-5a14-4827-9845-91c8e8dd3bf6";
          url = "https://github.com/Ecole-Mathias-Grunewald/emg-web";
          position = 104;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
        "Notion" = {
          id = "42u4a219-5a11-4827-9825-91b8e8dd3bf3";
          url = "https://app.notion.com";
          position = 105;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
        "Mural" = {
          id = "42u4a219-5a11-4827-9845-91c8e8dd3bf6";
          url = "https://app.mural.co";
          position = 106;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
        "Figjam" = {
          id = "42u4a219-5a11-4822-9845-91c5e8dd2bf7";
          url = "https://www.figma.com";
          position = 107;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
        "Moodle 13e" = {
          id = "42u4a219-5v11-4822-9843-91c5e8dd2bf9";
          url = "https://13eclasse.fr";
          position = 108;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
        "Mail EMG" = {
          id = "22u4a519-5i11-4822-9843-91c5e8dd2bf9";
          url = "https://ecole-mathias-grunewald.org:2096";
          position = 109;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
        "Coolify Mat" = {
          id = "22u4a519-5i11-4822-9843-91c5e3dd2bf9";
          url = "https://coolify.zhkcloud.ovh/";
          position = 110;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
        "Platform" = {
          id = "3c0d946c-3bc4-4c5b-9bda-5ad71fda5ffc";
          url = "https://emg-platform.zhkcloud.ovh";
          position = 111;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
        "Ovh" = {
          id = "c4490636-3138-4f67-af2a-8d470bafecde";
          url = "https://manager.eu.ovhcloud.com";
          position = 112;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
        "Mistral" = {
          id = "e5e75b97-53c8-40bb-a771-607ab84294e1";
          url = "https://console.mistral.ai/home";
          position = 113;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
        "Coolify prod" = {
          id = "1db454e1-b113-4776-b7a9-a51c1e953bac";
          url = "https://coolify.almilia.fr";
          position = 114;
          workspace = spaces."Emg".id;
          isEssential = false;
        };
      };

      spacesForce = true;
      spaces = {
        Home = {
          id = "572910e1-4468-4832-a869-0b3a93e2f165";
          icon = "🏠";
          position = 1000;
        };
        School42 = {
          id = "cdd10fab-4fc5-494b-9041-325e5759195b";
          icon = "💻";
          position = 2000;
        };
        Emg = {
          id = "c6de089c-410d-4206-961d-ab11f988d40a";
          icon = "📚";
          position = 3000;
        };
      };

      keyboardShortcuts = [
        {
          id = "zen-compact-mode-toggle";
          key = "b";
          modifiers.alt = true;
        }
        {
          id = "zen-compact-mode-show-sidebar"; # toggle floating sideboar
          key = "o";
          modifiers.alt = true;
        }
        {
          id = "key_savePage";
          key = "s";
          modifiers.control = true;
        }
        {
          id = "key_quitApplication";
          disabled = true;
        }
      ];
    };

    policies = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommand = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      NoDefaultBookmarks = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      SanitizeOnShutdown = {
        FormData = true;
        Cache = true;
      };
    };
  };

  # Expose the matugen output to Zen's chrome directory. The generated CSS
  # lives in the persisted state dir, so matugen and home-manager never fight
  # over the same file.
  home.file.".local/state/quickshell-config/zen/.keep".text = "";

  home.file.".config/zen/${config.home.username}/chrome/matugen".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/state/quickshell-config/zen";
}
