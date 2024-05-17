#import "@preview/tidy:0.3.0"
#import "@preview/cetz:0.2.2": draw, canvas
#import "src/circuit.typ": circuit
#import "src/element.typ"
#import "src/util.typ"
#import "src/wire.typ"

#let circuit-docs = tidy.parse-module(
  read("src/circuit.typ"),
  name: "circuit",
  require-all-parameters: true
)
#tidy.show-module(circuit-docs, style: tidy.styles.minimal)

#pagebreak()

#let util-docs = tidy.parse-module(
  read("src/util.typ"),
  name: "util",
  require-all-parameters: true,
  scope: (
    util: util,
    canvas: canvas,
    draw: draw
  )
)
#tidy.show-module(util-docs)

#pagebreak()

#let wire-docs = tidy.parse-module(
  read("src/wire.typ"),
  name: "wire",
  require-all-parameters: true,
  scope: (wire: wire, circuit: circuit, draw: draw)
)
#tidy.show-module(wire-docs)

#pagebreak()

#let element-docs = tidy.parse-module(
  read("src/elements/element.typ") + "\n" +
  read("src/elements/alu.typ") + "\n" +
  read("src/elements/block.typ") + "\n" +
  read("src/elements/extender.typ") + "\n" +
  read("src/elements/multiplexer.typ"),
  name: "element",
  require-all-parameters: false,
  scope: (
    element: element,
    circuit: circuit,
    draw: draw,
    wire: wire,
    tidy: tidy
  )
)

#tidy.show-module(element-docs, sort-functions: false)