#import "/src/cetz.typ": draw
#import "element.typ"
#import "ports.typ": add-port
#import "../util.typ"

#let draw-shape(elmt, bounds) = {
  let ratio = elmt.l-ratio / 100%
  let tl2 = util.lerp(bounds.bl, elmt.l-ratio, bounds.tl)
  let bounds2 = element.complete-bounds(elmt, (
    tl: tl2,
    tr: bounds.tr,
    br: bounds.br,
    bl: bounds.bl,
  ))

  let f = draw.line(
    bounds2.tl, bounds2.tr, bounds2.br, bounds2.bl,
    fill: elmt.fill,
    stroke: elmt.stroke,
    close: true
  )
  return (f, bounds2)
}

/// Draws a bit extender
///
/// #examples.extender
/// For other parameters description, see #doc-ref("element.elmt")
/// - h-ratio (ratio): The height ratio of the left side relative to the full height
/// - align-out (bool): If true, the output and input ports are aligned, otherwise, the output port is centered on the right side
#let extender(
  l-ratio: 75%,
  align-out: true,
  ..args
) = {
  let ports = (
    west: ((id: "in"),),
    east: ((id: "out"),)
  )
  let out-pct = if align-out {l-ratio / 2} else {50%}
  let ports-pos = (
    "east": (l, i) => {l - l * (out-pct / 100%)}
  )
  
  return element.elmt(
    cls: "extender",
    draw-shape: draw-shape,
    ports: ports,
    ports-pos: ports-pos,
    extra: (
      l-ratio: l-ratio,
      align-out: align-out
    ),
    ..args
  )
}