when defined(windows):
  switch("arm.android.clang.path", r"c:\android-ndk-r19c\toolchains\llvm\prebuilt\windows-x86_64\bin\")
  switch("arm.android.clang.exe", "armv7a-linux-androideabi16-clang.cmd")
  switch("arm.android.clang.linkerexe", "armv7a-linux-androideabi16-clang.cmd")
else:
  switch("arm.android.clang.path", "/home/akavel/dnload/dalvik-etc/android-ndk-r21/toolchains/llvm/prebuilt/linux-x86_64/bin/")
  switch("arm.android.clang.exe", "armv7a-linux-androideabi16-clang")
  switch("arm.android.clang.linkerexe", "armv7a-linux-androideabi16-clang")

