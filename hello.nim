{.experimental: "codeReordering".}
import jnim

import android/content/context
import android/app/activity
import android/os/bundle
import android/view/view

jclassDef java.lang.CharSequence of JVMObject

jclass android.widget.TextView of View:
  proc new(c: Context)
  proc setText(s: CharSequence)


type
  NimActivity = ref object of Activity
    n: int

jexport NimActivity extends Activity:
  proc new() = super()  # TODO: or else?

  proc stringFromField(): string =
    $this.n

  proc onCreate(b: Bundle) =
    this.super.onCreate(b)
    this.n = 44
    let v = TextView.new(this)
    # v.setText(this.stringFromField())
    v.setText(cast[CharSequence](this.stringFromField()))
    this.setContentView(v)

jnimDexWrite("jnim_gen_dex.nim")

