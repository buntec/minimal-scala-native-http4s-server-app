# A toy web server written in Scala using [http4s](https://http4s.org/)

The point of this project is to demonstrate how [scala-cli](https://scala-cli.virtuslab.org/)
and [nix flakes](https://nixos.wiki/wiki/Flakes) can be leveraged to build and distribute
Scala apps in 4 different ways:
 - as a standalone jar running on the JVM;
 - as a native executable compiled by [Scala Native](https://scala-native.org/en/latest/);
 - as a [GraalVM native image](https://www.graalvm.org/latest/reference-manual/native-image/);
 - as a Node.js app compiled by [Scala.js](https://www.scala-js.org/).

If you have [nix](https://nixos.org/download.html) installed and [flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes):

```shell
nix run github:buntec/minimal-scala-native-http4s-server-app#jvm --refresh

nix run github:buntec/minimal-scala-native-http4s-server-app#native --refresh

nix run github:buntec/minimal-scala-native-http4s-server-app#graal --refresh

nix run github:buntec/minimal-scala-native-http4s-server-app#node --refresh
```

Note that running any of the above will be slow the first time only -
after the initial build everything is cached in your nix store.

If you want the actual binary, simply replace `run` by `build`.

This flake also contains a dev shell suitable for working on the app:
```shell
nix develop github:buntec/minimal-scala-native-http4s-server-app --refresh
```

## Notes
The `--refresh` flag above ensures that you always get the most recent commit.
