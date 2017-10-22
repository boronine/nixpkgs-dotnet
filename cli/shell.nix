{ pkgs ? (import <nixpkgs> {}) }:

(import ./default.nix) {
  stdenv            = pkgs.stdenv;
  fetchFromGitHub   = pkgs.fetchFromGitHub;
  fetchurl          = pkgs.fetchurl;
  # which             = pkgs.which;
  # cmake             = pkgs.cmake;
  # clang             = pkgs.clang;
  # llvmPackages      = pkgs.llvmPackages;
  libunwind         = pkgs.libunwind;
  # gettext           = pkgs.gettext;
  openssl           = pkgs.openssl;
  # python2           = pkgs.python2;
  icu               = pkgs.icu;
  # lttng-ust         = pkgs.lttng-ust;
  # liburcu           = pkgs.liburcu;
  libuuid           = pkgs.libuuid;
  # libkrb5           = pkgs.libkrb5;
  patchelf          = pkgs.patchelf;
}
