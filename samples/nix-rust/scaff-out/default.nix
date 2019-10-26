{ pkgsFn ? import <nixpkgs> }:

let
  mozOverlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  crateOverlay = self: super: {
    defaultCrateOverrides = super.defaultCrateOverrides // {
      {{ project }} = attrs: {
        buildInputs = attrs.buildInputs ++ (with self; [ /* openssl */ ]);
      };
    };
  };
  pkgs = pkgsFn { overlays = [ mozOverlay crateOverlay ]; };
  buildRustCrate = pkgs.buildRustCrate.override {
    rustc = pkgs.latest.rustChannels.stable.rust;
  };
in
  (pkgs.callPackage ./Cargo.nix { inherit buildRustCrate; }).rootCrate.build.override {
    # features = [];
  }
