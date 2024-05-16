#import "@preview/cetz:0.2.2": canvas, draw, coordinate, vector

#set text(font: "Source Sans Pro")
#set page(flipped: true)

#let diag-colors = (
  orange: rgb(245, 180, 147),
  yellow: rgb(250, 225, 127),
  green: rgb(127, 200, 172),
  pink: rgb(236, 127, 178),
  purple: rgb(189, 151, 255)
)

#let lpad(s, len) = {
  let res = "0" * len + s
  return res.slice(-len)
}

#let opposite-anchor(anchor) = {
  return (
    north: "south",
    east: "west",
    south: "north",
    west: "east",

    north-west: "south-east",
    north-east: "south-west",
    south-east: "north-west",
    south-west: "north-east"
  ).at(anchor)
}

#let diag-port-stub(port-id, side, name: none, vertical: false, length: 1em) = {
  
  let offset = (
    north: (0, length),
    east: (length, 0),
    south: (0, -length),
    west: (-length, 0)
  ).at(side)
  draw.line(
    port-id,
    (rel: offset, to: port-id)
  )
  if name != none {
    let text-anchor = if vertical {
      (
        "north": "west",
        "south": "east",
        "west": "south",
        "east": "north"
      ).at(side)
    } else { opposite-anchor(side) }
    draw.content(
      anchor: text-anchor,
      padding: 0.2em,
      angle: if vertical {90deg} else {0deg},
      (rel: offset, to: port-id),
      name
    )
  }
}

#let diag-port(
  elmt-id,
  side,
  port,
  pos,
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
    
    let offset
    if (side == "north") {
      offset = (0, -1em)
    } else if (side == "east") {
      offset = (-1em, 0)
    } else if (side == "south") {
      offset = (0, 1em)
    } else if (side == "west") {
      offset = (1em, 0)
    }
    let pos1 = (rel: offset, to: pos)

    // TODO: use context or vectors to have the height relative to the width
    draw.line(
      prev, pos1, next
    )
  }
  draw.content(
    pos,
    anchor: if name-rotate {
      (
        "north": "east",
        "south": "west",
        "west": "north",
        "east": "south"
      ).at(side)
    } else {side},
    padding: 2pt,
    angle: if name-rotate {90deg} else {0deg},
    name
  )
  if debug {
    draw.circle(
      pos,
      name: elmt-id + "-port-" + port.at("id"),
      radius: .1,
      stroke: none,
      fill: red
    )
    
  } else {
    draw.hide(draw.circle(
      pos,
      radius: 0,
      stroke: none,
      name: elmt-id + "-port-" + port.at("id")
    ))
  }
}

#let diag-ports(
  elmt-id,
  tl, tr, br, bl,
  ports,
  ports-margins,
  debug: false
) = {
  let sides = (
    "north": (tl, tr),
    "east": (tr, br),
    "south": (bl, br),
    "west": (tl, bl)
  )
  for (side, props) in sides {
    let side-ports = ports.at(side, default: ())
    for (i, port) in side-ports.enumerate() {
      let pct = (i + 1) * 100% / (side-ports.len() + 1)
      let pt0 = props.at(0)
      let pt1 = props.at(1)

      if side in ports-margins {
        let (a, b) = (pt0, pt1)
        let margins = ports-margins.at(side)
        a = (pt0, margins.at(0), pt1)
        b = (pt0, 100% - margins.at(1), pt1)
        pt0 = a
        pt1 = b
      }
      
      let pos = (pt0, pct, pt1)

      let pct-prev = (i + 0.5) * 100% / (side-ports.len() + 1)
      let pct-next = (i + 1.5) * 100% / (side-ports.len() + 1)
      let pos-prev = (pt0, pct-prev, pt1)
      let pos-next = (pt0, pct-next, pt1)
      diag-port(
        elmt-id,
        side,
        port,
        pos,
        prev: pos-prev,
        next: pos-next,
        debug: debug
      )
      /*
      
      let name = port.at("name", default: "")
      let name-rotate = port.at("vertical", default: false)

      if (port.at("clock", default: false)) {
        let pct-prev = (i + 0.5) * 100% / (side-ports.len() + 1)
        let pct-next = (i + 1.5) * 100% / (side-ports.len() + 1)
        let pos0 = (pt0, pct-prev, pt1)
        let offset
        if (side == "north") {
          offset = (0, -1em)
        } else if (side == "east") {
          offset = (-1em, 0)
        } else if (side == "south") {
          offset = (0, 1em)
        } else if (side == "west") {
          offset = (1em, 0)
        }
        let pos1 = (rel: offset, to: pos)
        let pos2 = (pt0, pct-next, pt1)

        // TODO: use context or vectors to have the height relative to the width
        draw.line(
          pos0, pos1, pos2
        )
      }
      draw.content(
        pos,
        anchor: if name-rotate {
          (
            "north": "east",
            "south": "west",
            "west": "north",
            "east": "south"
          ).at(side)
        } else {side},
        padding: 2pt,
        angle: if name-rotate {90deg} else {0deg},
        name
      )
      if debug {
        draw.circle(
          pos,
          name: elmt-id + "-port-" + port.at("id"),
          radius: .1,
          stroke: none,
          fill: red
        )
        
      } else {
        draw.hide(draw.circle(
          pos,
          radius: 0,
          stroke: none,
          name: elmt-id + "-port-" + port.at("id")
        ))
      }*/
    }
  }
}

