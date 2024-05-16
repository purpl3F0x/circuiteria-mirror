#import "@preview/cetz:0.2.2": draw, coordinate
#import "util.typ": opposite-anchor

#let wire-styles = ("direct", "zigzag", "dodge")
#let signal-width = 1pt
#let bus-width = 1.5pt

#let intersection(pt) = {
  draw.circle(pt, radius: .2, stroke: none, fill: black)
}

#let get-direct-wire(pts) = {
  let anchors = (
    "start": pts.first(),
    "end": pts.last()
  )
  return (pts, anchors)
}

#let get-zigzag-wire(pts, ratio) = {
  let start = pts.first()
  let end = pts.last()
  let mid = (start, ratio, end)

  let points = (
    start,
    (horizontal: mid, vertical: ()),
    (horizontal: (), vertical: end),
    end
  )
  let anchors = (
    "start": start,
    "zig": points.at(1),
    "zag": points.at(2),
    "end": end
  )
  return (points, anchors)
}

#let get-dodge-wire(pts, dodge-y, margins, sides, ctx) = {
  let start = pts.first()
  let end = pts.last()
  let (margin-start, margin-end) = margins
  let (side-start, side-end) = sides

  let p1 = (start, margin-start, end)
  let p2 = (end, margin-end, start)
  
  let (ctx, p0) = coordinate.resolve(ctx, start)
  let (ctx, p3) = coordinate.resolve(ctx, end)
  p0 = (x: p0.first(), y: p0.last())
  p3 = (x: p3.first(), y: p3.last())

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

  let points = (
    start,
    (horizontal: p1, vertical: ()),
    (horizontal: (), vertical: (0, dodge-y)),
    (horizontal: p2, vertical: ()),
    (horizontal: (), vertical: end),
    end
  )
  let anchors = (
    "start": start,
    "start2": points.at(1),
    "dodge-start": points.at(2),
    "dodge-end": points.at(3),
    "end2": points.at(4),
    "end": end
  )

  return (points, anchors)
}

#let wire(
  id, pts,
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
  if not style in wire-styles {
    panic("Invalid wire style '" + style + "'")
  }

  if pts.len() != 2 {
    panic("Wrong number of points (got " + str(pts.len()) + " instead of 2)")
  }
  
  let stroke = (
    paint: color,
    thickness: if bus {bus-width} else {signal-width}
  )
  if dashed {
    stroke.insert("dash", "dashed")
  }

  let points = ()
  let anchors = ()

  if style == "direct" {
    (points, anchors) = get-direct-wire(pts)
    
  } else if style == "zigzag" {
    (points, anchors) = get-zigzag-wire(pts, zigzag-ratio)
    
  } else if style == "dodge" {
    (points, anchors) = get-dodge-wire(
      pts,
      dodge-y,
      dodge-margins,
      dodge-sides,
      ctx
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
    let (start, end) = slice
    let slice-txt = "[" + str(start) + ":" + str(end) + "]"
    
    draw.content(
      first-pt,
      anchor: "south-west",
      padding: 3pt,
      text(slice-txt, size: 0.75em)
    )
  }
})

#let stub(port-id, side, name: none, vertical: false, length: 1em) = {
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