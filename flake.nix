{
  description = "A toy web server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.my-nix-utils.url = "github:buntec/nix-utils";

  outputs = { self, nixpkgs, my-nix-utils, ... }:

    let
      inherit (nixpkgs.lib) genAttrs;

      eachSystem = genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      version = if (self ? rev) then self.rev else "dirty";

    in {

      packages = eachSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ ];
          };

          buildScalaApp = pkgs.callPackage my-nix-utils.lib.mkBuildScalaApp { };

        in buildScalaApp {
          inherit version;
          src = ./src;
          pname = "app";
          scala-native-version = "0.4.15";
          sha256 = "sha256-thlYA5MOmMVzvGa7CWzgIU01vfZtpHM5RiYBndrq/fk=";
        }

      );

      apps = eachSystem (system:
        builtins.mapAttrs (name: value: {
          type = "app";
          program = "${value}/bin/app";
        }) self.packages.${system});

      checks = self.packages;

    };
}
