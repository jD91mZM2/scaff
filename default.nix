let
  pinnedNixpkgs = builtins.fetchGit {
    name = "nixos-19.09-2019-10-27";
    url = https://github.com/nixos/nixpkgs/;
    # Commit hash for nixos-unstable as of 2019-10-27
    # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-19.09`
    ref = "refs/heads/nixos-19.09";
    rev = "27a5ddcf747fb2bb81ea9c63f63f2eb3eec7a2ec";
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
  name = "scaff";
  src = lib.sourceByRegex ./. [
    ''^src(/.*|$)''
    ''^Cargo\.(toml|lock)$''
    ''^build\.rs$''
  ];

  cargoSha256 = "0bpmfw4gd32xdca5hvwvkirjrkb2kkjvlqssw43y2bckld3wrk3y";

  nativeBuildInputs = with pkgs; [ pkgconfig ];
  buildInputs = with pkgs; [ openssl ];
}
