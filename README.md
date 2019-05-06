HelloWorld.apk built with Nim and no Android Studio
===================================================

To build the project, you will currently need the following prerequisites:

 - [Nim compiler](https://nim-lang.org/install.html)
 - [Go compiler](https://golang.org/dl/) (TODO: remove this dependency —
   at least provide prebuilt binaries of *apksigner*)
 - [Android NDK][ndk] (the elephant in the room...)
    - *standalone* toolchain — just
      [download][ndk] and unpack
      somewhere, no installation required afterwards (still, ~2.5GB unpacked)
 - ...and: NO Java, NO JRE, NO Android Studio, NO Android SDK! 🎉

[ndk]: https://developer.android.com/ndk/downloads

Build Steps
-----------

1. Compile the native JNI code, using Nim + Android NDK:

       $ git clone https://github.com/akavel/hellomello
         # Edit `nim.cfg`: change `--clang.path=...` to a correct path to clang in your Android NDK directory.
         # Also: remove `.cmd` suffixes in `nim.cfg` if you are on Linux.
       $ nim c --app:lib --os:android --cpu=arm -d:noSignalHandler --hint[CC]:on hello.nim
       $ mkdir lib
       $ mkdir lib/armeabi-v7a
       $ mv libhello.so lib/armeabi-v7a/libhello-mello.so

2. Assemble the Dalvik bytecode (required to wrap the JNI library), using dali:

       $ git clone https://github.com/akavel/dali
       $ cd dali
       $ nim c jni_hello.nim
       $ ./jni_hello > ../hellomello/classes.dex
       $ cd ..

3. Compile the manifest file to binary format, using marco:

       $ git clone https://github.com/akavel/marco
       $ cd marco
       $ nimble build
       $ cd ../hellomello
       $ ../marco/marco < AndroidManifest0.xml > AndroidManifest.xml

4. Build an unsigned .apk, using OS-provided zip archiver:

       $ zip -r unsigned.apk  classes.dex lib/ AndroidManifest.xml

5. Sign the .apk, using apksigner tool written in Go:

       $ git clone https://github.com/akavel/apksigner
       $ cd apksigner
       $ go build
       $ cd ../hellomello
       $ ../apksigner/apksigner -i unsigned.apk -o hello.apk -k key.pk8 -c key.x509.pem

6. ...aaand you should have a `hello.apk` file now, **ready to be installed**
   on an ARM-based Android device. Worked For Me&trade;... In case of problems
   installing or opening the apk on your device, try running `adb logcat` (yep,
   that requires Android Studio... or you could try
   [python-adb](https://github.com/google/python-adb)).  I suggest searching for
   "InstallInstall" and "InstallFail" messages, verifier/verification messages,
   and Java-like exception stack traces.  You're welcome to post your problems as
   issues on this repository, but I can't promise I will be able to help you in
   any way. We can treat them as "observations" or "reports". Maybe someone else
   will come by and suggest some steps for future experimenters.

*[/Mateusz Czapliński.](http://akavel.com)*  
*2019-05-06*

