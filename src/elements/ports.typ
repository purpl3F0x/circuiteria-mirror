#import "@preview/cetz:0.3.2": draw
#import "../util.typ": rotate-anchor

#let get-port-side(elmt, port) = {
  for (side, ports) in elmt.ports {
    for p in ports {
      if p.id == port {
        return side
      }
    }
  }
  panic("Unknown port " + port + " on element " + elmt.id)
}

#let get-port-idx(elmt, port, side: auto) = {
  if side == auto {
    side = get-port-side(elmt, port)
  }
  assert(
    side in elmt.ports,
    message: "No ports on side '" + side + "' of element '" + elmt.id + "'"
  )
  let i = elmt.ports.at(side).position(p => p.id == port)
  assert(
    i != none,
    message: "Could not find port '" + port + "' on side '" + side + "' of element '" + elmt.id + "'"
  )
  return i
}

#let get-port-pos(elmt, bounds, side, port, port-i) = {
  let (pt0, pt1) = bounds.ports.at(side)
  let side-len = if side in ("north", "south") {
    pt1.at(0) - pt0.at(0)
  } else {
    pt0.at(1) - pt1.at(1)
  }

  let offset = if (
    elmt.ports-pos == auto or
    elmt.ports-pos.at(side, default: auto) == auto
  ) {
    let space = 100% / (elmt.ports.at(side, default: ()).len() + 1)
    (port-i + 1) * space
  } else {
    assert(
      side in elmt.ports-pos,
      message: "Could not reliably compute port position (missing side)"
    )
    let side-pos = elmt.ports-pos.at(side)
    if type(side-pos) == function {
      (side-pos)(side-len, port-i)
    } else if type(side-pos) == array {
      (side-pos.at(i))(side-len)
    } else if type(side-pos) == dictionary {
      assert(
        port in side-pos,
        message: "Could not reliably compute port position (missing port)"
      )
      (side-pos.at(port))(side-len)
    } else {
      panic("Could not reliably compute port position (invalid type)")
    }
  }

  if type(offset) == ratio {
    offset = offset * side-len / 100%
  }
  return offset
}

#let add-port(
  elmt-id, side, port, pos,
  prev: none,
  next: none,
  debug: false
) = {
  let name = port.at("name", default: "")
  let name-rotate = port.at("vertical", default: false)

  if (port.at("clock", default: false)) {
    if prev == none or next == none {
      panic("Clock port must have previous and next positions")
    }
    
    let size = if port.at("small", default: false) {8pt} else {1em}
    let offset
    if      (side == "north") { offset = (    0, -size) }
    else if (side == "east")  { offset = (-size,     0) }
    else if (side == "south") { offset = (    0,  size) }
    else if (side == "west")  { offset = ( size,     0) }

    let pos1 = (rel: offset, to: pos)

    // TODO: use context or vectors to have the height relative to the width
    draw.line(prev, pos1, next)
  }
  draw.content(
    pos,
    anchor: if name-rotate {rotate-anchor(side)} else {side},
    padding: 2pt,
    angle: if name-rotate {90deg} else {0deg},
    name
  )

  if debug {
    draw.circle(
      pos,
      radius: .1,
      stroke: none,
      fill: red
    )
    
  } else {
    draw.hide(draw.circle(
      pos,
      radius: 0,
      stroke: none
    ))
  }
  draw.anchor(port.id, pos)
}

#let add-ports(
  elmt,
  bounds
) = {
  let debug = elmt.debug.ports

  if type(elmt.ports) != dictionary {
    return
  }

  for (side, props) in bounds.ports {
    let side-ports = elmt.ports.at(side, default: ())
    let space = 100% / (side-ports.len() + 1)
    
    let (pt0, pt1) = props
    let side-len = if side in ("north", "south") {
      pt1.at(0) - pt0.at(0)
    } else {
      pt0.at(1) - pt1.at(1)
    }
    for (i, port) in side-ports.enumerate() {
      let offset = get-port-pos(elmt, bounds, side, port, i)

      let pos = (pt0, offset, pt1)
      let offset-prev = if type(offset) == ratio {
        offset - space / 2
      } else {
        offset - space * side-len / 200%
      }
      let offset-next = if type(offset) == ratio {
        offset + space / 2
      } else {
        offset + space * side-len / 200%
      }
      let pos-prev = (pt0, offset-prev, pt1)
      let pos-next = (pt0, offset-next, pt1)

      if port.at("small", default: false) {
        pos-prev = (pos, 4pt, pt0)
        pos-next = (pos, 4pt, pt1)
      }

      add-port(
        elmt.id,
        side,
        port,
        pos,
        prev: pos-prev,
        next: pos-next,
        debug: debug
      )
    }
  }
}