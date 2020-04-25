{.experimental: "codeReordering".}
import jnim, macros

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
  proc start()
  proc join()
  proc sleep(millis: jlong) {.`static`.}
  proc interrupt()
  proc interrupted(): jboolean {.`static`.}
  proc isInterrupted(): jboolean

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
    pSky, pWall, pBird: Paint

    holder: SurfaceHolder
    renderer: Thread

  FlappyView = ref object of View
    # TODO: can't we avoid this indirection level?
    data: FlappyViewData

expandMacros: expandMacros:
  jexport FlappyView extends SurfaceView implements Runnable, SurfaceHolderCallback:
    proc new(c: Context) = super(c)  # TODO: or else?

    proc surfaceChanged*(holder: SurfaceHolder; format, width, height: jint) =
      discard Log.d("hellomello", "FlappyView.surfaceChanged")
      discard
    proc surfaceCreated*(holder: SurfaceHolder) =
      discard Log.d("hellomello", "FlappyView.surfaceCreated")
      let
        w = this.getWidth()
        h = this.getHeight()
        d = this.data
      d.y = int(h / 2)
      d.walls = @[(int(w/2), d.y), (int(w), int(h/3*2))]
      d.wallW2 = int(w/5/2)
      d.holeH = int(h/6)
      d.birdR = int(h/20)
      d.live = true
      ###
      d.x = 30
      d.pSky = Paint.new()
      d.pSky.setColor(blue)
      d.pWall = Paint.new()
      d.pWall.setColor(green)
      d.pBird = Paint.new()
      d.pBird.setColor(red)
    proc surfaceDestroyed*(holder: SurfaceHolder) =
      discard Log.d("hellomello", "FlappyView.surfaceDestroyed")
      discard

    proc start() =
      discard Log.d("hellomello", "FlappyView.start begin")
      let d = this.data
      # TODO: can we avoid 'super' below? getWidth() doesn't complain, why?
      d.holder = this.super.getHolder()
      # TODO: can we avoid cast below?
      d.renderer = Thread.new(cast[Runnable](this))
      d.renderer.start()
      discard Log.d("hellomello", "FlappyView.start end")

    proc stop() =
      discard Log.d("hellomello", "FlappyView.stop begin")
      this.data.renderer.interrupt()
      this.data.renderer.join()
      discard Log.d("hellomello", "FlappyView.stop end")

    proc logic(c: Canvas) =
      # discard Log.d("hellomello", "FlappyView.logic begin")
      let d = this.data
      let height = this.getHeight()
      let width = this.getWidth()
      c.drawPaint(d.pSky)
      for w in d.walls.mitems:
        c.drawRect(w.x.float-d.wallW2.float, 0.float, w.x.float+d.wallW2.float, w.y.float-d.holeH.float, d.pWall)
        c.drawRect(w.x.float-d.wallW2.float, w.y.float+d.holeH.float, w.x.float+d.wallW2.float, height.float, d.pWall)
        if w.x < 0:
          w.x = width.int
          # w.y = random(200, height-200)
        w.x -= 3
      c.drawCircle(width/2, d.y.float, d.birdR.float, d.pBird)
      # discard Log.d("hellomello", "FlappyView.logic end")

    proc run() =
      discard Log.d("hellomello", "FlappyView.run begin")
      let d = this.data
      while true:
        if Thread.interrupted().bool:
          break
        if not d.holder.getSurface().isValid().bool:
          Thread.sleep(1000)
          continue
        let c = d.holder.lockCanvas()
        if isnil c: # NOTE: SIGSEGV when `if c == nil:`
          continue
        this.logic(c)
        d.holder.unlockCanvasAndPost(c)
        Thread.sleep(16)  # VERY roughly ~60fps
      discard Log.d("hellomello", "FlappyView.run end")


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
    let v = FlappyView.new(this)
    this.data.v = v
    v.super.getHolder().addCallback(v)
    # this.super.setContentView(this.data.v)
    this.super.setContentView(v)
    discard Log.d("hellomello", "NimActivity.onCreate end")

  proc onResume() =
    discard Log.d("hellomello", "NimActivity.onResume begin")
    this.super.onResume()
    this.data.v.start()
    discard Log.d("hellomello", "NimActivity.onResume end")

  proc onPause() =
    discard Log.d("hellomello", "NimActivity.onPause begin")
    this.super.onPause()
    this.data.v.stop()
    discard Log.d("hellomello", "NimActivity.onPause end")

when defined(jnimGenDex):
  jnimDexWrite("jnim_gen_dex.nim")


