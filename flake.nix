{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, flake-utils, devshell, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [ devshell.overlays.default ];
        };

        jdk = pkgs.jdk17_headless;
        sbt = pkgs.sbt.override { jre = jdk; };
        metals = pkgs.metals.override { jre = jdk; };

        packages = [
          jdk
          sbt
          metals
          pkgs.s2n
          pkgs.zlib
          pkgs.s2n-tls
          pkgs.openssl
          pkgs.clang
          pkgs.llvmPackages.libcxxabi
          pkgs.coreutils
          pkgs.scala-cli
          pkgs.which
        ];

      in {

        devShell = pkgs.devshell.mkShell {
          name = "scala-native-http4s-dev-shell";
          commands = [
            {
              name = "sc";
              command = ''
                scala-cli "$@" --java-home=$JAVA_HOME
              '';
              help =
                "Wrapper around scala-cli, passing the correct jdk via --java-home";
            }
            { package = sbt; }
          ];

          packages = packages;

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
          # fixed-output derivation: to nix'ify scala-cli,
          # we must hash the coursier caches created during the build
          app = let
            coursier-cache = pkgs.stdenv.mkDerivation {
              name = "coursier-cache";
              src = ./src;

              buildInputs = packages;

              SCALA_CLI_HOME = "./scala-cli-home";
              COURSIER_CACHE = "./coursier-cache/v1";
              COURSIER_ARCHIVE_CACHE = "./coursier-cache/arc";
              COURSIER_JVM_CACHE = "./coursier-cache/jvm";

              # run the same build as our main derivation
              # to populate the cache with the correct set of dependencies
              buildPhase = ''
                mkdir scala-cli-home
                mkdir -p coursier-cache/v1
                mkdir -p coursier-cache/arc
                mkdir -p coursier-cache/jvm
                scala-cli compile . --java-home=${jdk} --server=false
              '';

              installPhase = ''
                mkdir -p $out/coursier-cache
                cp -R ./coursier-cache $out
              '';

              outputHashAlgo = "sha256";
              outputHashMode = "recursive";
              outputHash =
                "sha256-LSlYKxsF9RrQrcRh/CgBGATYxEVEMa6j+th5NjxYvww=";
            };

          in pkgs.stdenv.mkDerivation {
            name = "app";

            src = ./src;

            buildInputs = packages ++ [ coursier-cache ];

            JAVA_HOME = "${jdk.outPath}";
            SCALA_CLI_HOME = "./scala-cli-home";
            COURSIER_CACHE = "${coursier-cache}/coursier-cache/v1";
            COURSIER_ARCHIVE_CACHE = "${coursier-cache}/coursier-cache/arc";
            COURSIER_JVM_CACHE = "${coursier-cache}/coursier-cache/jvm";

            buildPhase = ''
              mkdir scala-cli-home
              scala-cli --power package . -o app --java-home=${jdk} --server=false
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
