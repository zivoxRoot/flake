{ lib, ... }:

# NOTE: Part of next 'NOTE' block
let
  luaDir = ./lua;

  luaFiles = lib.attrNames (
    lib.filterAttrs (
      name: type: type == "regular" && lib.hasSuffix ".lua" name && name != "hyprland.lua"
    ) (builtins.readDir luaDir)
  );
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    # withUWSM = true;

    # NOTE: To remove later, temporary solution to loads my lua-based hyprland config
    extraLuaFiles = lib.listToAttrs (
      map (f: {
        name = "lua." + lib.removeSuffix ".lua" f; # -> ~/.config/hypr/lua/<name>.lua
        value = {
          content = luaDir + "/${f}";
          autoLoad = true;
        };
      }) luaFiles
    );

    # NOTE: Works to load minimal config
    # extraConfig = builtins.readFile ./hyprland.lua;

    # TODO: Later use this integrated system
    # settings = {
    # 	"mod" = "SUPER";

    # 	bind = [
    # 		"SUPER, Return, exec, kitty"
    # 		"SUPER, Q, killactive"
    # 		"SUPER, F, fullscreen"
    # 	] ++ (builtins.concatLists (builtins.genList (i:
    # 		let ws = toString (i + 1); in [
    # 			"SUPER, code:1${toString i}, workspace, ${ws}"
    # 			"SUPER, SHIFT, code:1${toString i}, movetoworkspace, ${ws}"
    # 		]) 9));

    # 	monitors = [
    # 		"eDP-1, preferred, 0x0, 1.2"
    # 		"HDMI-A-2, highres, auto-center-up, 1.0"
    # 	];

    # 	# Variables
    # 	"terminal" = "kitty";
    # 	"menu" = "rofi --show drun";

    # 	general = {
    # 		gaps_in = 8;
    # 		gaps_out = 18;
    # 		border_size = 3;
    # 	};

    # 	gestures = {
    # 		workspace_swipe = true;
    # 		workspace_swipe_fingers = 3;
    # 	};
    # };
  };
}
