#import "@preview/cetz:0.3.2": draw
#import "../util.typ"
#import "element.typ"
#import "ports.typ": add-port

#let draw-shape(elmt, bounds) = {
  let margin = (100% - elmt.l-ratio) / 2
  let tr2 = util.lerp(bounds.tr, margin, bounds.br)
  let br2 = util.lerp(bounds.br, margin, bounds.tr)
  let bounds2 = element.complete-bounds(elmt, (
    tl: bounds.tl,
    bl: bounds.bl,
    tr: tr2,
    br: br2,
  ))
  let f = {
    draw.merge-path(
      inset: 0.5em,
      fill: elmt.fill,
      stroke: elmt.stroke,
      close: true,
      draw.line(bounds2.tl, bounds2.tr, bounds2.br, bounds2.bl)
    )
    draw.anchor("north", bounds2.t)
    draw.anchor("south", bounds2.b)
    draw.anchor("west", bounds2.l)
    draw.anchor("east", bounds2.r)
    draw.anchor("north-west", bounds2.tl)
    draw.anchor("north-east", bounds2.tr)
    draw.anchor("south-east", bounds2.br)
    draw.anchor("south-west", bounds2.bl)
  }

  return (f, bounds2)
}

/// Draws a multiplexer
///
/// #examples.multiplexer
/// For other parameters description, see #doc-ref("element.elmt")
/// - entries (int, array): If it is an integer, it defines the number of input ports (automatically named with their binary index). If it is an array of strings, it defines the name of each input.
/// - h-ratio (ratio): The height ratio of the right side relative to the full height
#let multiplexer(
  entries: 2,
  l-ratio: 60%,
  ..args
) = {
  let in-ports = ()
  let ports-pos = (
    "east": auto,
  )

  if (type(entries) == int) {
    let nbits = calc.ceil(calc.log(entries, base: 2))
    for i in range(entries) {
      let bits = util.lpad(str(i, base: 2), nbits)
      in-ports.push((id: "in" + str(i), name: bits))
    }
  } else {
    for (i, port) in entries.enumerate() {
      in-ports.push((id: "in" + str(i), name: port))
    }
  }

  let n = in-ports.len()
  ports-pos.insert("west", (l, i) => {l * (i + 0.5) / n})
  
  element.elmt(
    cls: "multiplexer",
    draw-shape: draw-shape,
    ports: (west: in-ports, east: ((id: "out"),)),
    ports-pos: ports-pos,
    extra: (l-ratio: l-ratio),
    ..args
  )

  /*
  for (i, port) in ports.enumerate() {
    let pct = (i + 0.5) * space
    add-port(id, "west", port, (id+".north-west", pct, id+".south-west"))
  }
  add-port(id, "east", (id: "out"), (id+".north-east", 50%, id+".south-east"))
  */
}