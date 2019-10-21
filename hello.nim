# Resources:
# - System.loadLibrary - hello-jni in Android samples, and also:
#   https://github.com/skanti/Android-Manual-Build-Command-Line/blob/3fea20b3b52ac04cb0208a691529a89cfb2064c1/hello-jni/src/com/example/hellojni/HelloJNI.java#L25
# - <clinit> - http://mariokmk.github.io/programming/2015/03/06/learning-android-bytecode.html

{.experimental: "codeReordering".}
import dali


when not defined android:
  const
    Activity = "Landroid/app/Activity;"
    Bundle = "Landroid/os/Bundle;"
    TextView = "Landroid/widget/TextView;"
    System = "Ljava/lang/System;"
    String = "Ljava/lang/String;"
    Context = "Landroid/content/Context;"
    CharSequence = "Ljava/lang/CharSequence;"
    View = "Landroid/view/View;"
    Long = "Ljava/lang/Long;"
    NimObject = "Lcom/akavel/hello2/Jnim$__NimObject;"
    Jnim = "Lcom/akavel/hello2/Jnim;"
    HelloActivity = "Lcom/akavel/hello2/Jnim$HelloActivity;"
    Throws = "Ldalvik/annotation/Throws;"
  let
    HelloActivity_self = Field(class:HelloActivity, typ:"J", name:"_1")

  let d = newDex()
  d.classes.add ClassDef(
    class: Jnim, access: {Public}, superclass: NoType(),
    class_data: ClassData(
      direct_methods: @[
        EncodedMethod(m: jproto Jnim.`_ 0`(jlong), access: {Public, Static, Native}, code: NoCode())]))
  d.classes.add ClassDef(
    class: NimObject, access: {Public, Interface}, superclass: NoType())
  d.classes.add ClassDef(
    class: HelloActivity, access: {Public, Static}, superclass: SomeType(Activity), interfaces: @[NimObject],
    class_data: ClassData(
      instance_fields: @[
        EncodedField(access: {Private}, f: HelloActivity_self),
        ],
      direct_methods: @[
        EncodedMethod(m: jproto HelloActivity.`<clinit>`(), access: {Static, Constructor}, code: SomeCode(Code(
          registers: 2, ins: 0, outs: 1, instrs: @[
            # System.loadLibrary("hello-mello")
            const_string(0, "hello-mello"),
            invoke_static(0, jproto System.loadLibrary(String)),
            return_void(),
          ]))),
        EncodedMethod(m: jproto HelloActivity.`<init>`(jlong), access: {Protected, Constructor}, code: SomeCode(Code(
          registers: 3, ins: 3, outs: 0, instrs: @[
            # ins: this, arg0/1
            # this.nimSelf = arg01
            iput_wide(1, 0, HelloActivity_self),
            return_void(),
          ]))),
        EncodedMethod(m: jproto HelloActivity.`<init>`(), access: {Public, Constructor}, code: SomeCode(Code(
          registers: 1, ins: 1, outs: 1, instrs: @[
            invoke_direct(0, jproto Activity.`<init>`()),
            return_void(),
          ]))),
        ],
      virtual_methods: @[
        EncodedMethod(m: jproto HelloActivity.finalize(), access: {Protected},
          annotations: @[
            Annotation(VisSystem, EncodedAnnotation(typ: Throws, elems: @[
              AnnotationElement(name: "value", value: EVArray(arrayElems: @[
                EVType(typ: Throwable),
              ]))
            ]))],
          code: SomeCode(Code(
            registers: 3, ins: 1, outs: 2, instrs: @[
              # ins: this
              # super.finalize()
              invoke_super(2, jproto Activity.finalize()),
              # this._0(nimSelf)
              iget_wide(2, 0, HelloActivity_self),
              invoke_static(0, jproto Jnim.`_ 0`(jlong)),
              # this.nimSelf = 0
              const_wide_16(0, 0'i16),
              iput_wide(2, 0, HelloActivity_self),
              return_void(),
          ]))),
        EncodedMethod(m: jproto HelloActivity.onCreate(Bundle), access: {Public}, code: SomeCode(Code(
          registers: 4, ins: 2, outs: 2, instrs: @[
            # ins: this, arg0
            # super.onCreate(arg0)
            invoke_super(2, 3, jproto Activity.onCreate(Bundle)),
            # v0 = new TextView(this)
            new_instance(0, TextView),
            invoke_direct(0, 2, jproto TextView.`<init>`(Context)),
            # v1 = this.stringFromField()
            #  NOTE: failure to call a Native function should result in
            #  java.lang.UnsatisfiedLinkError exception
            invoke_virtual(2, jproto HelloActivity.stringFromField() -> String),
            move_result_object(1),
            # v0.setText(v1)
            invoke_virtual(0, 1, jproto TextView.setText(CharSequence)),
            # this.setContentView(v0)
            invoke_virtual(2, 0, jproto HelloActivity.setContentView(View)),
            # return
            return_void(),
          ]))),
        EncodedMethod(m: jproto HelloActivity.stringFromField() -> jstring, access: {Private}, code: SomeCode(Code(
          registers: 4, ins: 1, outs: 3, instrs: @[
            # this.nimSelf = (long)43
            const_wide_16(0, 43'i16),
            iput_wide(0, 3, HelloActivity_self),
            # v0 = this.stringFromJNI()
            #  NOTE: failure to call a Native function should result in
            #  java.lang.UnsatisfiedLinkError exception
            invoke_virtual(3, jproto HelloActivity.stringFromJNI() -> jstring),
            move_result_object(0),
            # return v0
            return_object(0),
          ]))),
        EncodedMethod(m: jproto HelloActivity.stringFromJNI() -> jstring, access: {Public, Native}, code: NoCode()),
      ]))
  stdout.write(d.render)


when defined android:
  import jnim

  proc Java_com_akavel_hello2_Jnim_00024HelloActivity_stringFromJNI*(jenv: JNIEnvPtr;
      jthis: jobject): jstring {.cdecl, exportc, dynlib.} =
    let helloClass = jenv.FindClass(jenv, "com/akavel/hello2/Jnim$HelloActivity")
    let nimSelfField = jenv.GetFieldId(jenv, helloClass, "_1", "J")
    let longVal = jenv.GetLongField(jenv, jthis, nimSelfField)
    let longClass = jenv.FindClass(jenv, "java/lang/Long")
    let toStringMethod = jenv.GetStaticMethodID(jenv, longClass, "toString", "(J)Ljava/lang/String;")
    let stringVal = jenv.CallStaticObjectMethod(jenv, longClass, toStringMethod, longVal)
    return cast[jstring](stringVal)

