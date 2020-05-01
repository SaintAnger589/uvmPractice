//this class contains apb_config, apb agent and apb_env

`ifndef APB_AGENT_ENV_CFG__SV
`deinf APB_AGENT_ENV_CFG__SV

//-----------------------
// APB config class
//-----------------------

class apb_config extends uvm_object;

  `uvm_config_utils(apb_config)
  virtual apb_if vif;

  function new(string name="apb_config");
    super.new(name);
  endfunction

  endclass

  class apb_agent extends uvm_agent;

    apb_sequencer sqr;
    apb_master_drv drv;
    apb_monitor mon;

    virtual apb_if vif;

    `uvm_component_utils_begin(apb_agent)
      `uvm_field_object(sqr, UVM_ALL_ON)
      `uvm_field_object(drv, UVM_ALL_ON)
      `uvm_field_object(mon, UVM_ALL_ON)
    `uvm_component_utils_end

    function new (string name, uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      sqr = apb_sequencer::type_id::create(this, "sqr", "vif", vif);
      drv = apb_master_drv::type_id::create(this, "drv", "vif", vif);
      mon = apb_monitor::type_id::create(this, "mon", "vif", vif);

      if (!uvm_config_db#(virtual apb_if)::set(this, "", "vif", vif)) begin
        `uvm_fatal("APB", "No virtual interface found for sequencer");
      end

      uvm_config_db#(virtual apb_if)::set(this, "sqr", "vif", vif);
      uvm_config_db#(virtual apb_if)::set(this, "drv", "vif", vif);
      uvm_config_db#(virtual apb_if)::set(this, "mon", "vif", vif);
    endfunction: build_phase

    //connect  - driver and sequencer together
    virtual function void connect_phase(uvm_phase phase);
      drv.seq_iterm_port.connect(sqr.seq_item_export);
    endfunction
  endclass
