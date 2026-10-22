{config, ... }:

{
	my.backup.services.jellyfin = {
		unit  = "jellyfin.service";
		path  = config.services.jellyfin.dataDir;
		owner = config.services.jellyfin.user;
		group = config.services.jellyfin.group;
	};

	services.jellyfin = {
		enable = true;
		dataDir = "/mnt/data/jellyfin";
		openFirewall = false;
	};

# Never start before the SSD is mounted. Otherwise Jellyfin would silently
# create a fresh empty install on the root fs.
	systemd.services.jellyfin.unitConfig.RequiresMountsFor = "/mnt/data";

# Media folders, readable by jellyfin and writable by your login user
	users.groups.media = { };
	users.users.jellyfin.extraGroups = [ "media" ];

	systemd.tmpfiles.rules = [
		"d /mnt/data/media         2775 root media -"
			"d /mnt/data/media/movies  2775 root media -"
			"d /mnt/data/media/shows   2775 root media -"
	];
}
