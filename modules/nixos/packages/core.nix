{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bzip2
    coreutils
    diffutils
    findutils
    gnugrep
    gnused
    gnutar
    gptfdisk
    gzip
    # moreutils
    parted
    procps
    pciutils
    shadow
    util-linux
    which
    xz
    zstd
  ];
}
