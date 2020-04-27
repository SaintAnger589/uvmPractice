interface apb_if(input bit PCLK);
  parameter NUM_SLAVES = 1;
  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32;

  //output from the VIP to the slave
  logic [NUM_SLAVES-1:0] PSEL;
  logic                  PENABLE;
  logic [ADDR_WIDTH-1:0] PADDR;
  logic                  PWRITE;
  logic [DATA_WIDTH-1:0] PWDATA;

  //inputs to VIP from the slave DUTs
  wire [DATA_WIDTH-1:0] PRDATA;

  clocking master_cb @(posedge PCLK);
    output PSEL, PENABLE, PADDR, PWRITE, PWDATA;
    input PRDATA;
  endclocking: master_cb

  clocking slave_cb @(posedge PCLK);
    input PSEL, PENABLE, PADDR, PWRITE, PWDATA;
    output PRDATA;
  endclocking: slave_cb

  clocking monitor_cb @(posedge PCLK);
    input PSEL, PENABLE, PADDR, PWRITE, PWDATA, PRDATA;
  endclocking: monitor_cb

  modport master(clocking master_cb);
  modport slave(clocking slave_cb);
  modport passive(clocking monitor_cb);
endinterface
