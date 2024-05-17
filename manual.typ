#import "@preview/tidy:0.3.0"
#import "@preview/cetz:0.2.2": draw, canvas
#import "src/lib.typ"
#import "doc/examples.typ"
#import "src/circuit.typ": circuit
#import "src/element.typ"
#import "src/util.typ"
#import "src/wire.typ"

#set heading(numbering: (..num) => if num.pos().len() < 4 {
  numbering("1.1", ..num)
})
#{
  outline(indent: true, depth: 3)
}
#set page(numbering: "1/1", header: align(right)[circuiteria #sym.dash.em v#lib.version])
#show link: set text(blue)
#show heading.where(level: 3): it => context {
  let cnt = counter(heading)
  let i = cnt.get().at(it.depth) - 1
  let color = util.colors.values().at(i)
  block(width: 100%)[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      align: horizon,
      it,
      {
        place(horizon)[
          #line(
            start: (0%, 0%),
            end: (100%, 0%),
            stroke: color + 1pt
          )
        ]
        place(horizon)[
          #circle(radius: 3pt, stroke: none, fill: color)
        ]
        place(horizon+right)[
          #circle(radius: 3pt, stroke: none, fill: color)
        ]
      }
    )
  ]
}

= Introduction

This package provides a way to make beautiful block circuit diagrams using the CeTZ package.

= Usage

Simply import #link("src/lib.typ") and call the `circuit` function:
#pad(left: 1em)[```typ
#import "src/lib.typ"
#lib.circuit({
  import lib: *
  ...
})
```]

= Reference

#let circuit-docs = tidy.parse-module(
  read("src/circuit.typ"),
  name: "circuit",
  require-all-parameters: true
)
#tidy.show-module(circuit-docs)

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
  scope: (
    wire: wire,
    circuit: circuit,
    draw: draw,
    examples: examples
  )
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
  require-all-parameters: true,
  scope: (
    element: element,
    circuit: circuit,
    draw: draw,
    wire: wire,
    tidy: tidy,
    examples: examples
  )
)

#tidy.show-module(element-docs, sort-functions: false)