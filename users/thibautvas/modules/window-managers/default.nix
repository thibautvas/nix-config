{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

{
  imports = [ (if isDarwin then ./aerospace else ./hyprland) ];
}
