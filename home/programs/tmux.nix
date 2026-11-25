{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    sensibleOnTop = false; # home-manager loads tmux-sensible by default; this keeps tmux vanilla
    keyMode = "vi";

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          			set -g @resurrect-dir '$HOME/.local/share/tmux/resurrect'
          			set -g @resurrect-capture-pane-contents 'on'
          			set -g @resurrect-strategy-vim 'session'
        '';
      }
      {
        plugin = continuum; # keep it after resurrect
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      set -g status-style "bg=black,fg=white"
      set -g window-status-current-style "bg=blue,fg=black,bold"
      set -g pane-border-style "fg=brightblack"
      set -g pane-active-border-style "fg=blue"
      set -g message-style "bg=black,fg=blue"
    '';
  };
}
