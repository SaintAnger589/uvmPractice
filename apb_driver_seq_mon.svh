`ifndef APB_DRV_SEQ_MON_SV
`define APB_DRV_SEQ_MON_SV

typedef apb_config;
typedef apb_agent;

//------------------------
// APB master driver class
//------------------------

class apb_master_drv extends uvm_driver #(apb_rw);

  `uvm_component_utils(apb_master_drv)
  virtual apb_if vif;
  apb_config cfg;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //build uvm_phase//get the virtual interface handle from the agent (parent)
  //or config_db
  function void build_phase(uvm_phase phase);
    apb_agent agent;
    super.build_phase(phase);
    if ($cast(agent, get_parent()) && agent != null) begin
      vif = agent.vif;
    end else begin
      if (!uvm_config_db(virtual apb_if)::get(this, "", "vif", vif)) begin
        `uvm_fatal("APB/DRV/NOTIF", "No virtual interface described in this instance")
      end
    end
  endfunction
  //Run phase
  //implement a driver-seq aoi to get an item
  //based on if it is a read/write - drive the apb interface
  //the corresponding pins
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    this.vif.master_cb.psel    <= '0;
    this.vif.master_cb.penable <= '0;

    forever begin
      apb_rw tr;
      @ (this.vif.master_cb);
      //First get an item from sequencer
      seq_item_port.get_next_item(tr);
      @ (this.vif.master_cb);
      `uvm_report_info("APB_DRIVER", $psprint("Got transaction %s", tr.convert2string()));
      //Decode the APB Command and call rather read/write function
      case (tr.apb_cmd)
        apb_rw::READ: drive_read(tr.addr, tr.data);
        apb_rw::WRITE: drive_write(tr.addr, tr.data);
      endcase

      seq_item_port.item_done();
    end
  endtask: run_phase

  virtual protected task drive_read(input bit [31:0] addr,
                                    output logic [31:0] data);
    this.vif.master_cb.paddr <= addr;
    this.vif.master_cb.pwrite    <= '0;
    this.vif.master_cb.psel      <= '1;
    @ (this.vif.master_cb);
      this.vif.master_cb.penable <= '1;
    @ (this.vif.master_cb);
    data = this.vif.master_cb.prdata;
    this.vif.master_cb.psel     <= '0;
    this.vif.master_cb.penable  <= '0;
  endtask: drive_read

  virtual protected task drive_write(input bit [31:0] addr,
                                     input logic [31:0] data);
    this.vif.master_cb.paddr <= addr;
    this.vif.master_cb.prdata = data;
    this.vif.master_cb.pwrite    <= '1;
    this.vif.master_cb.psel      <= '1;
    @ (this.vif.master_cb);
      this.vif.master_cb.penable <= '1;
    @ (this.vif.master_cb);
    this.vif.master_cb.psel     <= '0;
    this.vif.master_cb.penable  <= '0;
  endtask: drive_write

endclass : apb_master_drv

//----------------------
// APB monitor class
//---------------------
class apb_monitor extends uvm_monitor;
  virtual apb_if.passive vif;

  //analysis port - parameterized to apb_rw_transaction
  //monitor writes transactions objects to this port
  //once detected on interface
  uvm_analysis_port #(apb_rw) ap;

  //config class handle
  apb_config cfg;

  `uvm_component_utils(apb_monitor)

  function new (string name, uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction: new

  //build phase - get handle of virtua; if from agent/uvm_config_db
  virtual function void build_phase(uvm_phase phase);
    apb_agent agent;
    if ($cast(agent, get_parent()) && agent != null) begin
      vif = agent.vif;
    end else begin
      virtual apb_if tmp;
      if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_if", tmp)) begin
        `uvm_fatal("APB/MON/NOVIF", "No virtual interface specified for this monitor instance");
      end
      vif =  tmp;
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      apb_rw tr;
      //wait for setup cycle
      do begin
        @ (this.vif.monitor_cb);
      end
      while (this.vif.monitor_cb.psel !== 1'b1 ||
             this.vif.monitor_cb.penable !== 1'b0);
      //create a transaction objects
      tr = apb_rw::type_id::create("tr", this);

    end

endclass: apb_monitor
