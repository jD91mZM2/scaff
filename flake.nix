{
  description = "Painless scaffolding of the boring part of setting up projects";

  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "i686-linux" "aarch64-linux" ];
  in {
    # Packages
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages."${system}";
    in {
      scaff = (pkgs.callPackage ./Cargo.nix {}).rootCrate.build;
    });
    defaultPackage = forAllSystems (system: self.packages."${system}".scaff);

    devShell = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages."${system}";
    in pkgs.mkShell {
      # Things to be put in $PATH
      nativeBuildInputs = with pkgs; [ pkgconfig ];
      # Libraries to be installed
      buildInputs = with pkgs; [ openssl ];
    });

    # Make it runnable with `nix app`
    apps = forAllSystems (system: {
      scaff = {
        type    = "app";
        program = "${self.packages."${system}".scaff}/bin/scaff";
      };
    });
    defaultApp = forAllSystems (system: self.apps."${system}".scaff);
  };
}
