{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation {
  name = "terraform-packer-esxi-example-env";
  buildInputs = [
    curl
    git
    gnumake
    libxslt
    patchelf
    unzip
  ];
}
