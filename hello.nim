{.experimental: "codeReordering".}
import jnim

jclassDef android.view.View
jclassDef android.os.Bundle

jclass android.app.Activity of JVMObject:
  proc new()
  proc onCreate(b: Bundle)
  proc setContentView(v: View)

jclassDef android.content.Context
jclassDef java.lang.CharSequence

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
    this.n = 44
    let v = TextView.new(this)
    v.setText(this.stringFromField())
    this.setContentView(v)

jnimDexWrite("_gen_dex.nim")

