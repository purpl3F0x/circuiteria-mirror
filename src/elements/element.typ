#import "@preview/cetz:0.3.2": draw, coordinate, matrix, vector
#import "ports.typ": add-ports, add-port
#import "../util.typ"

#let find-port(ports, id) = {
  for (side, side-ports) in ports {
    for (i, port) in side-ports.enumerate() {
      if port.id == id {
        return (side, i)
      }
    }
  }
  panic("Could not find port with id " + str(id))
}

#let local-to-global(origin, u, v, points) = {
  return points-real = points.map(p => {
    let (pu, pv) = p
    return vector.add(
      origin,
      vector.add(
        vector.scale(u, pu),
        vector.scale(v, pv)
      )
    )
  })
}

#let default-draw-shape(elmt, bounds) = {
  return ({}, bounds)
}

#let default-pre-process(elements, element) = {
  return elements
}

#let resolve-offset(ctx, offset, from, axis) = {
  let (ctx, pos) = coordinate.resolve(
    ctx,
    (rel: offset, to: from)
  )
  return pos.at(axis)
}

#let resolve-align(ctx, elmt, align, with, axis) = {
  let (align-side, i) = find-port(elmt.ports, align)
  let margins = (0%, 0%)
  if align-side in elmt.ports-margins {
    margins = elmt.ports-margins.at(align-side)
  }

  let parallel-sides = (
    ("north", "south"),
    ("west", "east")
  ).at(axis)

  let ortho-sides = (
    ("west", "east"),
    ("north", "south")
  ).at(axis)

  let dl
  let start-margin
  let len = elmt.size.at(axis)
  if align-side in parallel-sides {
    let used-pct = 100% - margins.at(0) - margins.at(1)
    let used-len = len * used-pct / 100%
    start-margin = len * margins.at(0) / 100%
    
    dl = used-len * (i + 1) / (elmt.ports.at(align-side).len() + 1)

    if not elmt.auto-ports {
      start-margin = 0
      dl = elmt.ports-pos.at(with)(len)
    }
  } else if align-side == ortho-sides.first() {
    dl = 0
    start-margin = 0
  } else {
    dl = len
    start-margin = 0
  }

  if axis == 1 {
    dl = len - dl
  }
  
  let (ctx, with-pos) = coordinate.resolve(ctx, with)
  return with-pos.at(axis) - dl + start-margin
}

#let resolve-coordinate(ctx, elmt, coord, axis) = {
  if type(coord) == dictionary {
    let offset = coord.at("offset", default: none)
    let from = coord.at("from", default: none)
    let align = coord.at("align", default: none)
    let with = coord.at("with", default: none)

    if none not in (offset, from) {
      if type(offset) != array {
        let a = (0, 0)
        a.at(axis) = offset
        offset = a
      }
      return resolve-offset(ctx, offset, from, axis)
      
    } else if none not in (align, with) {
      return resolve-align(ctx, elmt, align, with, axis)
    } else {
      panic("Dictionnary must either provide both 'offset' and 'from', or 'align' and 'with'")
    }
  }
  if type(coord) not in (int, float, length) {
    panic("Invalid " + "xy".at(axis) + " coordinate: " + repr(coord))
  }
  return coord
}

#let make-bounds(x, y, w, h) = {
  let w2 = w / 2
  let h2 = h / 2
  
  return (
    bl: (x, y),
    tl: (x, y + h),
    tr: (x + w, y + h),
    br: (x + w, y),
    center: (x + w2, y + h2),
    b: (x + w2, y),
    t: (x + w2, y + h),
    l: (x, y + h2),
    r: (x + w, y + h2),
  )
}

