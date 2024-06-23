{ lib }:

let
  baseModules = import ./modules/module-list.nix;
in
{
  modules ? [ ],
  specialArgs ? { },
}:
let
  eval = lib.evalModules {
    inherit specialArgs;
    modules = baseModules ++ modules;
  };
in
eval.config.profile.build.toplevel
