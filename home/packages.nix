{
  nixpkgs,
  pkgs,
  inputs,
  ...
}:

{
  home.packages = with pkgs; [
    # Desktop
    rofi
    waybar
    dunst
    brightnessctl
    bluez
    xwayland-satellite
    libnotify
    playerctl
    wl-clipboard
    adwaita-icon-theme
    awww
    matugen

    gnome.gvfs
    udiskie
    exfatprogs
    ntfs3g

    # GUI applications
    telegram-desktop
    nautilus
    satty
    imv
    localsend
    qbittorrent
    google-chrome

    # CLI tools
    ffmpeg
    yt-dlp
    kew
    imagemagick
    wf-recorder
    slurp
    grim
    # hyprshot TODO: Needed?
    tesseract
    whisper-cpp
    sops
    age
    vm-curator
    caligula
    openssl
    gh
    jq

    # Programming
    vim
    tmux
    claude-code
    devcontainer
    python315
    nodejs
    jdk25
    gcc
    gdb
    rustc
    rustup
    nixfmt
    biome
    quickshell

    # Base commands
    tree
    pciutils
    usbutils
    wget

    # Utils
    zip
    unzip

    # Fonts
    noto-fonts-color-emoji

    # Misc
    fastfetch
  ];
}
