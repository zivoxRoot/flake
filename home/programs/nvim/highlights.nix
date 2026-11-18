{ ... }:

{
  programs.nixvim.extraConfigLua = ''
    -- Hide the square popup borders and make floating windows blend in.
    -- Kept in Lua because blink.cmp draws its own menu/doc/signature windows.
    local function set_float_highlights()
      vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
      vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })

      vim.api.nvim_set_hl(0, "Pmenu", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "PmenuSel", { link = "Visual" })
      vim.api.nvim_set_hl(0, "PmenuSbar", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "PmenuThumb", { link = "Visual" })

      vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "BlinkCmpDoc", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { link = "FloatBorder" })
    end

    set_float_highlights()

    -- matugen re-applies the palette on SIGUSR1, which wipes these links.
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_float_highlights,
    })
  '';
}
