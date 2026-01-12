import uvm_pkg::*;
import FIFO_test_pkg::*;
`include "uvm_macros.svh"

module FIFO_top();
    bit clk;
    always #5 clk = ~clk;
    FIFO_if FIFOif (clk);
    //FIFOif and dut are the instance names 
    FIFO dut (FIFOif);
    bind FIFO FIFO_SVA assert_inst (FIFOif);

    initial begin
        // uvm_config_db stores a virtual interface handle in the UVM hierarchy, not the real interface itself.
        // the first arugment tells where do we start searching , the second arguemtn who does this apply to ?
        uvm_config_db #(virtual FIFO_if)::set(null, "uvm_test_top", "FIFO_IF", FIFOif);
        run_test("FIFO_full_test");
    end
endmodule