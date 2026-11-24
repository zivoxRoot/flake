{ ... }:

{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;

    autoInstall.enable = true;

    settings = {
      formatters_by_ft = {
        bash = [ "shfmt" ];
        # c = [ "cland-format" ];
        nix = [ "nixfmt" ];
        python = [
          "ruff_format"
          "ruff_organize_imports"
        ];
        javascript = [ "prettier" ];
        typescript = [ "prettier" ];
        typescriptreact = [ "prettier" ];
        lua = [ "stylua" ];
      };

      # Skip formatting C
      format_on_save.__raw = ''
        function(bufnr)
          local ft = vim.bo[bufnr].filetype
          if ft == "c" or ft == "cpp" then
            return
          end
          return { timeout_ms = 500, lsp_format = "fallback" }
        end
      '';

      format_on_save = {
        timeout_ms = 500;
        lsp_format = "fallback";
      };
    };
  };
}
