{.experimental: "codeReordering".}
import jnim

import jnim/java/lang

import android/content/context
import android/app/activity
import android/os/bundle
import android/view/view
import android/util/log

jclass android.graphics.Paint of JVMObject:
  proc new()
  proc setColor(c: jint)

jclass android.graphics.Canvas of JVMObject:
  proc drawLine(x1, y1, x2, y2: jfloat, p: Paint)

const
  black: int32 = 0xff000000'i32  # Color.BLACK
  white: int32 = 0xffffffff'i32  # Color.WHITE

type DrawView = ref object of View

jexport DrawView extends View:
  proc new(c: Context) = super(c)  # TODO: or else?
  proc onDraw(c: Canvas) =
    discard Log.d("hellomello", "DrawView.onDraw begin")
    var p = Paint.new()
    p.setColor(black)
    c.drawLine(0, 0, 20, 20, p)
    c.drawLine(20, 0, 0, 20, p)
    discard Log.d("hellomello", "DrawView.onDraw end")


type NimActivity = ref object of Activity

jexport NimActivity extends Activity:
  proc new() = super()  # TODO: or else?

  proc onCreate(b: Bundle) =
    discard Log.d("hellomello", "NimActivity.onCreate begin")
    this.super.onCreate(b)
    discard Log.d("hellomello", "NimActivity after super.onCreate")
    var v = DrawView.new(this)
    discard Log.d("hellomello", "NimActivity after DrawView.new")
    v.setBackgroundColor(white)
    discard Log.d("hellomello", "NimActivity after v.setBackgroundColor")
    this.setContentView(v)
    discard Log.d("hellomello", "NimActivity.onCreate end")

when defined(jnimGenDex):
  jnimDexWrite("jnim_gen_dex.nim")


