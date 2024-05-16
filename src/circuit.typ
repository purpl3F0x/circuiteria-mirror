#import "@preview/cetz:0.2.2": canvas

#let circuit(body, length: 2em) = {
  set text(font: "Source Sans 3")
  canvas(length: length, body)
}