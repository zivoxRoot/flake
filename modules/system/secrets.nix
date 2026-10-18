{config, vars,...}:

{
	sops = {
		defaultSopsFile = ../../secrets/secrets.yaml;

		# Private key path
		age.keyFile = "/var/lib/sops-nix/key.txt";

		secrets = {
			password = {
				neededForUsers = true;
			};

			"ssh/public_key" = {
				owner = vars.username;
				mode = "0400";
				path = "/home/${vars.username}/.ssh/id_ed25519.pub";
			};
			"ssh/private_key" = {
				owner = vars.username;
				mode = "0400";
				path = "/home/${vars.username}/.ssh/id_ed25519";
			};
		};
	};
}
