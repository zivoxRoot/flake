{ config, ... }:

{
  programs.nixvim.plugins.treesitter = {
    enable = true;

    grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
      bash
      c
      javascript
      json
      latex
      lua
      make
      markdown
      nix
      python
      tsx
      typescript
      vim
      vimdoc
    ];

    highlight.enable = true;
    indent.enable = true;
  };
}
