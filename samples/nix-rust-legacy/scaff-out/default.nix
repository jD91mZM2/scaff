{% set date = now() | date(format="%Y-%m-%d") -%}
{% set release = "19.09" -%}
let
  pinnedNixpkgs = builtins.fetchGit {
    name = "nixos-{{ release }}-{{ date }}";
    url = https://github.com/nixos/nixpkgs/;
    # Commit hash for nixos-unstable as of {{ date }}
    # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-{{ release }}`
    ref = "refs/heads/nixos-{{ release }}";
    rev = "0000000000000000000000000000000000000000";
  };
in

{ pkgsFn ? import pinnedNixpkgs }:

let
  mozOverlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  pkgs = pkgsFn { overlays = [ mozOverlay ]; };
  rustPlatform = let
    rust = pkgs.latest.rustChannels.stable.rust;
  in pkgs.makeRustPlatform {
    cargo = rust;
    rustc = rust;
  };

  inherit (pkgs) lib;
in rustPlatform.buildRustPackage {
  name = "{{ dirname }}";
  src = lib.sourceByRegex ./. [
    ''^src(/.*|$)''
    ''^Cargo\.(toml|lock)$''
    ''^build\.rs$''
  ];

  cargoSha256 = "0000000000000000000000000000000000000000000000000000000000000000";

  nativeBuildInputs = with pkgs; [ /* pkgconfig */ ];
  buildInputs = with pkgs; [ /* openssl */ ];
}
