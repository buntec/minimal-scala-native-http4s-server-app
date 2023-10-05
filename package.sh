#!/usr/bin/env bash

scala-cli --power package . \
  -o app \
  --java-home "$JAVA_HOME"
