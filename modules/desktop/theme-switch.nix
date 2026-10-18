{
  config,
  pkgs,
  vars,
  ...
}:

{
  # stable path to the current HM generation, updated on every rebuild
  environment.etc."hm-gen".source = config.home-manager.users.${vars.username}.home.activationPackage;

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "theme-toggle" ''
      set -eu
      state="''${XDG_STATE_HOME:-$HOME/.local/state}/theme"
      if [ "$(cat "$state" 2>/dev/null)" = "light" ]; then
        /etc/hm-gen/activate && echo dark > "$state"
      else
        /etc/hm-gen/specialisation/light/activate && echo light > "$state"
      fi
      # reload things that don't pick up changes on their own
      pkill -USR1 kitty || true
      pkill -USR2 waybar || true
      dunstctl reload || true
    '')
  ];
}
