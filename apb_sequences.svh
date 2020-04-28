//a few flavors of apb_sequences

`ifndef APB_SEQUENCE_SV
`define APB_SEQUENCE_SV

//------------------------
// base APB sequence derived from uvm_sequence
// and parametrized with sequence item of type
// apb_rw
class apb_base_seq extends uvm_sequence#(apb_rw);
  `uvm_object_utils(apb_base_seq)

  function new(string name = "");
    super.new(name);
  endfunction

  //main body method that gets executed sequence
  //is started
  task body();
    apb_rw rw_trans;
    //create 10 random APB read/write transaction and send to driver
    repeat(10) begin
      rw_trans = apb_rw::type_id::create(.name("rw_trans"), contxt(get_full_name()));
      start_item(rw_trans);
      assert(rw_trans.ramdomize());
      finish_item(rw_trans);
    end
  endtask

endclass
