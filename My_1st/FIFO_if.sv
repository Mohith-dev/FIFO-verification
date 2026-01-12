
interface FIFO_if(input clk);
// its just a container that hold the signals to say simply 
// what does instantitate interface mean ? 
//“Create a real instance of this interface in the design.”

/* Interface is a shared communication object that can contain:
it is hardware construct 
signals

timing

tasks

assertions

clocking blocks

modports
*/

parameter FIFO_WIDTH = 8;
parameter FIFO_DEPTH = 16;

// input signals
logic [FIFO_WIDTH-1:0] data_in;
logic rst_n,wr_en,rd_en;

// output signals
logic[FIFO_WIDTH-1:0] data_out;
logic overflow,underflow,empty,full;
logic almostfull,almostempty,wr_ack;

// the modport helps in enforcing directionality of the ports , Prevent illegal signal driving across components
modport DUT (
    // “From the DUT’s point of view, these are inputs, those are outputs.”
input clk,data_in,rst_n,wr_en,rd_en,
output data_out,overflow,underflow,empty,full,almostempty,almostfull,wr_ack
);



endinterface