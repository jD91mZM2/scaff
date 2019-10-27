# scaff

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
