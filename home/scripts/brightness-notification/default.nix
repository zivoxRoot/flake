{pkgs,...}:

let
brightness-notification = pkgs.writeShellApplication {
	name = "brightness-notification";
	runtimeInputs = with pkgs; [ dunst brightnessctl ];
	text = builtins.readFile ./brightness-notification.sh;
};
in
{
	home.packages = [
		brightness-notification
	];
}
