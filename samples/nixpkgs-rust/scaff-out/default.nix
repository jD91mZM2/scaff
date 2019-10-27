{ callPackage, lib, fetchFromGitLab }:

let
  pname = "{{ project }}";
  version = "{{ query(prompt = "Version", default = "0.1.0") }}";

  package = (callPackage ./Cargo.nix {}).rootCrate.build;
in package.overrideAttrs (attrs: {
  name = "${pname}-${version}";

  src = fetchFromGitLab {
    owner = "{{ name }}";
    repo = pname;
    rev = version;

    sha256 = "0rqlxxl58dpfvm2idhi0vzinraf4bgiapmawiih9wxs599fnhm3y";
  };

  postInstall = ''
    # Remove pointless file which can cause collisions
    rm $out/lib/link
  '';

  meta = with lib; {
    description = "{{ query(prompt = "Description") }}";
    license = licenses.mit;
    maintainers = with maintainers; [ jD91mZM2 ];
    platforms = platforms.unix;
  };
})
