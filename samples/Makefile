.PHONY: all clean

all: nix-bare.tar.gz nix-rust.tar.gz nix-rust-legacy.tar.gz license-mit.tar.gz rustfmt.tar.gz group-rust.tar.gz
clean:
	rm nix-bare.tar.gz || true
	rm nix-rust.tar.gz || true
	rm nix-rust-legacy.tar.gz || true
	rm license-mit.tar.gz || true
	rm rustfmt.tar.gz || true
	rm group-rust.tar.gz || true

source = $(shell find $(1) -type f)
build  = tar -czf $(1) $(2)

# Nix stuff
nix-bare.tar.gz: $(call source, nix-bare); $(call build, $@, $^)
nix-rust.tar.gz: $(call source, nix-rust); $(call build, $@, $^)
nix-rust-legacy.tar.gz: $(call source, nix-rust-legacy); $(call build, $@, $^)

# Licenses
license-mit.tar.gz: $(call source, license-mit); $(call build, $@, $^)

# Rust tooling
rustfmt.tar.gz: $(call source, rustfmt); $(call build, $@, $^)

# Groups
group-rust.tar.gz: $(call source, nix-bare license-mit rustfmt); $(call build, $@, $^)
