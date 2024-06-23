{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.environment;

  exportedEnvVars =
    let
      variables = lib.mapAttrs (n: lib.toList) cfg.variables;
      exportVariables = lib.mapAttrsToList (
        n: v: ''export ${n}="${lib.concatStringsSep ":" v}"''
      ) variables;
    in
    lib.concatStringsSep "\n" exportVariables;
in
{
  options = {
    environment = {
      packages = lib.mkOption {
        internal = true;
        type = with lib.types; listOf package;
        default = [ ];
      };

      pathsToLink = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };

      extraOutputsToInstall = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };

      extraSetup = lib.mkOption {
        type = lib.types.lines;
        default = "";
      };

      variables = lib.mkOption {
        type =
          with lib.types;
          attrsOf (oneOf [
            (listOf (oneOf [
              float
              int
              str
            ]))
            float
            int
            str
            path
          ]);
        default = { };
        apply = lib.mapAttrs (
          n: v: if lib.isList v then lib.concatMapStringsSep ":" toString v else toString v
        );
      };
    };
  };

  config = {
    environment.pathsToLink = [ "/bin" ];

    profile.build.path = pkgs.buildEnv {
      inherit (cfg) pathsToLink extraOutputsToInstall;

      name = "nix-profile-sw";
      paths = cfg.packages;
      postBuild = ''${cfg.extraSetup}'';
    };

    profile.build.setEnvironment = pkgs.writeText "set-environment" ''
      # DO NOT EDIT -- this file has been generated automatically.

      # Prevent this file from being sourced by child shells.
      export __NIX_PROFILE_SET_ENVIRONMENT_DONE=1

      ${exportedEnvVars}
    '';
  };
}
