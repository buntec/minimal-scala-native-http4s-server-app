A toy web server written in Scala using [http4s](https://http4s.org/)
and compiled using [Scala Native](https://scala-native.org/en/latest/) - no JVM :rocket:.

The build is handled entirely by [scala-cli](https://scala-cli.virtuslab.org/) - no sbt :sunglasses:.

The app is distributed using [nix flakes](https://nixos.wiki/wiki/Flakes) - no brew, apt, appimage, ... :snowflake:.

If you have [nix](https://nixos.org/download.html) installed and [flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes):

```shell
nix run github:buntec/minimal-scala-native-http4s-server-app
```

If you want the actual binary:
```shell
nix build github:buntec/minimal-scala-native-http4s-server-app
./result/bin/app
```

For a reproducible dev environment, clone this repo and do

```shell
nix develop
```
