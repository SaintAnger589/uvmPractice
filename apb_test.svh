`ifndef APB_BASE_SV_TEST
`define APB_BASE_SV_TEST

//---------------------------------
//Top level Test class that instantiates env, configures,
//and start simulation
//---------------------------------

class apb_base_test extends uvm_test;

  //Register with factory
  `uvm_component_utils(apb_base_test);

  apb_env env;
  apb_config cfg;
  virtual apb_if vif;


  function new (string name="apb_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //Build phase - construct the cfg and env class using factory
  //get the virtual interface handle from Test and then
  //set it config db for the env component

  function void build_phase(uvm_phase phase);
    cfg = apb_config::type_id::create("cfg", this);
    env = apb_env::trype_id::create("env", this);

    if (!uvm_config_db#(virtual apb_if)::get(this,"","vif", vif)) begin
      `uvm_fatal("APB/DRV/NOVIF", "No virtual interface specified for this test instance")
    end
    uvm_config_db#(virtual apb_if)::set(this,"env", "vif",vif);
  endfunction

  //Run phase - create an apb sequence and start it on apb_sequencer
  task run_phase(uvm_phase phase);
    apb_base_seq apb_seq;
    apb_seq = apb_base_seq::type_id::create("apb_seq");
    phase.raise_objection(this, "Starting apb_base_seqin main phase");
    $display("%t Starting sequence apb_seq run phaase", $time);
    apb_seq.start(env.agt.sqr);
    #100ns;
    phase.drop_objection(this, "Finished apb_seq in main phase");
  endtask: run_phase

endclass