#let diag-find-port(ports, id) = {
  for (side, side-ports) in ports {
    for (i, port) in side-ports.enumerate() {
      if port.id == id {
        return (side, i)
      }
    }
  }
  panic("Could not find port with id " + str(id))
}

#let diag-elmt(
  appearance: "rect",
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-pos: "center",
  ports: (),
  ports-margins: (),
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    grid: false,
    ports: false
  )
) = draw.get-ctx(ctx => {
  let width = w
  let height = h

  let y = y
  if x == none { panic("Parameter x must be set") }
  if y == none { panic("Parameter y must be set") }
  if w == none { panic("Parameter w must be set") }
  if h == none { panic("Parameter h must be set") }

  if (type(y) == dictionary) {
    let from = y.from
    let to = y.to
    let (to-side, i) = diag-find-port(ports, to)
    let margins = (0%, 0%)
    if to-side in ports-margins {
      margins = ports-margins.at(to-side)
    }
    let used-pct = 100% - margins.at(0) - margins.at(1)
    let used-height = height * used-pct / 100%
    let top-margin = height * margins.at(0) / 100%
    
    let dy = used-height * (i + 1) / (ports.at(to-side).len() + 1)

    if appearance == "alu" {
      top-margin = 0
      if to == "in1" {
        dy = height * 0.225
      } else if to == "in2" {
        dy = height * 0.775
      }
    }
    
    let (ctx, from-pos) = coordinate.resolve(ctx, from)
    y = from-pos.at(1) + dy - height + top-margin
  }

  let tl = (x, y + height)
  let tr = (x + width, y + height)
  let br = (x + width, y)
  let bl = (x, y)

  if appearance == "rect" {
    draw.rect(
      radius: 0.5em,
      inset: 0.5em,
      fill: fill,
      stroke: stroke,
      name: id,
      bl, tr
    )
  } else if appearance == "multiplexer" {
    let tr2 = (tr, 20%, br)
    let br2 = (tr, 80%, br)
    draw.group(name: id, {
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
  
  } else if appearance == "extender" {
    tl = (x, y + height * 0.75)
    let tr2 = (x + width, y + height * 0.75)
    let br = (x + width, y)
    (tr, tr2) = (tr2, tr)
    draw.group(name: id, {
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
  } else if appearance == "alu" {
    let p0 = tl
    let p1 = (tr, 10%, br)
    let p2 = (tr, 90%, br)
    let p3 = bl
    let p4 = (tl, 55%, bl)
    let p5 = (tl, 50%, br)
    let p6 = (tl, 45%, bl)
    
    draw.group(name: id, {
      
      draw.merge-path(
        inset: 0.5em,
        fill: fill,
        stroke: stroke,
        close: true,
        draw.line(p0, p1, p2, p3, p4, p5, p6)
      )
      draw.anchor("north", (p0, 50%, p1))
      draw.anchor("south", (p2, 50%, p3))
      draw.anchor("west", (p0, 50%, p3))
      draw.anchor("east", (p1, 50%, p2))
    })

    diag-port(id, "west", (id: "in1"), (p0, 50%, p6))
    diag-port(id, "west", (id: "in2"), (p3, 50%, p4))
    diag-port(id, "east", (id: "out"), (p1, 50%, p2))
  }
  /*draw.for-each-anchor(id, (name) => {
    draw.circle(id + "." + name, radius: .1, fill: red)
  })*/

  if (name != none) {
    let block-anchor = "center"
    let name-anchor = "center"
    if (name-pos == "top") {
      block-anchor = "north"
      name-anchor = "north"
    } else if (name-pos == "bottom") {
      block-anchor = "south"
      name-anchor = "south"
    } else if (name-pos == "left") {
      block-anchor = "west"
      name-anchor = "west"
    } else if (name-pos == "right") {
      block-anchor = "east"
      name-anchor = "east"
    }
    draw.content(
      (name: id, anchor: block-anchor),
      anchor: name-anchor,
      padding: 0.5em,
      align(center)[*#name*]
    )

  }
  if appearance != "alu" {
    diag-ports(
      id,
      tl, tr, br, bl,
      ports,
      ports-margins,
      debug: debug.ports
    )
  }
})

#let diag-block(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-pos: "center",
  ports: (),
  ports-margins: (),
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    grid: false,
    ports: false
  )
) = diag-elmt(
  appearance: "rect",
  x: x,
  y: y,
  w: w,
  h: h,
  name: name,
  name-pos: name-pos,
  ports: ports,
  ports-margins: ports-margins,
  fill: fill,
  stroke: stroke,
  id: id,
  debug: debug
)

#let diag-multiplexer(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-pos: "center",
  entries: 2,
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    grid: false,
    ports: false
  )
) = {
  let ports = ()

  if (type(entries) == int) {
    let nbits = calc.ceil(calc.log(entries, base: 2))
    for i in range(entries) {
      let bits = lpad(str(i, base: 2), nbits)
      ports.push((id: "in" + str(i), name: bits))
    }
  }
  
  diag-elmt(
    appearance: "multiplexer",
    x: x,
    y: y,
    w: w,
    h: h,
    name: name,
    name-pos: name-pos,
    ports: (west: ports, east: ((id: "out"),)),
    fill: fill,
    stroke: stroke,
    id: id,
    debug: debug
  )
}

#let diag-extender(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-pos: "center",
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    grid: false,
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
  
  diag-elmt(
    appearance: "extender",
    x: x,
    y: y,
    w: w,
    h: h,
    name: name,
    name-pos: name-pos,
    ports: ports,
    fill: fill,
    stroke: stroke,
    id: id,
    debug: debug
  )
}

