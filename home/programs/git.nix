{ vars, ... }:

{
  programs.git = {
    enable = true;

    settings.user = {
      name = vars.gitUsername;
      email = vars.gitEmail;

      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.navigate = true;
    };
  };
}
