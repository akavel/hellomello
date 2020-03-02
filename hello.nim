{.experimental: "codeReordering".}
import jnim

import jnim/java/lang

import android/content/context
import android/app/activity
import android/os/bundle
import android/view/view
import android/util/log

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
    discard Log.d("hellomello", "after onCreate prologue - START")
    this.super.onCreate(b)
    discard Log.d("hellomello", "after super.onCreate")
    this.n = 44
    discard Log.d("hellomello", "after this.n=44")
    let v = TextView.new(this)
    discard Log.d("hellomello", "after TextView.new(this)")
    # NOTE: above is the last Log.d line reached before String.new was added

    let s = String.new("barfoo")
    discard Log.d("hellomello", "after String.new('barfoo')")

    # # v.setText(this.stringFromField())
    # v.setText(cast[CharSequence](this.stringFromField()))
    #v.setText(cast[CharSequence]("foobar"))
    v.setText(cast[CharSequence](s))
    discard Log.d("hellomello", "after TextView.setText(...)")
    this.setContentView(v)
    discard Log.d("hellomello", "after this.setContentView(TextView) - END")

jnimDexWrite("jnim_gen_dex.nim")


