#import "@preview/cetz:0.2.2": draw
#import "element.typ"

#let draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  let (x, y) = bl
  let (width, height) = (tr.at(0) - x, tr.at(1) - y)

  tl = (x, y + height * 0.75)
  let tr2 = (x + width, y + height * 0.75)
  let br = (x + width, y)
  (tr, tr2) = (tr2, tr)
  let f = draw.group(name: id, {
    draw.merge-path(
      inset: 0.5em,
      fill: fill,
      stroke: stroke,
      close: true,
      draw.line(tl, tr2, br, bl)
    )
    draw.anchor("north", (tl, 50%, tr2))
    draw.anchor("south", (bl, 50%, br))
    draw.anchor("west", (tl, 50%, bl))
    draw.anchor("east", (tr2, 50%, br))
  })
  return (f, tl, tr, br, bl)
}

/// Draws a bit extender
///
/// #examples.extender
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
#let extender(
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
      (id: "in"),
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
    debug: debug
  )
}