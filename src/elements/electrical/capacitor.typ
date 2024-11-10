#import "@preview/cetz:0.2.2": draw
#import "../element.typ"
#import "../ports.typ": add-port

#let draw-shape(
  id, tl, tr, br, bl,
  fill, stroke,
  vertical: false,
  gap: 0.2,
  scales: (100%, 100%),
  symbols: (none, none)
) = {
  let (x0, y0) = tl
  let (x1, y1) = br

  let w = x1 - x0
  let h = y1 - y0

  let (o0, s0) = if vertical {(y0, h)} else {(x0, w)}
  let (o1, s1) = if vertical {(x0, w)} else {(y0, h)}
  let m1 = o1 + s1 / 2

  let pt(i, j) = if vertical {
    (j, i)
  } else {
    (i, j)
  }

  let size0 = s1 * scales.first() / 100%
  let size1 = s1 * scales.last() / 100%

  if type(gap) == ratio {
    gap = gap / 100%
  } else {
    gap = gap / calc.abs(s0)
  }
  let r0 = 0.5 - gap / 2
  let r1 = 0.5 + gap / 2

  // Coordinates in (main axis, secondary axis) format
  let p0 = pt(o0, m1)
  let p1 = pt(o0 + r0 * s0, m1)
  let p2 = pt(o0 + r1 * s0, m1)
  let p3 = pt(o0 + s0, m1)
  
  let p4 = pt(o0 + r0 * s0, m1 - size0 / 2)
  let p5 = pt(o0 + r0 * s0, m1 + size0 / 2)
  
  let p6 = pt(o0 + r1 * s0, m1 - size1 / 2)
  let p7 = pt(o0 + r1 * s0, m1 + size1 / 2)

  let line = draw.line.with(stroke: stroke)
  let f = draw.group(name: id, {
    line(p0, p1)
    line(p2, p3)
    line(p4, p5)
    line(p6, p7)

    if symbols.first() != none {
      draw.content(
        p1,
        symbols.first(),
        anchor: if vertical {"south-west"} else {"south-east"},
        padding: 2pt
      )
    }

    if symbols.last() != none {
      draw.content(
        p2,
        symbols.last(),
        anchor: if vertical {"north-west"} else {"south-west"},
        padding: 2pt
      )
    }
  })

  return (f, tl, tr, br, bl)
}

/// Draws a capacitor
///
/// #examples.capacitor
/// For other parameters description, see #doc-ref("element.elmt")
/// - vertical (bool): Whether the element is vertical or horizontal.
///   - If false, port 0 is placed on the west side and port 1 on the east.\
///   - If true, they are on the north, respectively the south sides
/// - gap (number, ratio): The gap between both sides
///   - if it is a number (int or float), it is interpreted as an absolute canvas-unit length
///   - if it is a ratio, it is interpreted as proportional to the capacitor's length (width if horizontal, height if vertical)
/// - scales (array): A pair of ratios, the sizes of the sides relative to the capacitor's height (width if vertical).
/// - symbols (array): A pair of content or strings (or none values) to attach on the sides of the capacitor
#let capacitor(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  vertical: false,
  gap: 0.2,
  scales: (100%, 100%),
  symbols: (none, none),
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    ports: false
  )
) = {
  let ports = if vertical {(
    north: ((id: "0"),),
    south: ((id: "1"),)
  )} else {(
    west: ((id: "0"),),
    east: ((id: "1"),)
  )}
  
  element.elmt(
    draw-shape: draw-shape.with(
      vertical: vertical,
      gap: gap,
      scales: scales,
      symbols: symbols
    ),
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
    debug: debug
  )
}