#import "@preview/cetz:0.3.2": draw
#import "../util.typ"
#import "element.typ"
#import "ports.typ": add-port

#let draw-shape(elmt, bounds) = {
  let margin = (100% - elmt.l-ratio) / 2
  let tr2 = (bounds.tr, margin, bounds.br)
  let br2 = (bounds.br, margin, bounds.tr)
  let f = draw.group(name: elmt.id, {
    draw.merge-path(
      inset: 0.5em,
      fill: elmt.fill,
      stroke: elmt.stroke,
      close: true,
      draw.line(bounds.tl, tr2, br2, bounds.bl)
    )
    draw.anchor("north", (bounds.tl, 50%, tr2))
    draw.anchor("south", (bounds.bl, 50%, br2))
    draw.anchor("west", (bounds.tl, 50%, bounds.bl))
    draw.anchor("east", (tr2, 50%, br2))
    draw.anchor("north-west", bounds.tl)
    draw.anchor("north-east", tr2)
    draw.anchor("south-east", br2)
    draw.anchor("south-west", bounds.bl)
  })

  return (f, bounds)
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