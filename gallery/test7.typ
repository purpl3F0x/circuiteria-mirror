#import "@preview/cetz:0.3.2": draw
#import "../src/lib.typ": circuit, element, util, wire

#set page(width: auto, height: auto, margin: .5cm)

#circuit({
  element.gate-iec-buf(
    x: 0,
    y: 0,
    w: 2,
    h: 2,
    id: "iec-buf",
    inputs: 1,
  )
  wire.stub("iec-buf-port-in0", "west")

  element.gate-iec-not(
    x: 3,
    y: 0,
    w: 2,
    h: 2,
    id: "iec-not",
    inputs: 1,
  )
  wire.stub("iec-not-port-in0", "west")

  element.gate-iec-and(
    id: "iec-and",
    x: 0,
    y: -3,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-and-port-in" + str(i), "west")
  }

  element.gate-iec-nand(
    id: "iec-nand",
    x: 3,
    y: -3,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-nand-port-in" + str(i), "west")
  }

  element.gate-iec-or(
    id: "iec-or",
    x: 0,
    y: -6,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-or-port-in" + str(i), "west")
  }

  element.gate-iec-nor(
    id: "iec-nor",
    x: 3,
    y: -6,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-nor-port-in" + str(i), "west")
  }

  element.gate-iec-xor(
    id: "iec-xor",
    x: 0,
    y: -9,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-xor-port-in" + str(i), "west")
  }

  element.gate-iec-nxor(
    id: "iec-nxor",
    x: 3,
    y: -9,
    w: 2,
    h: 2,
    inputs: 2,
  )
  for i in range(2) {
    wire.stub("iec-nxor-port-in" + str(i), "west")
  }
})