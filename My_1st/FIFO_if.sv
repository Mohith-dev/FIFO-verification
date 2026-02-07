interface FIFO_if(input clk);

parameter FIFO_WIDTH = 8;
parameter FIFO_DEPTH = 16;

// input signals
logic [FIFO_WIDTH-1:0] data_in;
logic rst_n,wr_en,rd_en;

// output signals
logic[FIFO_WIDTH-1:0] data_out;
logic overflow,underflow,empty,full;
logic almostfull,almostempty,wr_ack,rd_ack;


// driver clocking block 


clocking drv_cb @(posedge clk);
default input #1step output #0;

output wr_en;
output rd_en;
output rst_n;
output data_in;

input data_out;
input overflow,underflow,empty,full;
input almostfull,almostempty,wr_ack,rd_ack;

endclocking

clocking mon_cb @(posedge clk);




endclocking



// signal based modport 
modport DUT (

input clk,data_in,rst_n,wr_en,rd_en,
output data_out,overflow,underflow,empty,full,almostempty,almostfull,wr_ack,rd_ack

);

// This component is only allowed to access the interface through this specific access policy.”

// clocking based modport (this is behavioral modport)
/*

*/
modport Driver(clocking drv_cb);
modport Monitor(clocking mon_cb);



endinterface