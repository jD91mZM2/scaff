# scaff ![Crates.io](https://img.shields.io/crates/v/scaff)

Painless scaffolding of the boring part of setting up projects that
people other than you can use.

Scaff can be used to generate licenses, initial READMEs, makefiles,
build derivations, whatever really. All thanks to the awesome
[Tera](https://tera.netlify.com/) templating engine!

## Example use

[![asciicast](https://asciinema.org/a/PtKWiSQynFvVoGs1ozdoiJX99.svg)](https://asciinema.org/a/PtKWiSQynFvVoGs1ozdoiJX99)

## How it works

`scaff` will basically download a tarball, run tera on everything, and
extract out everything from any directory named `scaff-out`. The
reason for not extracting the whole tarball is to support hidden files
that you could potentially include from tera, and also to support
downloading a git repository directly from GitHub/GitLab without
including the root directory or any other non-relevant files like
readmes.

## Getting it

You can get it using cargo, the official rust package manager:

```sh
cargo install scaff
```

You can also use Nix, although the `default.nix` embedded in this
repository is slow to compile. The GitLab CI will continously update a
binary cache you can use with [Cachix](https://jd91mzm2.cachix.org/).

```sh
cachix use jd91mzm2
nix-env -if https://gitlab.com/jD91mZM2/scaff/-/archive/master.tar.gz
```

## Don't bloat down your repositories

It might be easy to think I'm condoning bloat when I literally make a
tool to dumb code into your perhaps already filled code repos. This is
not the case - I do not endorse bloat and I wouldn't recommend using
this tool to extract 100 lines of code or whatever. That's part of the
reason this tool doesn't allow updating any changes in the archives;
it should only be used as a base, not as something that you sync
between repositories.

For config files you intend to reuse and sync, I recommend the
[dhall](https://dhall-lang.org/) configuration language to keep
everything modular. This is not a replacement for dhall, it's merely a
way to dump a base dhall file for modification later.
