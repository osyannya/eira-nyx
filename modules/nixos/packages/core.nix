{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bzip2
    coreutils
    diffutils
    findutils
    gnugrep
    gnused
    gnutar
    gzip
    # moreutils
    procps
    pciutils
    shadow
    util-linux
    which
    xz
    zstd
  ];
}
