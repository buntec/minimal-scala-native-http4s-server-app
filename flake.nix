{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, flake-utils, devshell, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system: {

      devShell = let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [ devshell.overlays.default ];
        };
        jdk = pkgs.jdk17_headless;
      in pkgs.devshell.mkShell {
        name = "scala-native-http4s-dev-shell";
        commands = [
          { package = pkgs.metals.override { jre = jdk; }; }
          {
            name = "sc";
            command = ''
              scala-cli "$@" --java-home=$JAVA_HOME
            '';
            help =
              "Wrapper around scala-cli, passing the correct jdk via --java-home";
          }
          { package = pkgs.sbt.override { jre = jdk; }; }
        ];

        packages = [
          jdk
          pkgs.s2n
          pkgs.zlib
          pkgs.s2n-tls
          pkgs.openssl
          pkgs.clang
          pkgs.llvmPackages.libcxxabi
          pkgs.coreutils
          pkgs.scala-cli
        ];
        env = [
          {
            name = "JAVA_HOME";
            value = "${jdk.outPath}";
          }
          {
            name = "LIBRARY_PATH";
            prefix = "$DEVSHELL_DIR/lib:${pkgs.openssl.out}/lib";
          }
          {
            name = "C_INCLUDE_PATH";
            prefix = "$DEVSHELL_DIR/include";
          }
          {
            name = "LLVM_BIN";
            value = "${pkgs.clang}/bin";
          }
        ];
      };

      apps.default = let
        pkgs = import nixpkgs { inherit system; };
        app = pkgs.stdenv.mkDerivation {
          name = "app";
          src = ./src;
          buildPhase = ''
            scala-cli --power package . \
              -o app \
              --java-home "$JAVA_HOME" \
              --native-linking "-static-libstdc++"
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp app $out/bin
          '';

        };
      in {
        type = "app";
        program = "${app}/bin/app";
      };

    });
}
