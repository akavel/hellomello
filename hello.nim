{.experimental: "codeReordering".}
import jnim

import jnim/java/lang

## Android system classes

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
  proc drawCircle(x, y, r: jfloat, p: Paint)
  proc drawRect(left, top, right, bottom: jfloat, p: Paint)

const
  black: int32 = 0xff000000'i32  # Color.BLACK
  white: int32 = 0xffffffff'i32  # Color.WHITE
  blue: int32 =  0xffaaaaff'i32
  green: int32 = 0xff00ff00'i32
  red: int32 =   0xffff0000'i32


## Main code

type FlappyView = ref object of View
  walls: seq[tuple[x, y: int]]
  x, y: int
  score: int
  live: bool
  wallW2, holeH, birdR: int
  pWall, pBird: Paint

jexport FlappyView extends View:
  proc new(c: Context) = super(c)  # TODO: or else?
  proc init(w, h: int32) =
    this.setBackgroundColor(blue)
    this.y = int(h / 2)
    this.walls = @[(int(w/2), this.y), (int(w), int(h/3*2))]
    this.live = true
    this.wallW2 = int(w/5/2)
    this.holeH = int(h/6)
    this.birdR = int(h/20)
    this.pWall = Paint.new()
    this.pWall.setColor(green)
    this.pBird = Paint.new()
    this.pBird.setColor(red)
  proc onDraw(c: Canvas) =
    var
      width = this.getWidth()
      height = this.getHeight()
    if this.walls.len == 0:
      this.init(width, height)
    for w in this.walls:
      c.drawRect(w.x.float-this.wallW2.float, 0.float, w.x.float+this.wallW2.float, w.y.float-this.holeH.float, this.pWall)
      c.drawRect(w.x.float-this.wallW2.float, w.y.float+this.holeH.float, w.x.float+this.wallW2.float, height.float, this.pWall)
    c.drawCircle(width/2, this.y.float, this.birdR.float, this.pBird)


type NimActivity = ref object of Activity

jexport NimActivity extends Activity:
  proc new() = super()  # TODO: or else?

  proc onCreate(b: Bundle) =
    discard Log.d("hellomello", "NimActivity.onCreate begin")
    this.super.onCreate(b)
    var v = FlappyView.new(this)
    this.setContentView(v)
    discard Log.d("hellomello", "NimActivity.onCreate end")

when defined(jnimGenDex):
  jnimDexWrite("jnim_gen_dex.nim")


