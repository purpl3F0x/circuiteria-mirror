#import "@preview/cetz:0.3.2": draw
#import "iec_gate.typ" as iec-gate

/// Draws an IEC-XOR gate. This function is also available as `element.iec-gate-xor()`
/// 
/// For parameters, see #doc-ref("gates.iec-gate")
/// #examples.gate-iec-xor
#let gate-iec-xor(
  x: none,
  y: none,
  w: none,
  h: none,
  inputs: 2,
  fill: none,
  stroke: black + 1pt,
  id: "",
  inverted: (),
  debug: (
    ports: false
  )
) = {
  iec-gate.iec-gate(
    x: x,
    y: y,
    w: w,
    h: h,
    inputs: inputs,
    fill: fill,
    stroke: stroke,
    id: id,
    inverted: inverted,
    debug: debug,
    symbol: $= 1$,
  )
}

/// Draws an IEC-NXOR gate. This function is also available as `element.iec-gate-nxor()`
/// 
/// For parameters, see #doc-ref("gates.iec-gate")
/// #examples.gate-iec-nxor
#let gate-iec-nxor(
  x: none,
  y: none,
  w: none,
  h: none,
  inputs: 2,
  fill: none,
  stroke: black + 1pt,
  id: "",
  inverted: (),
  debug: (
    ports: false
  )
) = {
  gate-iec-xor(
    x: x,
    y: y,
    w: w,
    h: h,
    inputs: inputs,
    fill: fill,
    stroke: stroke,
    id: id,
    inverted: if inverted != "all" {inverted + ("out",)} else {inverted},
    debug: debug
  )
}