{ callPackage, lib, fetchFromGitLab }:

let
  pname = "{{ dirname }}";
  version = "{{ query(prompt = "Version", default = "0.1.0") }}";

  package = (callPackage ./Cargo.nix {}).rootCrate.build;
in package.overrideAttrs (attrs: {
  name = "${pname}-${version}";

  src = fetchFromGitLab {
    owner = "{{ user }}";
    repo = pname;
    rev = version;

    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  postInstall = ''
    # Remove pointless file which can cause collisions
    rm $out/lib/link
  '';

  meta = with lib; {
    description = "{{ query(prompt = "Description") }}";
    license = licenses.mit;
    maintainers = with maintainers; [ {{ user }} ];
    platforms = platforms.unix;
  };
})
