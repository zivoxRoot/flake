{ config, ... }:

{
  programs.nixvim.plugins.treesitter = {
    enable = true;

    grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
      bash
      javascript
      latex
      lua
      markdown
      python
      typescript
      vim
      vimdoc
    ];

    highlight.enable = true;
    indent.enable = true;
    folding.enable = true;
  };
}
