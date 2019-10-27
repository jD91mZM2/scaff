# Used by default.nix in case no nixpkgs is specified. Pinning is
# useful to ensure cachix binary cache gets used.

{% set date = now() | date(format="%Y-%m-%d") -%}
{% set release = "19.09" -%}

import (builtins.fetchGit {
  name = "nixos-{{ release }}-{{ date }}";
  url = https://github.com/nixos/nixpkgs/;
  # Commit hash for nixos-unstable as of {{ date }}
  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-{{ release }}`
  ref = "refs/heads/nixos-{{ release }}";
  rev = "0000000000000000000000000000000000000000";
})
