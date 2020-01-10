{ pkgs ? import ./pinned.nix {} }:

(pkgs.callPackage ./Cargo.nix {}).rootCrate.build.overrideAttrs (_attrs: {
  postInstall = ''
    # Remove pointless file which can cause collisions
    rm $out/lib/link || true
  '';
})
