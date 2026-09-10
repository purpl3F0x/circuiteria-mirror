#import "/src/lib.typ" as circuiteria: circuit, util, verilog

#set page(width: auto, height: auto, margin: .5cm)

#circuit({
  verilog.block(
    read("axi_demo.v"),
    x: 0, y: 0,
    // fill: util.colors.yellow,
    // radius: 0.05em
  )
})
