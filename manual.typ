#import "@preview/tidy:0.3.0"
#import "@preview/cetz:0.2.2": draw
#import "src/circuit.typ": circuit
#import "src/util.typ"
#import "src/wire.typ"

#let circuit-docs = tidy.parse-module(
  read("src/circuit.typ"),
  name: "circuit",
  require-all-parameters: true
)
#tidy.show-module(circuit-docs)

#let util-docs = tidy.parse-module(
  read("src/util.typ"),
  name: "util",
  require-all-parameters: true,
  scope: (util: util)
)
#tidy.show-module(util-docs)

#let wire-docs = tidy.parse-module(
  read("src/wire.typ"),
  name: "wire",
  require-all-parameters: true,
  scope: (wire: wire, circuit: circuit, draw: draw)
)
#tidy.show-module(wire-docs)