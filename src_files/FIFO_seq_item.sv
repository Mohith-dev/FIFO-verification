package FIFO_seq_item_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;

parameter FIFO_WIDTH = 8;
parameter FIFO_DEPTH = 16;

// sequence item is the transaction objects that gets passed between the uvm compnoents 
// all the classes that you write to do the funcitonal verification using uvm , you will divide them into two classes , like uvm_object and uvm_component 
// some classes are for giving the strucutre to testbench , some for transaction 
// uvm is methodology and library for enforcing discipline  
// the “standard verification methodology” is a set of rules about how you build verification testbench
class FIFO_seq_item extends uvm_sequence_item; // derived class 

`uvm_object_utils(FIFO_seq_item)
// By registering a class with the UVM factory, any instance of that class created through the factory can be overridden or substituted with another derived class, without changing the original code.

// variables
rand bit [FIFO_WIDTH-1:0] data_in;
rand bit rst_n,wr_en,rd_en;
bit [FIFO_WIDTH-1:0] data_out;
bit wr_ack;
bit overflow,underflow,almostfull,almostempty,full,empty;
int level;


int RD_EN_ON_DIST;
int WR_EN_ON_DIST;

// every time i create an instance of this class , the constructor gets invoked ,
// we are doing to this intilaise the objects state 
function new(input string name = "FIFO_seq_item",int RD_EN_ON_DIST = 30, int WR_EN_ON_DIST = 70);
super.new(name);
this.RD_EN_ON_DIST = RD_EN_ON_DIST;
this.WR_EN_ON_DIST = WR_EN_ON_DIST;
endfunction: new


 // Group: Functions
        function string convert2string();
          string s;
          s = super.convert2string();
          return $sformatf("%s data_in = 0b%0b, rst_n = 0b%0b, wr_en = 0b%0b, rd_en = 0b%0b, data_out = 0b%0b, wr_ack = 0b%0b, overflow = 0b%0b, full = 0b%0b, empty = 0b%0b, almostfull = 0b%0b, almostempty = 0b%0b, underflow = 0b%0b", 
              s, data_in, rst_n, wr_en, rd_en, data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow);
        endfunction: convert2string
      
        
        function string convert2string_stimulus();
          return $sformatf("data_in = 0b%0b, rst_n = 0b%0b, wr_en = 0b%0b, rd_en = 0b%0b, data_out = 0b%0b, wr_ack = 0b%0b, overflow = 0b%0b, full = 0b%0b, empty = 0b%0b, almostfull = 0b%0b, almostempty = 0b%0b, underflow = 0b%0b", 
              data_in, rst_n, wr_en, rd_en, data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow);
        endfunction: convert2string_stimulus   
// constaints

//reset constraint

constraint rest_con{
    rst_n dist{
      0:/ 10,
      1:/ 90
    };
}

// write_en constraint

constraint wr_en_const{
     wr_en dist{
       1:/ WR_EN_ON_DIST,
       0:/ (100- WR_EN_ON_DIST)
     };
}


// read_en constraint

constraint rd_en_const{
    rd_en dist{
      1:/ RD_EN_ON_DIST,
      0:/ (100-RD_EN_ON_DIST)
    };
}


endclass: FIFO_seq_item

endpackage