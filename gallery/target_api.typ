#import "../src/lib.typ": *
#import "@preview/cetz:0.3.4": draw

#set text(font: "Source Sans 3")

#circuit({
  element.block(
    size: (1.5, 2.2),
    id: "PCBuf",
    fill: util.colors.orange,
    ports: (
      west: "PCNext",
      north: (id: "CLK", clock: true),
      east: "PC",
      south: (("EN", "EN"),)
    )
  )
  
  wire.stub("PCBuf.CLK", name: "CLK")
  wire.stub("PCBuf.EN", name: "PCWrite")
  
  element.multiplexer(
    pos: (
      3, (align: "in0", with: "PCBuf.PC")
    ),
    size: (1, 2),
    id: "AdrSrc-MP",
    fill: util.colors.orange,
    entries: 2
  )
  wire.wire(
    "PCBuf.PC",
    "AdrSrc-MP.in0",
    id: "wPCBuf-InstDataMgr",
    name: "PC",
    bus: true
  )
  wire.stub("AdrSrc-MP.north", side: "north", name: "AdrSrc")
  
  element.block(
    pos: (
      6, (align: "A", with: "AdrSrc-MP.out")
    ),
    size: (3, 4),
    id: "InstDataMgr",
    fill: util.colors.yellow,
    ports: (
      west: (
        ("A", "A"),
        ("WD", "WD")
      ),
      north: (
        (id: "CLK", clock: true),
        (id: "WE", name: "WE", vertical: true),
        (id: "IRWrite", name: "IRWrite", vertical: true)
      ),
      east: (
        ("Instr", "Instr."),
        ("RD", "RD")
      )
    ),
    ports-margins: (
      west: (30%, 0%),
      east: (40%, 0%)
    )
  )
  wire.wire(
    "AdrSrc-MP.out",
    "InstDataMgr.A",
    id: "wAdrSrcMP-InstDataMgr",
    name: (none, "Adr"),
    bus: true
  )
  
  wire.stub("InstDataMgr.CLK", name: "CLK")
  wire.stub("InstDataMgr.WE")
  wire.stub("InstDataMgr.IRWrite")
  wire.stub("InstDataMgr.WD")

  element.block(
    pos: (
      15, (align: "WD3", with: "InstDataMgr.RD")
    ),
    size: (3, 4),
    id: "RegFile",
    fill: util.colors.pink,
    ports: (
      west: (
        ("A1", "A1"),
        ("A2", "A2"),
        ("A3", "A3"),
        ("WD3", "WD3"),
      ),
      north: (
        (id: "CLK", clock: true),
        (id: "WE3", name: "WE3", vertical: true)
      ),
      east: (
        ("RD1", "RD1"),
        ("RD2", "RD2"),
      )
    ),
    ports-margins: (
      east: (20%, 20%)
    )
  )
  wire.stub("RegFile.CLK", name: "CLK")
  wire.stub("RegFile.WE3", name: "Regwrite", name-offset: 0.6)
  wire.stub("RegFile.A2")
  wire.stub("RegFile.RD2")

  element.extender(
    pos: (15, -3.5),
    size: (3, 1),
    id: "Extender",
    fill: util.colors.green
  )
  wire.wire(
    "Extender.north",
    (18, -2),
    id: "wExtender-ImmSrc",
    style: "zigzag",
    zigzag-ratio: 0%,
    name: (none, "ImmSrc"),
    bus: true
  )

  
  let mid = ("InstDataMgr.east", 50%, "RegFile.west")
  wire.wire(
    "InstDataMgr.Instr",
    (vertical: (), horizontal: mid),
    id: "wInstDataMgr-Bus",
    name: ("Instr", none),
    bus: true
  )
  wire.wire(
    (v => (v.at(0), -3.5), mid),
    (horizontal: (), vertical: (0, 3.5)),
    id: "wBus",
    bus: true
  )
  wire.wire(
    "RegFile.A1",
    (horizontal: mid, vertical: ()),
    id: "wBus-RegFile-A1",
    name: (none, "RS1"),
    slice: (19, 15),
    reverse: true,
    bus: true
  )
  wire.wire(
    "RegFile.A3",
    (horizontal: mid, vertical: ()),
    id: "wBus-RegFile-A3",
    name: (none, "RD"),
    slice: (11, 7),
    reverse: true,
    bus: true
  )
  wire.wire(
    "Extender.in",
    (horizontal: mid, vertical: ()),
    id: "wBus-Extender",
    slice: (31, 7),
    reverse: true,
    bus: true
  )
  
  element.alu(
    pos: (
      22, (align: "in1", with: "RegFile.RD1")
    ),
    size: (1, 2),
    id: "ALU",
    fill: util.colors.purple
  )
  wire.wire(
    "RegFile.RD1",
    "ALU.in1",
    id: "wRegFile-ALU",
    name: ("A", "SrcA"),
    bus: true
  )
  wire.stub("ALU.north", side: "north")

  /*
  element.block(
    pos: (
      26, (align: "in", with: "ALU.out")
    ),
    size: (1.5, 2),
    id: "OutBuf",
    fill: util.colors.orange,
    ports: (
      west: "in",
      north: (id: "CLK", clock: true),
      east: "out"
    )
  )
  wire.stub("OutBuf.CLK", name: "CLK")
  wire.wire(
    "ALU.out",
    "OutBuf.in",
    id: "wALU-OutBuf"
    name: "ALUResult",
    bus: true
  )

  element.multiplexer(
    pos: (
      30, (align: "in0", with: "OutBuf.out")
    ),
    size: (1, 2.5),
    id: "Res-MP",
    fill: util.colors.orange,
    entries: 3
  )
  wire.stub("Res-MP.north", name: "ResultSrc")
  wire.stub("Res-MP.in2")
  wire.wire(
    "OutBuf.out",
    "Res-MP.in0",
    id: "wOutBuf-ResMP"
    name: "ALUOut",
    bus: true
  )

  wire.wire(
    "Extender.out",
    "ALU.in2",
    id: "wExt-ALU"
    name: ("ImmExt", "SrcB"),
    bus: true,
    style: "zigzag",
    zigzag-ratio: 60%
  )

  wire.wire(
    "InstDataMgr.RD",
    "Res-MP.in1",
    id: "wInstDataMgr-ResMP"
    style: "dodge",
    dodge-y: -4,
    dodge-sides: ("east", "west"),
    name: ("Data", none),
    bus: true
  )

  wire.wire(
    "Res-MP.out",
    "AdrSrc-MP.in1",
    id: "wResMP-AdrSrc"
    style: "dodge",
    dodge-y: -5,
    dodge-sides: ("east", "west"),
    dodge-margins: (0.5, 1),
    bus: true
  )

  wire.wire(
    "Res-MP.out",
    "RegFile.WD3",
    id: "wResMP-RegFile"
    style: "dodge",
    dodge-y: -5,
    dodge-sides: ("east", "west"),
    dodge-margins: (0.5, 1),
    bus: true
  )

  wire.wire(
    "Res-MP.out",
    "PCBuf.PCNext",
    id: "wResMP-PCBuf"
    style: "dodge",
    dodge-y: -5,
    dodge-sides: ("east", "west"),
    dodge-margins: (0.5, 1.5),
    name: (none, "PCNext"),
    bus: true
  )

  wire.intersection("wResMP-RegFile.dodge-end", radius: .2)
  wire.intersection("wResMP-AdrSrc.dodge-end", radius: .2)
  */
})