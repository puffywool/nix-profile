{
  config,
  lib,
  pkgs,
  ...
}:

let
  profile = pkgs.runCommandLocal "nix-profile" { } ''
    mkdir -p $out

    ln -s ${config.profile.build.path}/* $out
    ln -s ${config.profile.build.files} $out/files
    ln -s ${config.profile.build.setEnvironment} $out/set-environment

    echo '${config.profile.activationScripts.script}' > $out/activate
    substituteInPlace $out/activate --subst-var-by out $out
    chmod u+x $out/activate
  '';
in
{
  options = {
    profile.build.toplevel = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
    };
  };

  config = {
    profile.build.toplevel = profile;
  };
}
