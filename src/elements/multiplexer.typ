#import "@preview/cetz:0.2.2": draw
#import "../util.typ"
#import "element.typ"

#let draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  let tr2 = (tr, 20%, br)
  let br2 = (tr, 80%, br)
  let f = draw.group(name: id, {
    draw.merge-path(
      inset: 0.5em,
      fill: fill,
      stroke: stroke,
      close: true,
      draw.line(tl, tr2, br2, bl)
    )
    draw.anchor("north", (tl, 50%, tr2))
    draw.anchor("south", (bl, 50%, br2))
    draw.anchor("west", (tl, 50%, bl))
    draw.anchor("east", (tr2, 50%, br2))
  })
  return (f, tl, tr, br, bl)
}

/// Draws a multiplexer
///
/// #examples.multiplexer
/// - x (number, dictionary): see #doc-ref("element.elmt")
/// - y (number, dictionary): see #doc-ref("element.elmt")
/// - w (number): see #doc-ref("element.elmt")
/// - h (number): see #doc-ref("element.elmt")
/// - name (none, str): see #doc-ref("element.elmt")
/// - name-anchor (str): see #doc-ref("element.elmt")
/// - entries (int, array): If it is an integer, it defines the number of input ports (automatically named with their binary index). If it is an array of strings, it defines the name of each input.
/// - fill (none, color): see #doc-ref("element.elmt")
/// - stroke (stroke): see #doc-ref("element.elmt")
/// - id (str): see #doc-ref("element.elmt")
/// - debug (dictionary): see #doc-ref("element.elmt")
#let multiplexer(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  entries: 2,
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    ports: false
  )
) = {
  let ports = ()

  if (type(entries) == int) {
    let nbits = calc.ceil(calc.log(entries, base: 2))
    for i in range(entries) {
      let bits = util.lpad(str(i, base: 2), nbits)
      ports.push((id: "in" + str(i), name: bits))
    }
  } else {
    for (i, port) in entries.enumerate() {
      ports.push((id: "in" + str(i), name: port))
    }
  }
  
  element.elmt(
    draw-shape: draw-shape,
    x: x,
    y: y,
    w: w,
    h: h,
    name: name,
    name-anchor: name-anchor,
    ports: (west: ports, east: ((id: "out"),)),
    fill: fill,
    stroke: stroke,
    id: id,
    debug: debug
  )
}