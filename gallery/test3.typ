#import "@preview/cetz:0.2.2": draw
#import "../src/lib.typ": circuit, element, util, wire

#set page(width: auto, height: auto, margin: .5cm)

#circuit({
  element.block(
    x: 0, y: 0, w: 2, h: 3, id: "block",
    name: "Test",
    ports: (
      east: (
        (id: "out0"),
        (id: "out1"),
        (id: "out2"),
      )
    )
  )
  element.gate-and(
    x: 4, y: 0, w: 2, h: 2, id: "and1",
    inverted: ("in1")
  )
  element.gate-or(
    x: 7, y: 0, w: 2, h: 2, id: "or1",
    inverted: ("in0", "out")
  )

  wire.wire(
    "w1",
    ("block-port-out0", "and1-port-in0"),
    style: "dodge",
    dodge-y: 3,
    dodge-margins: (20%, 20%)
  )
  wire.wire(
    "w2",
    ("block-port-out1", "and1-port-in1"),
    style: "zigzag"
  )
  wire.wire(
    "w3",
    ("and1-port-out", "or1-port-in0")
  )

  element.gate-and(
    x: 11, y: 0, w: 2, h: 2, id: "and2", inputs: 3,
    inverted: ("in0", "in2")
  )
  for i in range(3) {
    wire.stub("and2-port-in"+str(i), "west")
  }

  element.gate-xor(
    x: 14, y: 0, w: 2, h: 2, id: "xor",
    inverted: ("in1")
  )
  
  element.gate-buf(
    x: 0, y: -3, w: 2, h: 2, id: "buf"
  )
  element.gate-not(
    x: 0, y: -6, w: 2, h: 2, id: "not"
  )
  
  element.gate-and(
    x: 3, y: -3, w: 2, h: 2, id: "and"
  )
  element.gate-nand(
    x: 3, y: -6, w: 2, h: 2, id: "nand"
  )
  
  element.gate-or(
    x: 6, y: -3, w: 2, h: 2, id: "or"
  )
  element.gate-nor(
    x: 6, y: -6, w: 2, h: 2, id: "nor"
  )
  
  element.gate-xor(
    x: 9, y: -3, w: 2, h: 2, id: "xor"
  )
  element.gate-xnor(
    x: 9, y: -6, w: 2, h: 2, id: "xnor"
  )

  element.resistor(
    x: 0, y: -8, w: 2, h: 0.5, id: "res1"
  )

  element.capacitor(
    x: 3, y: (from: "res1-port-1", to: "0"),
    w: 2, h: 0.6,
    id: "cap1",
    scales: (100%, 80%),
    symbols: ([+], [-])
  )

  element.resistor(
    x: (rel: 1, to: "cap1-port-1"),
    y: (from: "cap1-port-1", to: "0"),
    w: 0.5, h: 2,
    id: "res2",
    vertical: true,
    zigzags: 8
  )

  element.capacitor(
    x: (rel: 1, to: "res2.east"),
    y: (from: "res2-port-1", to: "1"),
    w: 0.5, h: 2,
    id: "cap2",
    vertical: true,
    symbols: ([a], [b])
  )

  element.resistor(
    x: (rel: 1, to: "cap2-port-0"),
    y: (from: "cap2-port-0", to: "0"),
    w: 2, h: 0.5,
    id: "res3",
    zigzags: none
  )

  element.resistor(
    x: (rel: 1, to: "res3-port-1"),
    y: (from: "res3-port-1", to: "0"),
    w: 0.5, h: 2,
    id: "res4",
    zigzags: none,
    vertical: true
  )

  wire.wire("w4", ("res1-port-1", "cap1-port-0"))
  wire.wire("w5", ("cap1-port-1", "res2-port-0"))
  wire.wire("w6", ("res2-port-1", "cap2-port-1"))
  wire.wire("w7", ("cap2-port-0", "res3-port-0"))
  wire.wire("w8", ("res3-port-1", "res4-port-0"))
})