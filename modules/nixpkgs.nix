{ lib, config, ... }:

let
  cfg = config.nixpkgs;
in
{
  options = {
    nixpkgs = {
      pkgs = lib.mkOption {
        type = lib.types.pkgs;
        description = ''The pkgs module argument.'';
      };
      config = lib.mkOption {
        internal = true;
        type = with lib.types; unique { message = "nixpkgs.config is set to read-only"; } anything;
        description = ''
          The Nixpkgs `config` that `pkgs` was initialized with.
        '';
      };
      overlays = lib.mkOption {
        internal = true;
        type = with lib.types; unique { message = "nixpkgs.overlays is set to read-only"; } anything;
        description = ''
          The Nixpkgs overlays that `pkgs` was initialized with.
        '';
      };
      hostPlatform = lib.mkOption {
        internal = true;
        readOnly = true;
        description = ''
          The platform of the machine that is running the NixOS configuration.
        '';
      };
      buildPlatform = lib.mkOption {
        internal = true;
        readOnly = true;
        description = ''
          The platform of the machine that built the NixOS configuration.
        '';
      };
    };
  };

  config = {
    _module.args.pkgs =
      # find mistaken definitions
      builtins.seq cfg.config builtins.seq cfg.overlays builtins.seq cfg.hostPlatform builtins.seq
        cfg.buildPlatform
        cfg.pkgs;
    nixpkgs.config = cfg.pkgs.config;
    nixpkgs.overlays = cfg.pkgs.overlays;
    nixpkgs.hostPlatform = cfg.pkgs.stdenv.hostPlatform;
    nixpkgs.buildPlatform = cfg.pkgs.stdenv.buildPlatform;
  };
}
