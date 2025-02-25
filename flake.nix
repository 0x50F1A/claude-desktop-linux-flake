{
  description = "Claude Desktop for Linux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = function: nixpkgs.lib.genAttrs supportedSystems (system: function system);

      overlay = final: prev: {
        patchy-cnb = final.callPackage ./pkgs/patchy-cnb.nix { };
        claude-desktop = final.callPackage ./pkgs/claude-desktop.nix {
          patchy-cnb = final.patchy-cnb;
        };
      };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
        in
        {
          inherit (pkgs) patchy-cnb claude-desktop;
          default = pkgs.claude-desktop;
          unlicensed = pkgs.claude-desktop.overrideAttrs (
            final: prev: {
              meta = removeAttrs prev.meta [ "license" ];
            }
          );
        }
      );

      overlays.default = overlay;
    };
}
