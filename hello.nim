{.experimental: "codeReordering".}
import jnim, macros
import locks
import random

## Android system classes

import jnim/java/lang
import android/content/context
import android/app/activity
import android/os/bundle
import android/graphics/[paint, canvas]
import android/view/[view, surface, surface_view, surface_holder, motion_event]
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
    vy: int
    score: int
    live: bool
    wallW2, holeH, birdR: int
    pSky, pWall, pBird: Paint

    rng: Rand

    holder: SurfaceHolder
    renderer: Thread

    lock: Lock
    touched: bool

  FlappyView = ref object of View
    # TODO: can't we avoid this indirection level?
    data: FlappyViewData

jexport FlappyView extends SurfaceView implements Runnable, SurfaceHolderCallback:
  proc new(c: Context) = super(c)  # TODO: or else?

  proc surfaceChanged*(holder: SurfaceHolder; format, width, height: jint) =
    discard
  proc surfaceCreated*(holder: SurfaceHolder) =
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
    discard

  proc onTouchEvent*(evt: MotionEvent): jboolean =
    this.data.lock.withLock:
      this.data.touched = true
    # FIXME: can we avoid cast below?
    return this.super.onTouchEvent(evt).jboolean

  proc start() =
    let d = this.data
    d.lock.initLock
    d.rng = initRand(123)
    # TODO: can we avoid 'super' below? getWidth() doesn't complain, why?
    d.holder = this.super.getHolder()
    # TODO: can we avoid cast below?
    d.renderer = Thread.new(cast[Runnable](this))
    d.renderer.start()

  proc stop() =
    this.data.renderer.interrupt()
    this.data.renderer.join()

  proc logic(c: Canvas) =
    let
      d = this.data
      height = this.getHeight()
      width = this.getWidth()

    if not d.live:
      d.live = true
      d.y = int(height/2)
      d.vy = -17

    d.lock.withLock:
      if d.touched:
        d.touched = false
        d.vy = -17
    d.vy.inc
    d.y += d.vy

    # TEMPORARY:
    if d.y > height or d.y < 0:
      d.live = false

    c.drawPaint(d.pSky)
    for w in d.walls.mitems:
      c.drawRect(w.x.float-d.wallW2.float, 0.float, w.x.float+d.wallW2.float, w.y.float-d.holeH.float, d.pWall)
      c.drawRect(w.x.float-d.wallW2.float, w.y.float+d.holeH.float, w.x.float+d.wallW2.float, height.float, d.pWall)
      if w.x < 0:
        w.x = width.int
        w.y = d.rng.rand(200 .. height.int-200)
      w.x -= 3
    c.drawCircle(width/2, d.y.float, d.birdR.float, d.pBird)
    # if not d.isnil and not d.touched.isnil and d.touched.get:
    #   d.touched.set(false)
    #   d.y.dec

  proc run() =
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


type
  NimActivityData = ref object
    v: FlappyView
  NimActivity = ref object of Activity
    data: NimActivityData

jexport NimActivity extends Activity:
  proc new() = super()  # TODO: or else?

  proc onCreate(b: Bundle) =
    this.super.onCreate(b)
    let v = FlappyView.new(this)
    this.data.v = v
    v.super.getHolder().addCallback(v)
    this.super.setContentView(v)

  proc onResume() =
    this.super.onResume()
    this.data.v.start()

  proc onPause() =
    this.super.onPause()
    this.data.v.stop()

when defined(jnimGenDex):
  jnimDexWrite("jnim_gen_dex.nim")


