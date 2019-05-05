@echo off
:: http://akehrer.github.io/posts/connecting-nim-to-python/
:: https://forum.nim-lang.org/t/3575
:: https://forum.nim-lang.org/t/2696#16699
::nim c --app:lib --os:android --cpu=arm64 -d:noSignalHandler --compileOnly --nimcache:./cache hello.nim
::nim cc --app:lib -d:noSignalHandler --compileOnly hello.nim
::nim c --app:lib -d:noSignalHandler --compileOnly --nimcache:./cache hello.nim
::nim cc --app:lib -d:noSignalHandler --compileOnly hello.nim
::nim c --app:lib --os:android --cpu=arm64 -d:noSignalHandler --compileOnly --nimcache:./cache hello.nim
::nim c --app:lib --os:android --cpu=arm64 -d:noSignalHandler --hint[CC]:on hello.nim
nim c --app:lib --os:android --cpu=arm -d:noSignalHandler --hint[CC]:on hello.nim
