{.experimental: "codeReordering".}
import jnim

import jnim/java/lang

import android/content/context
import android/app/activity
import android/os/bundle
import android/view/view
import android/util/log

const
  black: int32 = 0xff000000  # Color.BLACK
  white: int32 = 0xffffffff  # Color.WHITE

type DrawView = ref object of View

jexport DrawView extends View:
  proc new(c: Context) = super(c)  # TODO: or else?
  proc onDraw(c: Canvas) =
    var p = Paint.new()
    p.setColor(black)
    c.drawLine(0, 0, 20, 20, p)
    c.drawLine(20, 0, 0, 20, p)


type NimActivity = ref object of Activity

jexport NimActivity extends Activity:
  proc new() = super()  # TODO: or else?

  proc onCreate(b: Bundle) =
    this.super.onCreate(b)
    var v = DrawView.new(this)
    v.setBackgroundColor(white)
    this.setContentView(v)

jnimDexWrite("jnim_gen_dex.nim")


