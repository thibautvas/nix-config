{
  self,
  templates,
  pkgs,
  ...
}:

{
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    registry = {
      templates.flake = templates;
      tv.flake = self;
    };
  };
}
