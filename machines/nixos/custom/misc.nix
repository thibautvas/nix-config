{
  pkgs,
  ...
}:

{
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;
    config = {
      user = {
        name = "thibautvas";
        email = "thibaut.vas@gmail.com";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  virtualisation.libvirtd.enable = true;
  users.users.thibautvas.extraGroups = [ "docker" ];
}
