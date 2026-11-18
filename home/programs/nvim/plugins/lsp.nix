{ ... }:

{
  programs.nixvim = {
    plugins.lspconfig.enable = true;
    plugins.tiny-inline-diagnostic.enable = true;

    lsp = {
      servers = {
        lua_ls = {
          enable = true;
          config.settings.Lua.diagnostics.globals = [ "vim" ];
        };

        pyright.enable = true;

        markdown_oxide = {
          enable = true;
          config.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true;
        };
      };

      # Keymaps that only apply once a language server attaches.
      keymaps = [
        {
          mode = "n";
          key = "K";
          lspBufAction = "hover";
          options.desc = "LSP hover";
        }
        {
          mode = "n";
          key = "<leader>rn";
          lspBufAction = "rename";
          options.desc = "LSP rename";
        }
        {
          mode = "n";
          key = "<leader>ca";
          lspBufAction = "code_action";
          options.desc = "LSP code action";
        }
        {
          mode = "n";
          key = "[d";
          action.__raw = "vim.diagnostic.goto_prev";
          options.desc = "Previous diagnostic";
        }
        {
          mode = "n";
          key = "]d";
          action.__raw = "vim.diagnostic.goto_next";
          options.desc = "Next diagnostic";
        }
      ];
    };

    diagnostic.settings.virtual_text = false;
  };
}
