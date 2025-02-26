{
  lib,
  buildFHSEnv,
  claude-desktop,
}:
let
  pname = claude-desktop.pname;
  version = claude-desktop.version;
  desktopItem = claude-desktop.desktopItem;
in
buildFHSEnv {
  inherit desktopItem pname version;

  runScript = lib.getExe claude-desktop;

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

  extraInstallCommands = ''
    mkdir -p $out/share/icons
    cp -r ${claude-desktop}/share/icons/* $out/share/icons

    mkdir -p $out/share/applications
    install -Dm0644 {${desktopItem},$out}/share/applications/$pname.desktop
  '';

  meta = claude-desktop.meta // {
    description = ''
      Wrapped version of ${pname} which launches in an FHS compatible environment.
      Should allow for Model Context Protocol servers to run.
    '';
  };
}
