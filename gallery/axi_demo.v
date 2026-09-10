`timescale 1ns / 1ps

// Simple AXI-Stream to AXI4-Lite bridge used as a demo for the Verilog parser
module axi_demo #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDR_WIDTH = 12
) (
    input  wire                      aclk,
    input  wire                      aresetn,

    // AXI4-Lite slave interface
    input  wire [ADDR_WIDTH-1:0]     s_axil_awaddr,
    input  wire [2:0]                s_axil_awprot,
    input  wire                      s_axil_awvalid,
    output wire                      s_axil_awready,
    input  wire [31:0]               s_axil_wdata,
    input  wire [3:0]                s_axil_wstrb,
    input  wire                      s_axil_wvalid,
    output wire                      s_axil_wready,
    output wire [1:0]                s_axil_bresp,
    output wire                      s_axil_bvalid,
    input  wire                      s_axil_bready,
    input  wire [ADDR_WIDTH-1:0]     s_axil_araddr,
    input  wire [2:0]                s_axil_arprot,
    input  wire                      s_axil_arvalid,
    output wire                      s_axil_arready,
    output wire [31:0]               s_axil_rdata,
    output wire [1:0]                s_axil_rresp,
    output wire                      s_axil_rvalid,
    input  wire                      s_axil_rready,

    // AXI4-Stream sink
    input  wire [63:0]               s_axis_tdata,
    input  wire [7:0]                s_axis_tkeep,
    input  wire                      s_axis_tvalid,
    output wire                      s_axis_tready,
    input  wire                      s_axis_tlast,

    // AXI4-Stream source
    output wire [63:0]               m_axis_tdata,
    output wire [7:0]                m_axis_tkeep,
    output wire                      m_axis_tvalid,
    input  wire                      m_axis_tready,
    output wire                      m_axis_tlast,

    input  wire                      enable,
    output wire [3:0]                status,
    output wire                      irq
);

endmodule
