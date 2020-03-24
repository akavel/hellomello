{.experimental: "codeReordering".}
import jnim

## Android system classes

import jnim/java/lang
import android/content/context
import android/app/activity
import android/os/bundle
import android/graphics/[paint, canvas]
import android/view/[view, surface, surface_view, surface_holder]
import android/util/log

jclass java.lang.Thread of JVMObject:
  proc new(r: Runnable)
  proc run()
  proc join()
  proc sleep(millis: jlong) {.`static`.}
  proc interrupt()
  proc isInterrupted(): jboolean {.`static`.}

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

    holder: SurfaceHolder
    renderer: Thread

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

    # TODO: can we avoid 'super' below? getWidth() doesn't complain, why?
    d.holder = this.super.getHolder()
    # TODO: can we avoid cast below?
    d.renderer = Thread.new(cast[Runnable](this))
    d.renderer.run()

  proc stop() =
    this.data.renderer.interrupt()
    this.data.renderer.join()

  proc draw(c: Canvas) =
    let d = this.data
    let height = this.getHeight()
    let width = this.getWidth()
    for w in d.walls:
      c.drawRect(w.x.float-d.wallW2.float, 0.float, w.x.float+d.wallW2.float, w.y.float-d.holeH.float, d.pWall)
      c.drawRect(w.x.float-d.wallW2.float, w.y.float+d.holeH.float, w.x.float+d.wallW2.float, height.float, d.pWall)
    c.drawCircle(width/2, d.y.float, d.birdR.float, d.pBird)

  proc run() =
    let d = this.data
    while true:
      if Thread.isInterrupted().bool:
        break
      if not d.holder.getSurface().isValid().bool:
        Thread.sleep(1000)
        continue
      let c = d.holder.lockCanvas()
      if c == nil:
        continue
      this.draw(c)
      d.holder.unlockCanvasAndPost(c)
      Thread.sleep(16)  # VERY roughly ~60fps


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
    this.setContentView(this.data.v)
    discard Log.d("hellomello", "NimActivity.onCreate end")

  proc onResume() =
    this.super.onResume()
    this.data.v.start()

  proc onPause() =
    this.super.onPause()
    this.data.v.stop()

when defined(jnimGenDex):
  jnimDexWrite("jnim_gen_dex.nim")


