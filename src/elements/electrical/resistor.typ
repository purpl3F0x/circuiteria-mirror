#import "@preview/cetz:0.2.2": draw
#import "../element.typ"
#import "../ports.typ": add-port

#let draw-shape(
  id, tl, tr, br, bl,
  fill, stroke,
  zigzags: 6,
  vertical: false
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

  let p0 = pt(o0, m1)
  let p1 = pt(o0 + 0.2 * s0, m1)
  let p2 = pt(o0 + 0.8 * s0, m1)
  let p3 = pt(o0 + s0, m1)

  if zigzags == none {
    let p4 = pt(o0 + 0.2 * s0, o1)
    let p5 = pt(o0 + 0.8 * s0, o1 + s1)
    let f = draw.group(name: id, {
      draw.line(p0, p1)
      draw.line(p2, p3)
      draw.rect(p4, p5, stroke: stroke, fill: fill)
    })
    return (f, tl, tr, br, bl)
  }
  
  let pts = (p0, p1)
  
  for i in range(zigzags) {
    let r = ((i+0.5) / zigzags * 0.6 + 0.2)
    let pos = pt(o0 + r * s0, o1 + s1 * calc.rem(i, 2))
    pts.push(pos)
  }

  pts += (p2, p3)

  let f = draw.group(name: id, {
    draw.line(..pts, stroke: stroke)
  })
  return (f, tl, tr, br, bl)
}

/// Draws a resistor
///
/// #examples.resistor
/// For other parameters description, see #doc-ref("element.elmt")
/// - vertical (bool): Whether the element is vertical or horizontal. If false, port 0 is placed on the west side and port 1 on the east. If true, they are on the north, respectively the south sides
/// - zigzags (number, none): Number of zigzags to draw. If none, a rectangle is drawn
#let resistor(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  vertical: false,
  zigzags: 6,
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
      zigzags: zigzags
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