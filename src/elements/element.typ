#import "@preview/cetz:0.2.2": draw, coordinate
#import "ports.typ": add-ports, add-port

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

#let default-draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  return ({}, tl, tr, br, bl)
}

#let elmt(
  draw-shape: default-draw-shape,
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  ports: (),
  ports-margins: (),
  fill: none,
  stroke: black + 1pt,
  id: "",
  auto-ports: true,
  ports-y: (),
  debug: (
    grid: false,
    ports: false
  )
) = draw.get-ctx(ctx => {
  let width = w
  let height = h

  let x = x
  let y = y
  if x == none { panic("Parameter x must be set") }
  if y == none { panic("Parameter y must be set") }
  if w == none { panic("Parameter w must be set") }
  if h == none { panic("Parameter h must be set") }

  if (type(x) == dictionary) {
    let offset = x.rel
    let to = x.to
    let (ctx, to-pos) = coordinate.resolve(ctx, (rel: (offset, 0), to: to))
    x = to-pos.at(0)
  }
  
  if (type(y) == dictionary) {
    let from = y.from
    let to = y.to
    let (to-side, i) = find-port(ports, to)
    let margins = (0%, 0%)
    if to-side in ports-margins {
      margins = ports-margins.at(to-side)
    }
    let used-pct = 100% - margins.at(0) - margins.at(1)
    let used-height = height * used-pct / 100%
    let top-margin = height * margins.at(0) / 100%
    
    let dy = used-height * (i + 1) / (ports.at(to-side).len() + 1)

    if not auto-ports {
      top-margin = 0
      dy = ports-y.at(to)(height)
    }
    
    let (ctx, from-pos) = coordinate.resolve(ctx, from)
    y = from-pos.at(1) + dy - height + top-margin
  }

  let tl = (x, y + height)
  let tr = (x + width, y + height)
  let br = (x + width, y)
  let bl = (x, y)

  // Workaround because CeTZ needs to have all draw functions in the body
  let func = {}
  (func, tl, tr, br, bl) = draw-shape(id, tl, tr, br, bl, fill, stroke)
  func

  if (name != none) {
    draw.content(
      (name: id, anchor: name-anchor),
      anchor: name-anchor,
      padding: 0.5em,
      align(center)[*#name*]
    )
  }

  if auto-ports {
    add-ports(
      id,
      tl, tr, br, bl,
      ports,
      ports-margins,
      debug: debug.ports
    )
  }
})