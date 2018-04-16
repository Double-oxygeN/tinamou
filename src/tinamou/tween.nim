## Tween
##
## Usage
## ======
##
## ::
##   var
##     t: uint = 0
##     x: float = quad.tweenIn().ease(t, 0.0, 400.0, 120)
##     y: float = exponential.tweenInOut().yoyo().ease(t, 0.0, 600.0, 30)
##

import math

type
  TBaseTween = (proc (x: float): float) not nil

let
  linear*: TBaseTween = proc (x: float): float = x
  quad*: TBaseTween = proc (x: float): float = x * x
  cubic*: TBaseTween = proc (x: float): float = x * x * x
  quint*: TBaseTween = proc (x: float): float = x * x * x * x
  quart*: TBaseTween = proc (x: float): float = x * x * x * x * x
  sinusoidal*: TBaseTween = proc (x: float): float = 1 - cos(x / 2 * PI)
  exponential*: TBaseTween = proc (x: float): float = (if x == 0: 0.0 else: pow(1024, x - 1))
  circular*: TBaseTween = proc (x: float): float = 1 - sqrt(1 - x * x)
  elastic*: TBaseTween = proc (x: float): float = 56 * x * x * x * x * x - 105 * x * x * x * x + 60 * x * x * x - 10 * x * x
  softback*: TBaseTween = proc (x: float): float = x * x * (2 * x - 1)
  back*: TBaseTween = proc (x: float): float = x * x * (2.70158 * x - 1.70158)

proc tweenIn*(f: TBaseTween): TBaseTween = f
proc tweenOut*(f: TBaseTween): TBaseTween = (proc (x: float): float = 1 - f(1 - x))
proc tweenInOut*(f: TBaseTween): TBaseTween = (proc (x: float): float = (if x < 0.5: f(x * 2) / 2 else: 1 - f(2 - x * 2) / 2))

proc yoyo*(f: TBaseTween): TBaseTween =
  (proc (x: float): float =
    let l: float = x mod 2
    return if l < 1: f(l) else: f(2 - l))

proc ease*(f: TBaseTween; time: uint; begin, delta: float; duration: uint): float =
  ## Apply easing function.
  return begin + delta * f(time.int / duration.int)
