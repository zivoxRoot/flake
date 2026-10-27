{ config, vars, ... }:

{
  # xdg.configFile."matugen" = {
  # 	# source = config.lib.file.mkOutOfStoreSymlink "/home/lostfromlight/.dotfiles/modules/quickshell";
  # 	source = config.lib.file.mkOutOfStoreSymlink "/home/${vars.username}/.dotfiles/modules/matugen";
  # 	recursive = true;
  # };
  home.file.".config/matugen/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/home/programs/matugen/config.toml";

  home.file.".config/matugen/templates".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/home/programs/matugen/templates";
}
