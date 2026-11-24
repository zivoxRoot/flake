{ pkgs, ... }:

{
  imports = [
    ./aliases.nix
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    history = {
      size = 10000;
      ignoreAllDups = true;
      path = "$HOME/.zsh_history";
    };

    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
    ];

    initContent = ''
      fpath+=("${pkgs.pure-prompt}/share/zsh/site-functions")
      # Zsh keybindings
      bindkey '^[f' autosuggest-accept
      bindkey '^N' history-search-forward
      bindkey '^P' history-search-backward
      # bindkey '^[l' forward-word
      # bindkey '^[h' backward-word

      # Zsh options
      setopt autocd
      setopt correct

      # History
      setopt appendhistory
      setopt sharehistory
      setopt hist_ignore_space
      setopt hist_ignore_all_dups
      setopt hist_save_no_dups
      setopt hist_ignore_dups
      setopt hist_find_no_dups

      # Function to create a directory and cd into it
      mkcd() {
        mkdir -p -- "$1" && cd "$1"
      }

      # Completion styling
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

      # FZF
      source <(${pkgs.fzf}/bin/fzf --zsh)

      # Zoxide
      eval "$(${pkgs.zoxide}/bin/zoxide init --cmd cd zsh)"

      # Zsh autosuggestions
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      # Zsh syntax highlighting
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

      autoload -U promptinit; promptinit
      prompt pure
    '';
  };
}
