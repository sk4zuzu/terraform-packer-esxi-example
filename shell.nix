{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation {
  name = "terraform-packer-esxi-example-env";
  buildInputs = [
    git
    libvirt libxslt
    pkgconfig gnumake
    go gcc
    patchelf
  ];
}
