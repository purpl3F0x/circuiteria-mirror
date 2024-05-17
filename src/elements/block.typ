#import "@preview/cetz:0.2.2": draw
#import "element.typ"

#let draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  let f = draw.rect(
    radius: 0.5em,
    inset: 0.5em,
    fill: fill,
    stroke: stroke,
    name: id,
    bl, tr
  )
  return (f, tl, tr, br, bl)
}

/// Draws a block element
///
/// #examples.block
/// - x (number, dictionary): see #doc-ref("element.elmt")
/// - y (number, dictionary): see #doc-ref("element.elmt")
/// - w (number): see #doc-ref("element.elmt")
/// - h (number): see #doc-ref("element.elmt")
/// - name (none, str): see #doc-ref("element.elmt")
/// - name-anchor (str): see #doc-ref("element.elmt")
/// - ports (dictionary): see #doc-ref("element.elmt")
/// - ports-margins (dictionary): see #doc-ref("element.elmt")
/// - fill (none, color): see #doc-ref("element.elmt")
/// - stroke (stroke): see #doc-ref("element.elmt")
/// - id (str): see #doc-ref("element.elmt")
/// - debug (dictionary): see #doc-ref("element.elmt")
#let block(
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
  debug: (
    ports: false
  )
) = element.elmt(
  draw-shape: draw-shape,
  x: x,
  y: y,
  w: w,
  h: h,
  name: name,
  name-anchor: name-anchor,
  ports: ports,
  ports-margins: ports-margins,
  fill: fill,
  stroke: stroke,
  id: id,
  debug: debug
)