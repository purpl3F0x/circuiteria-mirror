#import "@preview/cetz:0.3.2": draw
#import "element.typ"

#let draw-shape(elmt, bounds) = {
  let f = draw.rect(
    radius: 0.5em,
    inset: 0.5em,
    fill: elmt.fill,
    stroke: elmt.stroke,
    bounds.bl, bounds.tr
  )
  return (f, bounds)
}

/// Draws a block element
///
/// #examples.block
/// For parameters description, see #doc-ref("element.elmt")
#let block(
  ..args
) = element.elmt(
  draw-shape: draw-shape,
  ..args
)