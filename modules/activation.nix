{ lib, pkgs, ... }:

let
  path =
    with pkgs;
    map lib.getBin [
      coreutils
      findutils
      gnugrep
    ];

  addAttributeName = lib.mapAttrs (
    n: v:
    v
    // {
      text = ''
        #### Activation script snippet ${n}:
        _localstatus=0
        ${v.text}

        if (( _localstatus > 0 )); then
          printf "Activation script snippet '%s' failed (%s)\n" "${n}" "$_localstatus"
        fi
      '';
    }
  );
in
{
  options = {
    profile = {
      activationScripts = lib.mkOption {
        type =
          with lib.types;
          attrsOf (
            either str (submodule {
              options = {
                deps = lib.mkOption {
                  type = listOf str;
                  default = [ ];
                };
                text = lib.mkOption { type = lines; };
              };
            })
          );
        default = { };
        apply = set: {
          script = ''
            #!${pkgs.runtimeShell}

            profile_config='@out@'

            PATH="${lib.makeBinPath path}"

            _status=0
            trap "_status=1 _localstatus=\$?" ERR

            ${
              let
                set' = lib.mapAttrs (n: v: if lib.isString v then lib.noDepEntry v else v) set;
                withHeadlines = addAttributeName set';
              in
              lib.textClosureMap lib.id (withHeadlines) (lib.attrNames withHeadlines)
            }

            exit $_status
          '';
        };
      };
    };
  };
}
