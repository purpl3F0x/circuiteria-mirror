#import "@preview/cetz:0.2.2": draw
#import "../element.typ"
#import "../ports.typ": add-port

#let draw-shape(
  id, tl, tr, br, bl,
  fill, stroke,
  zigzags: 7,
  vertical: false
) = {
  let (x, y) = bl
  let (width, height) = (tr.at(0) - x, tr.at(1) - y)
  
  let pts = if vertical {(
    (x + width / 2, y),
    (x + width / 2, y + height * 0.2),
  )} else {(
    (x, y + height / 2),
    (x + width * 0.2, y + height / 2),
  )}
  
  for i in range(zigzags) {
    let r = ((i+0.5) / zigzags * 0.6 + 0.2)
    let pos = if vertical {(
      x + width * calc.rem(i, 2),
      r * height + y
    )} else {(
      r * width + x,
      y + height * calc.rem(i, 2)
    )}
    pts.push(pos)
  }

  pts += if vertical {(
    (x + width / 2, y + height * 0.8),
    (x + width / 2, y + height),
  )} else {(
    (x + width * 0.8, y + height / 2),
    (x + width, y + height / 2),
  )}

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
/// - zigzags (number): Number of zigzags to draw
#let resistor(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  vertical: false,
  zigzags: 7,
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