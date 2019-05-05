# Based on:
# - https://forum.nim-lang.org/t/2696#16699

# TODO: compile with -d:noSignalHandler (https://forum.nim-lang.org/t/2696#16699)

# import jnim
# import dynlib # FIXME: Do I need this?

import jni_wrapper

# Copied from jnim (which requires JVM to compile :/)
# Specifically, from: https://github.com/yglukhov/jnim/blob/ec889fd4f58a8f587b53ee3b726de8189cc59769/src/private/jni_wrapper.nim
# type
#   jobject_base {.inheritable, pure.} = object
#   jobject* = ptr jobject_base
#   jstring* = ptr object of jobject
#   JNIEnv* = ptr JNINativeInterface
#   JNIEnvPtr* = ptr JNIEnv

proc Java_com_akavel_hello2_HelloActivity_stringFromJNI*(env: JNIEnvPtr, thiz: jobject): jstring {.cdecl,exportc,dynlib.} =
  return env.NewStringUTF(env, "Hello from Nim :D")

# jclass com.akavel.hello2.HelloActivity:
#   proc stringFromJNI*(): string
