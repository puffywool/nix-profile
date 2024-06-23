{ lib }:

{
  evalConfig = import ./eval-config.nix { inherit lib; };
}
