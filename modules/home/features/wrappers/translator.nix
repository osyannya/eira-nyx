{ config, lib, pkgs, inputs, ... }:

let
  scriptsDir = "${inputs.self}/modules/nixos/programs/scripts";

  scriptNames = [
    "connect-wifi"
    "disconnect-wifi"
    "temporary-wifi"
    "wallpaper"
  ];

  wrappedScripts =
    map (name:
      pkgs.writeShellScriptBin name ''
        exec ${pkgs.bash}/bin/bash ${scriptsDir}/${name}.sh "$@"
      ''
    ) scriptNames;

in {
  home.packages = wrappedScripts;
}
