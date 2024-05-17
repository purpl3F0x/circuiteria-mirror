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
/// #box(width: 100%, align(center)[
///   #circuit({
///     element.multiplexer(
///       x: 0, y: 0,
///       w: 1, h: 3,
///       id: "multiplexer",
///       entries: 3
///     )
///     wire.stub("multiplexer-port-in0", "west")
///     wire.stub("multiplexer-port-in1", "west")
///     wire.stub("multiplexer-port-in2", "west")
///     wire.stub("multiplexer.north", "north")
///     wire.stub("multiplexer-port-out", "east")
///     element.multiplexer(
///       x: 3, y: 0,
///       w: 1, h: 3,
///       id: "multiplexer2",
///       entries: ("A", "B", "C")
///     )
///     wire.stub("multiplexer2-port-in0", "west")
///     wire.stub("multiplexer2-port-in1", "west")
///     wire.stub("multiplexer2-port-in2", "west")
///     wire.stub("multiplexer2.south", "south")
///     wire.stub("multiplexer2-port-out", "east")
///   })
/// ])
/// - x (number, dictionary): see `elmt()`
/// - y (number, dictionary): see `elmt()`
/// - w (number): see `elmt()`
/// - h (number): see `elmt()`
/// - name (none, str): see `elmt()`
/// - name-anchor (str): see `elmt()`
/// - entries (int, array): If it is an integer, it defines the number of input ports (automatically named with their binary index). If it is an array of string, it defines the name of each input.
/// - fill (none, color): see `elmt()`
/// - stroke (stroke): see `elmt()`
/// - id (str): see `elmt()`
/// - debug (dictionary): see `elmt()`
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