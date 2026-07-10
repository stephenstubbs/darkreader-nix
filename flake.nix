{
  description = "Dark Reader browser extension packaged for Nix as an unpacked Chromium MV3 directory (for --load-extension)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        rec {
          darkreader = pkgs.callPackage ./package.nix { };
          default = darkreader;
        }
      );

      overlays.default = final: _: {
        darkreader = final.callPackage ./package.nix { };
      };
    };
}
