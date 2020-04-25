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
    pWall, pBird: Paint

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
    proc surfaceCreated*(holder: SurfaceHolder) =
      # let d = this.data
      # if d.renderer != nil:
      #   d.renderer.join()
      # d.renderer = Thread.new(cast[Runnable](this))
      discard Log.d("hellomello", "FlappyView.surfaceCreated")
    proc surfaceDestroyed*(holder: SurfaceHolder) =
      discard Log.d("hellomello", "FlappyView.surfaceDestroyed")

    proc start() =
      discard Log.d("hellomello", "FlappyView.start begin")
      this.setBackgroundColor(blue)
      this.setWillNotDraw(false)
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
      d.renderer.start()
      discard Log.d("hellomello", "FlappyView.start end")

    proc stop() =
      discard Log.d("hellomello", "FlappyView.stop begin")
      this.data.renderer.interrupt()
      this.data.renderer.join()
      discard Log.d("hellomello", "FlappyView.stop end")

    proc dodraw(c: Canvas) =
      discard Log.d("hellomello", "FlappyView.dodraw begin")
      let d = this.data
      let height = this.getHeight()
      let width = this.getWidth()
      for w in d.walls:
        c.drawRect(w.x.float-d.wallW2.float, 0.float, w.x.float+d.wallW2.float, w.y.float-d.holeH.float, d.pWall)
        c.drawRect(w.x.float-d.wallW2.float, w.y.float+d.holeH.float, w.x.float+d.wallW2.float, height.float, d.pWall)
      c.drawCircle(width/2, d.y.float, d.birdR.float, d.pBird)
      discard Log.d("hellomello", "FlappyView.dodraw end")

    proc run() =
      discard Log.d("hellomello", "FlappyView.run begin")
      let d = this.data
      discard Log.d("hellomello", "FlappyView.run after d=this.data")
      while true:
        discard Log.d("hellomello", "FlappyView.run after while start")
        if Thread.interrupted().bool:
          discard Log.d("hellomello", "FlappyView.run after interrupted break")
          break
        discard Log.d("hellomello", "FlappyView.run after if interrupted")
        discard Log.d("hellomello", "FlappyView.run isValid? " & $this.super.getHolder().getSurface().isValid())
        if not d.holder.getSurface().isValid().bool:
          discard Log.d("hellomello", "FlappyView.run after not isValid")
          Thread.sleep(1000)
          discard Log.d("hellomello", "FlappyView.run after sleep(1000)")
          continue
        discard Log.d("hellomello", "FlappyView.run after if not isValid")
        let c = d.holder.lockCanvas()
        discard Log.d("hellomello", "FlappyView.run after lockCanvas")
        if isnil c:
        # if c == nil:  # SIGSEGV
          discard Log.d("hellomello", "FlappyView.run after c==nil")
          continue
        discard Log.d("hellomello", "FlappyView.run after if c==nil")
        this.dodraw(c)
        discard Log.d("hellomello", "FlappyView.run after dodraw")
        d.holder.unlockCanvasAndPost(c)
        discard Log.d("hellomello", "FlappyView.run after unlockCanvasAndPost")
        Thread.sleep(16)  # VERY roughly ~60fps
        discard Log.d("hellomello", "FlappyView.run after sleep(16)")
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
    # v.super.setVisibility(0)  # VISIBLE
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


