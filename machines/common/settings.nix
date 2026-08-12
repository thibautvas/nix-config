{
  flakes,
  ...
}:

{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    registry = {
      templates.flake = flakes.templates;
      tv.flake = flakes.self;
    };
  };
}
