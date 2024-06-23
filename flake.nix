{
  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
  };

  outputs =
    { nixpkgs-lib, ... }:
    {
      lib = import ./default.nix { inherit (nixpkgs-lib) lib; };
    };
}
