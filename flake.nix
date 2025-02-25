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
        claude-desktop-fhs =
          let
            name = "claude-desktop";
          in
          final.buildFHSEnv {
            inherit name;
            pname = name;
            version = final.claude-desktop.version;
            targetPkgs =
              pkgs:
              builtins.attrValues {
                inherit (pkgs)
                  docker
                  glibc
                  openssl
                  nodejs
                  uv
                  ;
              };
            runScript = final.lib.getExe final.claude-desktop;
            meta = final.claude-desktop.meta // {
              description = ''
                Wrapped version of ${name} which launches in an FHS compatible environment.
                Should allow for Model Context Protocol servers to run.
              '';
            };
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
          inherit (pkgs) patchy-cnb claude-desktop claude-desktop-fhs;
          default = pkgs.claude-desktop;
          unlicensed = pkgs.claude-desktop.overrideAttrs (
            final: prev: {
              meta = removeAttrs prev.meta [ "license" ];
            }
          );
          unlicensed-fhs = pkgs.claude-desktop-fhs.overrideAttrs (
            final: prev: {
              meta = removeAttrs prev.meta [ "license" ];
            }
          );
        }
      );

      overlays.default = overlay;
    };
}
