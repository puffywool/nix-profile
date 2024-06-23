{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.user;
in
{
  options = {
    user = {
      packages = lib.mkOption {
        type = with lib.types; listOf package;
        default = [ ];
      };
    };
  };

  config = {
    environment.packages = cfg.packages;
  };
}
