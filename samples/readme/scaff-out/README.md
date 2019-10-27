{% set bucket = name | lower -%}
{% set url = "https://gitlab.com/" ~ name ~ "/" ~ project -%}

# {{ project }} ![Crates.io](https://img.shields.io/crates/v/{{ project }})

WRITE SHORT DESCRIPTION HERE

## Getting it

Installing `{{ project }}` is smoothest with the
[Nix](https://nixos.org/nix/) package manager, which will fetch all
the required system dependencies. There's also an optional binary
cache available using [Cachix](https://{{ bucket }}.cachix.org/).

```sh
cachix use {{ bucket }} # optional
nix-env -if {{ url }}/-/archive/master.tar.gz
```

Alternatively, you can use the official rust package manager,
cargo. However, that will require you to fetch all system dependencies
yourself.

```sh
cargo install {{ project }}
```

List of features and system dependencies. This may sometimes be out of
date, feel free to send a PR to update it.

| Feature flag | Description | Dependencies     |
|--------------|-------------|------------------|
| Default      |             | All of the below |
| No features  |             | `openssl`        |
