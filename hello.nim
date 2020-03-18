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

type
  FlappyViewData = ref object
    walls: seq[tuple[x, y: int]]
    x, y: int
    score: int
    live: bool
    wallW2, holeH, birdR: int
    pWall, pBird: Paint

    renderer: Thread
    holder: SurfaceHolder

  FlappyView = ref object of View
    # TODO: can't we avoid this indirection level?
    data: FlappyViewData

jexport FlappyView extends SurfaceView implements Runnable:
  proc new(c: Context) = super(c)  # TODO: or else?

  proc start() =
    this.setBackgroundColor(blue)
    let
      w = this.getWidth()
      h = this.getHeight()
      d = this.data
    d.x = 30
    d.pWall = Paint.new()
    d.pWall.setColor(green)
    d.pBird = Paint.new()
    d.pBird.setColor(red)
    d.y = int(h / 2)
    d.walls = @[(int(w/2), this.data.y), (int(w), int(h/3*2))]
    d.live = true
    d.wallW2 = int(w/5/2)
    d.holeH = int(h/6)
    d.birdR = int(h/20)

    d.renderer = Thread.new(this)
    d.holder = this.getHolder()

  proc stop() =
    this.data.renderer.interrupt()

  proc run() =
    let d = this.data
    while true:
      if this.interrupted():
        break
      if !d.holder.getSurface().isValid():
        Thread.sleep(1000)
        continue
      let c = d.holder.lockCanvas()
      if c == nil:
        continue
      this.draw(c)
      d.holder.unlockCanvasAndPost(c)
      Thread.sleep(16)  # VERY roughly ~60fps

  proc draw(c: Canvas) =
    let d = this.data
    for w in d.walls:
      c.drawRect(w.x.float-d.wallW2.float, 0.float, w.x.float+d.wallW2.float, w.y.float-d.holeH.float, d.pWall)
      c.drawRect(w.x.float-d.wallW2.float, w.y.float+d.holeH.float, w.x.float+d.wallW2.float, height.float, d.pWall)
    c.drawCircle(width/2, d.y.float, d.birdR.float, d.pBird)


type
  NimActivityData = ref object
    v: FlappyView
  NimActivity = ref object of Activity
    data: NimActivityData

jexport NimActivity extends Activity:
  proc new() = super()  # TODO: or else?

  proc onCreate(b: Bundle) =
    discard Log.d("hellomello", "NimActivity.onCreate begin")
    this.super.onCreate(b)
    this.data.v = FlappyView.new(this)
    this.setContentView(v)
    discard Log.d("hellomello", "NimActivity.onCreate end")

  proc onResume() =
    super.onResume()
    this.data.v.start()

  proc onPause() =
    super.onPause()
    this.data.v.stop()

when defined(jnimGenDex):
  jnimDexWrite("jnim_gen_dex.nim")


