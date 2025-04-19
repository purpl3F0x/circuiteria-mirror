#import "@preview/cetz:0.3.2": draw
#import "element.typ"
#import "ports.typ": add-port
#import "../util.typ"

#let draw-shape(elmt, bounds) = {
  let tl = bounds.tl
  let tr = bounds.tr
  let bl = bounds.bl
  let br = bounds.br

  let p0 = tl
  let p1 = util.lerp(tr, 10%, br)
  let p2 = util.lerp(tr, 90%, br)
  let p3 = bl
  let p4 = util.lerp(tl, 55%, bl)
  let p5 = util.lerp(tl, 50%, br)
  let p6 = util.lerp(tl, 45%, bl)

  let bounds2 = element.complete-bounds(elmt, (
    tl: p0,
    tr: p1,
    br: p2,
    bl: p3
  ))
  
  let f = {
    draw.line(
      p0, p1, p2, p3, p4, p5, p6,
      fill: elmt.fill,
      stroke: elmt.stroke,
      close: true
    )
    draw.anchor("name", (p5, 50%, (p1, 50%, p2)))
  }

  return (f, bounds2)
}

/// Draws an ALU with two inputs
///
/// #examples.alu
/// For parameters description, see #doc-ref("element.elmt")
#let alu(
  ..args
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
  
  return element.elmt(
    draw-shape: draw-shape,
    ports: ports,
    ports-pos: (
      west: (
        in1: l => l * 0.225,
        in2: l => l * 0.775,
      ),
      east: (
        out: l => l * 0.5
      )
    ),
    ..args
  )
}