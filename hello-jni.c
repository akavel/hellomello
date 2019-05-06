/*
 Tried to compile with:

c:> \android-ndk-r19c\toolchains\llvm\prebuilt\windows-x86_64\bin\armv7a-linux-androideabi16-clang -fPIC -c hello-jni.c
c:> \android-ndk-r19c\toolchains\llvm\prebuilt\windows-x86_64\bin\armv7a-linux-androideabi16-clang -shared hello-jni.o -o hello-jni.so

 based on: https://github.com/skanti/Android-Manual-Build-Command-Line/blob/3fea20b3b52ac04cb0208a691529a89cfb2064c1/hello-jni/Makefile
 However, apparently you can't run such a binary on a non-rooted phone.

https://github.com/googlesamples/android-ndk/blob/86ceeb248bb20bfffb09330d1a95bcf3e91bb99d/hello-jni/app/src/main/cpp/hello-jni.c
*/

#include <string.h>
#include <jni.h>

JNIEXPORT jstring JNICALL
Java_com_akavel_hello2_HelloActivity_stringFromJNI( JNIEnv* env, jobject thiz )
{
	return (*env)->NewStringUTF(env, "Hello from JNI..!");
}
