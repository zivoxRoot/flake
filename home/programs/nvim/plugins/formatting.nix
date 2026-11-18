{ ... }:

{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;

    autoInstall.enable = true;

    settings = {
      formatters_by_ft = {
        lua = [ "stylua" ];
        python = [ "black" ];
        javascript = [ "prettier" ];
        typescript = [ "prettier" ];
      };

      format_on_save = {
        timeout_ms = 500;
        lsp_format = "fallback";
      };
    };
  };
}
