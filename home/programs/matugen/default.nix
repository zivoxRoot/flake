{ config, vars, ... }:

{
  home.file.".config/matugen/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/home/programs/matugen/config.toml";

  home.file.".config/matugen/templates".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/home/programs/matugen/templates";
}
