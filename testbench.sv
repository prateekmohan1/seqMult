
//-------------------------------------------
// Top level Test module
//  Includes all env component and sequences files 
//-------------------------------------------
 import uvm_pkg::*;
`include "uvm_macros.svh"

 //Include all files

`include "seqMult_if.svh"
`include "seqMult.v"
`include "seqMult_seq.svh"
`include "apb_driver_seq_mon.svh"
`include "apb_agent_env_config.svh"
`include "apb_sequences.svh"
`include "apb_test.svh"

//--------------------------------------------------------
//Top level module that instantiates  just a physical apb interface
//No real DUT or APB slave as of now
//--------------------------------------------------------
module test;

   import uvm_pkg::*;

    //Instantiate a physical interface for APB interface here and connect the pclk input
    seqMult_if seqMultvif();
  
   initial begin
      seqMultvif.sig_clk=0;
   end

    //Generate a clock
   always begin
      forever #5 seqMultvif.sig_clk = ~seqMultvif.sig_clk;
   end
 
  //Attach VIF to actual DUT
  seqMult  my_seqMult (.a(seqMultvif.sig_a), .b(seqMultvif.sig_b), .z(seqMultvif.sig_z), .clk(seqMultvif.sig_clk), .rst(seqMultvif.sig_rst), 
						.ab_ready(seqMultvif.sig_ab_ready), .ab_valid(seqMultvif.sig_ab_valid),
						.z_valid(seqMultvif.sig_z_valid));
  
  initial begin
    //Pass above physical interface to test top
    //(which will further pass it down to env->agent->drv/sqr/mon
    uvm_config_db#(virtual seqMult_if)::set(uvm_root::get(), "uvm_test_top", "seqMultvif", seqMultvif);
  
    //Call the run_test - but passing run_test argument as test class name
    run_test("apb_base_test");

    $finish();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, test);
  end  
  
endmodule
