{ lib, ... }:

{
  options = {
    profile.build = lib.mkOption {
      default = { };
      type =
        with lib.types;
        submoduleWith { modules = [ { freeformType = lazyAttrsOf (uniq unspecified); } ]; };
    };
  };
}
