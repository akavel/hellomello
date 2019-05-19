# Package

version       = "0.1.0"
author        = "Mateusz Czapliński"
description   = "Sample hello-world app for Android with Dali"
license       = "0BSD"
srcDir        = "src"


# Dependencies

requires "nim >= 0.19.4"
requires "dali 0.1"


# Tasks

task dex, "Assemble a classes.dex file":
  mkDir("apk")
  exec("nim c -r classes.nim apk/classes.dex")

