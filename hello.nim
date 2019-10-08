# Resources:
# - System.loadLibrary - hello-jni in Android samples, and also:
#   https://github.com/skanti/Android-Manual-Build-Command-Line/blob/3fea20b3b52ac04cb0208a691529a89cfb2064c1/hello-jni/src/com/example/hellojni/HelloJNI.java#L25
# - <clinit> - http://mariokmk.github.io/programming/2015/03/06/learning-android-bytecode.html

{.experimental: "codeReordering".}
import dali

when defined android:
  import jnim

const
  Activity = "Landroid/app/Activity;"
  HelloActivity = "Lcom/akavel/hello2/HelloActivity;"
  Bundle = "Landroid/os/Bundle;"
  TextView = "Landroid/widget/TextView;"
  System = "Ljava/lang/System;"
  String = "Ljava/lang/String;"
  Context = "Landroid/content/Context;"
  CharSequence = "Ljava/lang/CharSequence;"
  View = "Landroid/view/View;"

classes_dex:
  dclass com.akavel.hello2.HelloActivity {.public.} of Activity:
    proc `<clinit>`() {.static, constructor, regs:2, ins:0, outs:1.} =
      # v0 = "hello-mello"
      const_string(0, "hello-mello")
      # System.loadLibrary(v0)
      invoke_static(0, jproto System.loadLibrary(String))
      # return
      return_void()
    proc `<init>`() {.public, constructor, regs:1, ins:1, outs:1.} =
      # super.<init>()
      invoke_direct(0, jproto Activity.`<init>`())
      # return
      return_void()
    proc onCreate(Bundle) {.public, regs:4, ins:2, outs:2.} =
      # super.onCreate(arg0)
      invoke_super(2, 3, jproto Activity.onCreate(Bundle))
      # v0 = new TextView(this)
      new_instance(0, TextView)
      invoke_direct(0, 2, jproto TextView.`<init>`(Context))
      # v1 = this.stringFromJNI()
      #  NOTE: failure to call a Native function should result in
      #  java.lang.UnsatisfiedLinkError exception
      invoke_virtual(2, jproto HelloActivity.stringFromJNI() -> String)
      move_result_object(1)
      # v0.setText(v1)
      invoke_virtual(0, 1, jproto TextView.setText(CharSequence))
      # this.setContentView(v0)
      invoke_virtual(2, 0, jproto HelloActivity.setContentView(View))
      # return
      return_void()
    proc stringFromJNI(): jstring {.public, native.} =
      return jenv.NewStringUTF(jenv, "Hello from Nim classes_dex :D")

