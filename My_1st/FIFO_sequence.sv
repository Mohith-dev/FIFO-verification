package FIFO_sequence_pkg;
  import uvm_pkg::*;
  import FIFO_seq_item_pkg::*;
  `include "uvm_macros.svh"

  class FIFO_reset_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_reset_sequence)

    FIFO_seq_item seq_item;

    function new(string name = "FIFO_reset_sequence");
      super.new(name);
    endfunction : new

    task body();
      seq_item = FIFO_seq_item::type_id::create("seq_item");
      start_item(seq_item);
      seq_item.rst_n   = 0;
      seq_item.data_in = 0;
      seq_item.wr_en   = 0;
      seq_item.rd_en   = 0;
      finish_item(seq_item);
    endtask
  endclass : FIFO_reset_sequence

  class FIFO_write_only_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_write_only_sequence)

    FIFO_seq_item seq_item;

    int read_dist = 0;  // No read
    int write_dist = 100;  // Write only 

    function new(string name = "FIFO_write_only_sequence");
      super.new(name);
    endfunction : new

    task body();
      seq_item = FIFO_seq_item::type_id::create("seq_item");
      seq_item.RD_EN_ON_DIST = read_dist;
      seq_item.WR_EN_ON_DIST = write_dist;
      start_item(seq_item);
      assert (seq_item.randomize());
      finish_item(seq_item);
    endtask
  endclass : FIFO_write_only_sequence

  class FIFO_read_only_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_read_only_sequence)

    FIFO_seq_item seq_item;

    int read_dist = 100;  // No read
    int write_dist = 0;  // Write only 

    function new(string name = "FIFO_read_only_sequence");
      super.new(name);
    endfunction : new

    task body();
      seq_item = FIFO_seq_item::type_id::create("seq_item");
      seq_item.RD_EN_ON_DIST = read_dist;
      seq_item.WR_EN_ON_DIST = write_dist;
      start_item(seq_item);
      assert (seq_item.randomize());
      finish_item(seq_item);
    endtask
  endclass : FIFO_read_only_sequence

  class FIFO_write_read_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_write_read_sequence)

    FIFO_seq_item seq_item;

    function new(string name = "FIFO_write_read_sequence");
      super.new(name);
    endfunction : new

    task body();
      seq_item = FIFO_seq_item::type_id::create("seq_item");
      start_item(seq_item);
      assert (seq_item.randomize());
      finish_item(seq_item);
    endtask
  endclass : FIFO_write_read_sequence


   class FIFO_full_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_full_sequence)

    function new(string name = "FIFO_full_sequence");
      super.new(name);
    endfunction

    task body();
      FIFO_write_only_sequence fifo_write_oper;
      fifo_write_oper = FIFO_write_only_sequence::type_id::create("fifo_write_oper");
      repeat (FIFO_DEPTH) begin
        fifo_write_oper.start(m_sequencer);  // start the child sequence
      end
    endtask

  endclass
endpackage
