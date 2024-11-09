#import "@preview/cetz:0.2.2": draw
#import "../element.typ"
#import "../ports.typ": add-port

#let draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  let f = draw.rect(tl, br, name: id, stroke: stroke, fill: fill)
  return (f, tl, tr, br, bl)
}

/// Draws a capacitor
///
/// #examples.capacitor
/// For other parameters description, see #doc-ref("element.elmt")
/// - vertical (bool): Whether the element is vertical or horizontal. If false, port 0 is placed on the west side and port 1 on the east. If true, they are on the north, respectively the south sides
#let capacitor(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  vertical: false,
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
    draw-shape: draw-shape.with(),
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