//--------------------------
// Top level test module
// include all env component and sequence files
//---------------------------

import uvm_pkg::*;
`include "uvm_macros.svh"

//Include all files
`include "apb_if.svh"
`include "apb_rw.svh"
`include "apb_driver_seq_mon.svh"
`inlcude "apb_agent_env_config.svh"
`include "apb_sequences.svh"
`include "apb_test.svh"

//----------------------------
//top level module that instantiates just a physical
//apb interface
//----------------------------
module test;
  logic pclk;
  logic [31:0] paddr;
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [31:0] prdata;
  logic [31:0] pwdata;

  initial begin
    #10 pclk = ~pclk;
  end

  //instantiates a physical interface for apb interface
  apb_if apb_if(.pclk(pclk));

  initial begin
    //pass the physical interface to test top
    //which will further pass it down to env->agent->drv/seq/mon
    uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top", "vif", apb_if);

    run_test();
  end
endmodule