#let diag-alu(
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-pos: "center",
  fill: none,
  stroke: black + 1pt,
  id: "",
  debug: (
    grid: false,
    ports: false
  )
) = {
  let ports = (
    west: (
      (id: "in1"),
      (id: "in2"),
    ),
    east: (
      (id: "out"),
    )
  )
  
  diag-elmt(
    appearance: "alu",
    x: x,
    y: y,
    w: w,
    h: h,
    name: name,
    name-pos: name-pos,
    ports: ports,
    fill: fill,
    stroke: stroke,
    id: id,
    debug: debug
  )
}

#let diag-wire(
  id,
  pts,
  bus: false,
  name: none,
  name-pos: "middle",
  slice: none,
  color: black,
  dashed: false,
  style: "direct",
  reverse: false,
  zigzag-ratio: 50%,
  dodge-y: 0,
  dodge-sides: ("east", "west"),
  dodge-margins: (5%, 5%)
) = draw.get-ctx(ctx => {
  let styles = (
    "direct",
    "zigzag",
    "dodge"
  )
  if not style in styles {
    panic("Invalid wire style '" + style + "'")
  }
  if pts.len() != 2 {
    panic("Wrong number of points for style '" + style + "' (got " + str(pts.len()) + " instead of 2)")
  }
  
  let stroke = (paint: color, thickness: if bus {1.5pt} else {1pt})
  if dashed {
    stroke.insert("dash", "dashed")
  }

  let points = ()
  let anchors = ()

  if style == "direct" {
    points = pts
    anchors = (
      "start": points.first(),
      "end": points.last()
    )
    
  } else if style == "zigzag" {
    let start = pts.at(0)
    let end = pts.at(1)
    let mid = (start, zigzag-ratio, end)

    points = (
      start,
      (horizontal: mid, vertical: ()),
      (horizontal: (), vertical: end),
      end
    )
    anchors = (
      "start": points.first(),
      "zig": points.at(1),
      "zag": points.at(1),
      "end": points.last()
    )
    
  } else if style == "dodge" {
    let start = pts.at(0)
    let end = pts.at(1)
    let p1 = (start, dodge-margins.at(0), end)
    let p2 = (end, dodge-margins.at(1), start)
    
    let (ctx, p0) = coordinate.resolve(ctx, start)
    let (ctx, p3) = coordinate.resolve(ctx, end)
    p0 = (x: p0.at(0), y: p0.at(1))
    p3 = (x: p3.at(0), y: p3.at(1))
    let (margin-start, margin-end) = dodge-margins
    let (side-start, side-end) = dodge-sides

    let dx1 = margin-start
    let dx2 = margin-end
    
    if type(margin-start) == ratio {
      dx1 = calc.abs(p3.x - p0.x) * margin-start / 100%
    }
    if type(margin-end) == ratio {
      dx2 = calc.abs(p3.x - p0.x) * margin-end / 100%
    }
    if side-start == "west" {
      dx1 *= -1
    }
    if side-end == "east" {
      dx2 *= -1
    }
    p1 = (p0.x + dx1, p0.y)
    p2 = (p3.x - dx2, p0.y)

    points = (
      start,
      (horizontal: p1, vertical: ()),
      (horizontal: (), vertical: (0, dodge-y)),
      (horizontal: p2, vertical: ()),
      (horizontal: (), vertical: end),
      end
    )
    anchors = (
      "start": start,
      "start2": points.at(1),
      "dodge-start": points.at(2),
      "dodge-end": points.at(3),
      "end2": points.at(4),
      "end": end
    )
  }

  draw.group(name: id, {
    draw.line(..points, stroke: stroke)
    for (anchor-name, anchor-pos) in anchors {
      draw.anchor(anchor-name, anchor-pos)
    }
  })

  let first-pt = id + ".start"
  let last-pt = id + ".end"
  if reverse {
    (first-pt, last-pt) = (last-pt, first-pt)
  }
  
  if name != none {
    let names = ()
    
    if type(name) == str {
      names = ((name, name-pos),)
      
    } else if type(name) == array {
      names = (
        (name.at(0), "start"),
        (name.at(1), "end")
      )
    }

    for (name, pos) in names {
      let point
      let anchor
      
      if pos == "middle" {
        point = (first-pt, 50%, last-pt)
        anchor = "south"
      } else if pos == "start" {
        point = first-pt
        anchor = "south-west"
      } else if pos == "end" {
        point = last-pt
        anchor = "south-east"
      }
      draw.content(point, anchor: anchor, padding: 3pt, name)
    }
  }
  if slice != none {
    let slice-txt = "[" + str(slice.first()) + ":" + str(slice.last()) + "]"
    
    draw.content(
      first-pt,
      anchor: "south-west",
      padding: 3pt,
      text(slice-txt, size: 0.75em)
    )
  }
})

