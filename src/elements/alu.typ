#import "@preview/cetz:0.2.2": draw
#import "element.typ"
#import "ports.typ": add-port

#let draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  let p0 = tl
  let p1 = (tr, 10%, br)
  let p2 = (tr, 90%, br)
  let p3 = bl
  let p4 = (tl, 55%, bl)
  let p5 = (tl, 50%, br)
  let p6 = (tl, 45%, bl)
  
  let f1 = draw.group(name: id, {
    
    draw.merge-path(
      inset: 0.5em,
      fill: fill,
      stroke: stroke,
      close: true,
      draw.line(p0, p1, p2, p3, p4, p5, p6)
    )
    draw.anchor("north", (p0, 50%, p1))
    draw.anchor("south", (p2, 50%, p3))
    draw.anchor("west", (p0, 50%, p3))
    draw.anchor("east", (p1, 50%, p2))
  })

  let f2 = add-port(id, "west", (id: "in1"), (p0, 50%, p6))
  let f3 = add-port(id, "west", (id: "in2"), (p3, 50%, p4))
  let f4 = add-port(id, "east", (id: "out"), (p1, 50%, p2))

  let f = {
    f1; f2; f3; f4
  }

  return (f, tl, tr, br, bl)
}

/// Draws an ALU with two inputs
///
/// #box(width: 100%, align(center)[
///   #circuit({
///     element.alu(x: 0, y: 0, w: 1, h: 2, id: "alu")
///     wire.stub("alu-port-in1", "west")
///     wire.stub("alu-port-in2", "west")
///     wire.stub("alu-port-out", "east")
///   })
/// ])
/// - x (number, dictionary): see `elmt()`
/// - y (number, dictionary): see `elmt()`
/// - w (number): see `elmt()`
/// - h (number): see `elmt()`
/// - name (none, str): see `elmt()`
/// - name-anchor (str): see `elmt()`
/// - fill (none, color): see `elmt()`
/// - stroke (stroke): see `elmt()`
/// - id (str): see `elmt()`
/// - debug (dictionary): see `elmt()`
#let alu(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    ports: false
  )
) = {
  let ports = (
    west: (
      (id: "in1"),
      (id: "in2"),
    ),
    east: (
      (id: "out"),
    )
  )
  
  element.elmt(
    draw-shape: draw-shape,
    x: x,
    y: y,
    w: w,
    h: h,
    name: name,
    name-anchor: name-anchor,
    ports: ports,
    fill: fill,
    stroke: stroke,
    id: id,
    auto-ports: false,
    ports-y: (
      in1: (h) => {h * 0.225},
      in2: (h) => {h * 0.775},
    ),
    debug: debug
  )
}