#let render(draw-shape, elmt) = draw.group(name: elmt.id, ctx => {
  let width = elmt.size.first()
  let height = elmt.size.last()

  let x = elmt.pos.first()
  let y = elmt.pos.last()

  x = resolve-coordinate(ctx, elmt, x, 0)
  y = resolve-coordinate(ctx, elmt, y, 1)

  let bounds = make-bounds(x, y, width, height)

  // Workaround because CeTZ needs to have all draw functions in the body
  let func = {}
  (func, bounds) = draw-shape(elmt, bounds)
  func

  if elmt.name != none {
    draw.content(
      (name: elmt.id, anchor: elmt.name-anchor),
      anchor: if elmt.name-anchor in util.valid-anchors {elmt.name-anchor} else {"center"},
      padding: 0.5em,
      align(center)[*#elmt.name*]
    )
  }

  if elmt.auto-ports {
    add-ports(
      elmt.id,
      bounds,
      elmt.ports,
      elmt.ports-margins,
      debug: elmt.debug.ports
    )
  }
})

/// Draws an element
/// - draw-shape (function): Draw function
/// - x (number, dictionary): The x position (bottom-left corner).
///
///   If it is a dictionary, it should be in the format `(rel: number, to: str)`, where `rel` is the offset and `to` the base anchor
/// - y (number, dictionary): The y position (bottom-left corner).
///
///   If it is a dictionary, it should be in the format `(from: str, to: str)`, where `from` is the base anchor and `to` is the id of the port to align with the anchor
/// - w (number): Width of the element
/// - h (number): Height of the element
/// - name (none, str): Optional name of the block
/// - name-anchor (str): Anchor for the optional name
/// - ports (dictionary): Dictionary of ports. The keys are cardinal directions ("north", "east", "south" and/or "west"). The values are arrays of ports (dictionaries) with the following fields:
///   - `id` (`str`): (Required) Port id
///   - `name` (`str`): Optional name displayed *in* the block
///   - `clock` (`bool`): Whether it is a clock port (triangle symbol)
///   - `vertical` (`bool`): Whether the name should be drawn vertically
/// - ports-margins (dictionary): Dictionary of ports margins (used with automatic port placement). They keys are cardinal directions ("north", "east", "south", "west"). The values are tuples of (`<start>`, `<end>`) margins (numbers)
/// - fill (none, color): Fill color
/// - stroke (stroke): Border stroke
/// - id (str): The block id (for future reference)
/// - auto-ports (bool): Whether to use auto port placements or not. If false, `draw-shape` is responsible for adding the appropiate ports
/// - ports-y (dictionary): Dictionary of the ports y offsets (used with `auto-ports: false`)
/// - debug (dictionary): Dictionary of debug options.
///
///   Supported fields include:
///     - `ports`: if true, shows dots on all ports of the element
#let elmt(
  draw-shape: default-draw-shape,
  pre-process: default-pre-process,
  pos: (0, 0),
  size: (1, 1),
  name: none,
  name-anchor: "center",
  ports: (:),
  ports-margins: (:),
  fill: none,
  stroke: black + 1pt,
  id: "",
  auto-ports: true,
  ports-y: (:),
  debug: (
    ports: false
  )
) = {
  for (key, side-ports) in ports.pairs() {
    if type(side-ports) == str {
      side-ports = ((id: side-ports),)
    } else if type(side-ports) == dictionary {
      side-ports = (side-ports,)
    }

    for (i, port) in side-ports.enumerate() {
      if type(port) == array {
        side-ports.at(i) = (
          id: port.at(0, default: ""),
          name: port.at(1, default: "")
        )
      } else if type(port) == str {
        side-ports.at(i) = (id: port)
      }
    }
    ports.at(key) = side-ports
  }


  return ((
    id: id,
    draw: render.with(draw-shape),
    pre-process: pre-process,
    pos: pos,
    size: size,
    name: name,
    name-anchor: name-anchor,
    ports: ports,
    ports-margins: ports-margins,
    fill: fill,
    stroke: stroke,
    auto-ports: auto-ports,
    ports-y: ports-y,
    debug: debug
  ),)
}