#let diag-intersection(pt) = {
  draw.circle(pt, radius: .2, stroke: none, fill: black)
}

#context {
  canvas(length: 2em, {
    diag-block(
      x: 0, y: 0, w: 1.5, h: 2.2,
      id: "PC-buf",
      fill: diag-colors.orange,
      ports: (
        west: (
          (id: "PCNext"),
        ),
        north: (
          (id: "CLK", clock: true),
        ),
        east: (
          (id: "PC"),
        ),
        south: (
          (id: "EN", name: "EN"),
        )
      )
    )
    diag-port-stub("PC-buf-port-CLK", "north", name: "CLK")
    diag-port-stub("PC-buf-port-EN", "south", name: "PCWrite")
    
    diag-multiplexer(
      x: 3, y: (from: "PC-buf-port-PC", to: "in0"), w: 1, h: 2,
      id: "AdrSrc-MP",
      fill: diag-colors.orange,
      entries: 2
    )
    diag-wire(
      "wPCBuf-InstDataMgr", (
        "PC-buf-port-PC",
        "AdrSrc-MP-port-in0"
      ),
      name: "PC",
      bus: true
    )
    diag-port-stub("AdrSrc-MP.north", "north", name: "AdrSrc")
    
    diag-block(
      x: 6, y: (from: "AdrSrc-MP-port-out", to: "A"), w: 3, h: 4,
      id: "InstDataMgr",
      fill: diag-colors.yellow,
      ports: (
        west: (
          (id: "A", name: "A"),
          (id: "WD", name: "WD")
        ),
        north: (
          (id: "CLK", clock: true),
          (id: "WE", name: "WE", vertical: true),
          (id: "IRWrite", name: "IRWrite", vertical: true)
        ),
        east: (
          (id: "Instr", name: "Instr."),
          (id: "RD", name: "RD")
        )
      ),
      ports-margins: (
        west: (30%, 0%),
        east: (40%, 0%)
      )
    )
    diag-wire(
      "wAdrSrcMP-InstDataMgr", (
        "AdrSrc-MP-port-out",
        "InstDataMgr-port-A"
      ),
      name: "Addr",
      name-pos: "end",
      bus: true
    )
    
    diag-port-stub("InstDataMgr-port-CLK", "north", name: "CLK")
    diag-port-stub("InstDataMgr-port-WE", "north")
    diag-port-stub("InstDataMgr-port-IRWrite", "north")
    diag-port-stub("InstDataMgr-port-WD", "west")

    diag-block(
      x: 15, y: (from: "InstDataMgr-port-RD", to: "WD3"), w: 3, h: 4,
      id: "RegFile",
      fill: diag-colors.pink,
      ports: (
        west: (
          (id: "A1", name: "A1"),
          (id: "A2", name: "A2"),
          (id: "A3", name: "A3"),
          (id: "WD3", name: "WD3"),
        ),
        north: (
          (id: "CLK", clock: true),
          (id: "WE3", name: "WE3", vertical: true)
        ),
        east: (
          (id: "RD1", name: "RD1"),
          (id: "RD2", name: "RD2"),
        )
      ),
      ports-margins: (
        east: (20%, 20%)
      )
    )
    diag-port-stub("RegFile-port-CLK", "north", name: "CLK")
    diag-port-stub("RegFile-port-WE3", "north", name: "Regwrite", vertical: true)
    diag-port-stub("RegFile-port-A2", "west")
    diag-port-stub("RegFile-port-RD2", "east")

    diag-extender(
      x: 15, y: -3.5, w: 3, h: 1,
      id: "Extender",
      fill: diag-colors.green
    )
    diag-wire(
      "wExtender-ImmSrc", (
        "Extender.north",
        (18, -2)
      ),
      style: "zigzag",
      zigzag-ratio: 0%,
      name: "ImmSrc",
      name-pos: "end",
      bus: true
    )

    let mid = ("InstDataMgr.east", 50%, "RegFile.west")
    diag-wire(
      "wInstDataMgr-Bus", (
        "InstDataMgr-port-Instr",
        (vertical: (), horizontal: mid)
      ),
      name: "Instr",
      name-pos: "start",
      bus: true
    )
    diag-wire(
      "wBus", (
        (v => (v.at(0), -3.5), mid),
        (horizontal: (), vertical: (0, 3.5)),
      ),
      bus: true
    )
    diag-wire(
      "wBus-RegFile-A1", (
        "RegFile-port-A1",
        (horizontal: mid, vertical: ()),
      ),
      name: "RS1",
      name-pos: "end",
      slice: (19, 15),
      reverse: true,
      bus: true
    )
    diag-wire(
      "wBus-RegFile-A3", (
        "RegFile-port-A3",
        (horizontal: mid, vertical: ()),
      ),
      name: "RD",
      name-pos: "end",
      slice: (11, 7),
      reverse: true,
      bus: true
    )
    diag-wire(
      "wBus-Extender", (
        "Extender-port-in",
        (horizontal: mid, vertical: ()),
      ),
      slice: (31, 7),
      reverse: true,
      bus: true
    )

    diag-alu(
      x: 22, y: (from: "RegFile-port-RD1", to: "in1"), w: 1, h: 2,
      id: "ALU",
      fill: diag-colors.purple
    )
    diag-wire(
      "wRegFile-ALU", (
        "RegFile-port-RD1",
        "ALU-port-in1"
      ),
      name: ("A", "SrcA"),
      bus: true
    )

    diag-block(
      x: 26, y: (from: "ALU-port-out", to: "in"), w: 1.5, h: 2,
      id: "OutBuf",
      fill: diag-colors.orange,
      ports: (
        west: (
          (id: "in"),
        ),
        north: (
          (id: "CLK", clock: true),
        ),
        east: (
          (id: "out"),
        )
      )
    )
    diag-port-stub("OutBuf-port-CLK", "north", name: "CLK")
    diag-wire(
      "wALU-OutBuf", (
        "ALU-port-out",
        "OutBuf-port-in"
      ),
      name: "ALUResult",
      bus: true
    )

    diag-multiplexer(
      x: 30, y: (from: "OutBuf-port-out", to: "in0"), w: 1, h: 2.5,
      id: "Res-MP",
      fill: diag-colors.orange,
      entries: 3
    )
    diag-port-stub("Res-MP.north", "north", name: "ResultSrc")
    diag-port-stub("Res-MP-port-in2", "west")
    diag-wire(
      "wOutBuf-ResMP", (
        "OutBuf-port-out",
        "Res-MP-port-in0"
      ),
      name: "ALUOut",
      bus: true
    )

    diag-wire(
      "wExt-ALU", (
        "Extender-port-out",
        "ALU-port-in2",
      ),
      name: ("ImmExt", "SrcB"),
      bus: true,
      style: "zigzag",
      zigzag-ratio: 60%
    )

    diag-wire(
      "wInstDataMgr-ResMP", (
        "InstDataMgr-port-RD",
        "Res-MP-port-in1"
      ),
      style: "dodge",
      dodge-y: -4,
      dodge-sides: ("east", "west"),
      name: "Data",
      name-pos: "start",
      bus: true
    )

    diag-wire(
      "wResMP-AdrSrc", (
        "Res-MP-port-out",
        "AdrSrc-MP-port-in1"
      ),
      style: "dodge",
      dodge-y: -5,
      dodge-sides: ("east", "west"),
      dodge-margins: (0.5, 1),
      bus: true
    )

    diag-wire(
      "wResMP-RegFile", (
        "Res-MP-port-out",
        "RegFile-port-WD3"
      ),
      style: "dodge",
      dodge-y: -5,
      dodge-sides: ("east", "west"),
      dodge-margins: (0.5, 1),
      bus: true
    )

    diag-wire(
      "wResMP-PCBuf", (
        "Res-MP-port-out",
        "PC-buf-port-PCNext"
      ),
      style: "dodge",
      dodge-y: -5,
      dodge-sides: ("east", "west"),
      dodge-margins: (0.5, 1.5),
      name: "PCNext",
      name-pos: "end",
      bus: true
    )

    
    diag-intersection("wResMP-RegFile.dodge-end")
    diag-intersection("wResMP-AdrSrc.dodge-end")
  })
}