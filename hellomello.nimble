# Package

version       = "0.1.0"
author        = "Mateusz Czapliński"
description   = "Sample hello-world app for Android with Dali"
license       = "0BSD"
srcDir        = "src"


# Dependencies

requires "nim >= 1.0.2"
requires "dali 0.3.0"
requires "https://github.com/akavel/jnim#dali"


# Tasks

task dex, "Assemble a classes.dex file":
  mkDir("apk")
  exec("nim c -d:jnimGenDex hello.nim")
  exec("nim c -r _gen_dex.nim")

task so, "Compile and link an Android .so library":
  mkDir("apk")
  # http://akehrer.github.io/posts/connecting-nim-to-python/
  # https://forum.nim-lang.org/t/3575
  # https://forum.nim-lang.org/t/2696#16699
  exec("nim c --app:lib --os:android --cpu=arm -d:noSignalHandler --hint[CC]:on --listcmd -o:apk/lib/armeabi-v7a/libhello-mello.so hello.nim")

from os import getHomeDir

task manifest, "Compile AndroidManifest.xml to binary format":
  mkDir("apk")
  # Based on: https://github.com/nim-lang/nimble/tree/v0.11.0#nimbles-folder-structure-and-packages
  # and contents found in actual files in ~/.nimble/bin/
  #let bin = getHomeDir() & ".nimble/bin"
  const hash = "efadb3f340327c36712115acb881cafa1774a47b"
  let marco = getHomeDir() & ".nimble/pkgs/marco-#" & hash & "/marco".toExe
  if not existsFile(marco):
    exec("nimble install https://github.com/akavel/marco@#" & hash)
  # TODO: when failed, print instructions how to install and build https://github.com/akavel/marco
  exec(marco & " -i=AndroidManifest.xml -o=apk/AndroidManifest.xml")

task apk, "Build a signed .apk archive containing files from apk/ directory":
  exec("basia -i=apk/ -o=hello.apk -c=cert.x509.pem -k=key.pk8")

