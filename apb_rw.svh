//-------------------------------
// Basic APB Read/Write Transaction class definition
// this transaction class will be used by sequences, Driver and monitors
//-------------------------------

`ifndef APB_RW_SV
`define APB_RW_SV

import uvm_pkg::*;

//apb_rw sequence item derived from base uvm_sequence_item
class apb_rw extends uvm_sequence_item;

  typedef enum {READ, WRITE} kind_e;
  rand bit [31:0] addr;
  rand logic [31:0] data;
  rand kind_e apb_cmd;

  //register with factory for dynamic creation
  `uvm_object_utils(apb_rw)

  function new(string name = "apb_rw");
    super.new(name);
  endfunction

  function string convert2string();
    return $psprintf("kind = %s addr = %0h data = %0h", apb_cmd, addr, data);
  endfunction

  endclass: apb_rw

  `endif 
