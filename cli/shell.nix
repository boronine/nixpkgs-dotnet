{ pkgs ? (import <nixpkgs> {}) }:

(import ./default.nix) {
  stdenv            = pkgs.stdenv;
  fetchFromGitHub   = pkgs.fetchFromGitHub;
  fetchurl          = pkgs.fetchurl;
  libunwind         = pkgs.libunwind;
  openssl           = pkgs.openssl;
  icu               = pkgs.icu;
  libuuid           = pkgs.libuuid;
  zlib              = pkgs.zlib;
  curl              = pkgs.curl;
  patchelf          = pkgs.patchelf;
  mktemp            = pkgs.mktemp;
}
