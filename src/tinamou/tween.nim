## Tween
##
## Usage
## ======
##
## ::
##   var
##     t: int = 0
##     x: float = quad.tweenIn().ease(t, 0.0, 400.0, 120)
##     y: float = exponential.tweenInOut().yoyo().ease(t, 0.0, 600.0, 30)
##

import math

type
  BaseTween = (proc (x: float): float) not nil

let
  linear*: BaseTween = proc (x: float): float = x
  quad*: BaseTween = proc (x: float): float = x * x
  cubic*: BaseTween = proc (x: float): float = x * x * x
  quint*: BaseTween = proc (x: float): float = x * x * x * x
  quart*: BaseTween = proc (x: float): float = x * x * x * x * x
  sinusoidal*: BaseTween = proc (x: float): float = 1 - cos(x / 2 * PI)
  exponential*: BaseTween = proc (x: float): float = (if x == 0: 0.0 else: pow(1024, x - 1))
  circular*: BaseTween = proc (x: float): float = 1 - sqrt(1 - x * x)
  elastic*: BaseTween = proc (x: float): float = 56 * x * x * x * x * x - 105 * x * x * x * x + 60 * x * x * x - 10 * x * x
  softback*: BaseTween = proc (x: float): float = x * x * (2 * x - 1)
  back*: BaseTween = proc (x: float): float = x * x * (2.70158 * x - 1.70158)

proc tweenIn*(f: BaseTween): BaseTween = f
proc tweenOut*(f: BaseTween): BaseTween = (proc (x: float): float = 1 - f(1 - x))
proc tweenInOut*(f: BaseTween): BaseTween = (proc (x: float): float = (if x < 0.5: f(x * 2) / 2 else: 1 - f(2 - x * 2) / 2))

proc yoyo*(f: BaseTween): BaseTween =
  ## Repeat forwarding and backwarding.
  return proc (x: float): float =
    let l: float = x mod 2
    return if l < 1: f(l) else: f(2 - l)

proc ease*(f: BaseTween; time: Positive; begin, delta: float; duration: Positive): float =
  ## Apply easing function.
  return begin + delta * f(time / duration)
