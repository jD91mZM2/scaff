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

{ pkgs ? import pinnedNixpkgs {} }:

let
  inherit (pkgs) lib rustPlatform;
in rustPlatform.buildRustPackage {
  name = "scaff";
  src = lib.sourceByRegex ./. [
    ''^src(/.*|$)''
    ''^Cargo\.(toml|lock)$''
    ''^build\.rs$''
  ];

  cargoSha256 = "050wwl4z0h8xja6c8sgcxc0zyfbdn9rrkcwkzrvyd43bdkvfn9qz";

  nativeBuildInputs = with pkgs; [ pkgconfig ];
  buildInputs = with pkgs; [ openssl ];
}
