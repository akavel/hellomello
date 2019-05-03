/*
 Tried to compile with:

c:> \android-ndk-r19c\toolchains\llvm\prebuilt\windows-x86_64\bin\armv7a-linux-androideabi16-clang -pie hello-jni.c

 based on: http://nickdesaulniers.github.io/blog/2016/07/01/android-cli/
 However, apparently you can't run such a binary on a non-rooted phone.

*/
#include <stdio.h>
int main() {
	puts("Hello mello\n");
}
