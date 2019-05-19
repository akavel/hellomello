# Resources:
# - System.loadLibrary - hello-jni in Android samples, and also:
#   https://github.com/skanti/Android-Manual-Build-Command-Line/blob/3fea20b3b52ac04cb0208a691529a89cfb2064c1/hello-jni/src/com/example/hellojni/HelloJNI.java#L25
# - <clinit> - http://mariokmk.github.io/programming/2015/03/06/learning-android-bytecode.html

{.experimental: "codeReordering".}
import dali
import os

const
  Activity = "Landroid/app/Activity;"
  HelloActivity = "Lcom/akavel/hello2/HelloActivity;"
  Bundle = "Landroid/os/Bundle;"
  TextView = "Landroid/widget/TextView;"
  System = "Ljava/lang/System;"

var dex = newDex()
dex.classes.add(ClassDef(
  class: HelloActivity,
  access: {Public},
  superclass: SomeType(Activity),
  class_data: ClassData(
    direct_methods: @[
      EncodedMethod(
        # void ...HelloActivity.<clinit>()
        m: Method(
          class: HelloActivity,
          name: "<clinit>",
          prototype: Prototype(ret: "V", params: @[]),
        ),
        access: {Static, Constructor},
        code: SomeCode(Code(
          registers: 2,
          ins: 0,
          outs: 1,
          instrs: @[
            # v0 = "hello-mello"
            const_string(0, "hello-mello"),
            # System.loadLibrary(v0)
            invoke_static(0, Method(class: System, name: "loadLibrary",
              prototype: Prototype(ret: "V", params: @["Ljava/lang/String;"]))),
            # return
            return_void(),
          ],
        )),
      ),
      EncodedMethod(
        # void ...HelloActivity.<init>()
        m: Method(
          class: HelloActivity,
          name: "<init>",
          prototype: Prototype(ret: "V", params: @[]),
        ),
        access: {Public, Constructor},
        code: SomeCode(Code(
          registers: 1,
          ins: 1,
          outs: 1,
          instrs: @[
            # super.<init>()
            invoke_direct(0, Method(class: Activity, name: "<init>",
              prototype: Prototype(ret: "V", params: @[]))),
            # return
            return_void(),
          ],
        )),
      ),
    ],
    virtual_methods: @[
      EncodedMethod(
        # void ...HelloActivity.onCreate(Bundle)
        m: Method(
          class: HelloActivity,
          name: "onCreate",
          prototype: Prototype(ret: "V", params: @[Bundle])),
        access: {Public},
        code: SomeCode(Code(
          registers: 4,
          ins: 2,   # this, arg0
          outs: 2,  # TODO(akavel): what does this really mean???
          instrs: @[
            # super.onCreate(arg0)
            invoke_super(2, 3, Method(class: Activity, name: "onCreate",
              prototype: Prototype(ret: "V", params: @[Bundle]))),
            # v0 = new TextView(this)
            new_instance(0, TextView),
            invoke_direct(0, 2, Method(class: TextView, name: "<init>",
              prototype: Prototype(ret: "V", params: @["Landroid/content/Context;"]))),
            # v1 = this.stringFromJNI()
            #  NOTE: failure to call a Native function should result in
            #  java.lang.UnsatisfiedLinkError exception
            invoke_virtual(2, Method(class: HelloActivity, name: "stringFromJNI",
              prototype: Prototype(ret: "Ljava/lang/String;", params: @[]))),
            move_result_object(1),
            # v0.setText(v1)
            invoke_virtual(0, 1, Method(class: TextView, name: "setText",
              prototype: Prototype(ret: "V", params: @["Ljava/lang/CharSequence;"]))),
            # this.setContentView(v0)
            invoke_virtual(2, 0, Method(class: HelloActivity, name: "setContentView",
              prototype: Prototype(ret: "V", params: @["Landroid/view/View;"]))),
            # return
            return_void(),
          ],
        )),
      ),
      EncodedMethod(
        m: Method(
          class: HelloActivity,
          name: "stringFromJNI",
          prototype: Prototype(ret: "Ljava/lang/String;", params: @[])),
        access: {Public, Native},
        code: NoCode(),
      ),
    ]
  )
))

if paramCount() > 0:
  writeFile(paramStr(1), dex.render)
else:
  write(stdout, dex.render)

