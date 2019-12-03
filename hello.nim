{.experimental: "codeReordering".}
import jnim

jclassDef android.view.View of JVMObject
jclassDef android.os.Bundle of JVMObject

jclass android.app.Activity of JVMObject:
  proc new()
  proc onCreate(b: Bundle)
  proc setContentView(v: View)

jclassDef android.content.Context of JVMObject
jclassDef java.lang.CharSequence of JVMObject

jclass android.widget.TextView of JVMObject:
  proc new(c: Context)
  proc setText(s: CharSequence)


type
  NimActivity = ref object of JVMObject
    n: int

jexport NimActivity implements Activity:
  proc new() = super()  # TODO: or else?

  proc stringFromField(): string =
    $this.n

  proc onCreate(b: Bundle) =
    this.super.onCreate(b)
    # cast[Activity](this.super).onCreate(b)  #  Error: expression cannot be cast to Activity=ref Activity:ObjectType
    this.n = 44
    let v = TextView.new(this)
    v.setText(this.stringFromField())
    this.setContentView(v)

jnimDexWrite("_gen_dex.nim")

