{ pkgs, ... }:

{
  programs.obsidian = {
    enable = true;

    vaults.notes = {
      target = "Documents/sync/vault";
    };

    defaultSettings = {
      appearance.theme = "obsidian";

      communityPlugins = [
        {
          pkg = pkgs.obsidianPlugins.obsidian-excalidraw-plugin;
          settings = {
            matchTheme = true;
            folder = "assets";
          };
        }
      ];

      app = {
        showInlineTitle = false;
        openBehavior = "daily";
        attachmentFolderPath = "assets";
        defaultViewMode = "preview";
        spellcheck = false;
        newFileLocation = "folder";
        newFileFolderPath = "notes";
        alwaysUpdateLinks = true;
      };
    };
  };
}
