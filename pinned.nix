# Used by default.nix in case no nixpkgs is specified. Pinning is
# useful to ensure cachix binary cache gets used.

import (builtins.fetchGit {
  name = "nixos-19.09-2019-12-03";
  url = https://github.com/nixos/nixpkgs/;
  # Commit hash for nixos-unstable as of 2019-12-03
  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-19.09`
  ref = "refs/heads/nixos-19.09";
  rev = "72a2ced252348defc877bea0a8b551272c0be3f9";
})
