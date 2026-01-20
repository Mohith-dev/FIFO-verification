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


  class FIFO_bringup_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_bringup_sequence)

    function new(string name = "FIFO_bringup_sequence");
      super.new(name);
    endfunction

    task body();

      FIFO_seq_item test_seq;
      test_seq = FIFO_seq_item::type_id::create("test_seq");
      `uvm_info("BRINGUP", "Starting bringup phase of the workflow", UVM_NONE)

      // Reset
      repeat (3) begin
        start_item(test_seq);
        test_seq.rst_n   = 0;
        test_seq.wr_en   = 0;
        test_seq.rd_en   = 0;
        test_seq.data_in = 0;
        finish_item(test_seq);
      end

      // Deassert reset
      start_item(test_seq);
      test_seq.rst_n = 1;
      test_seq.wr_en = 0;
      test_seq.rd_en = 0;
      finish_item(test_seq);


      //writing 
      start_item(test_seq);
      test_seq.rst_n   = 1;
      test_seq.wr_en   = 1;
      test_seq.rd_en   = 0;
      test_seq.data_in = $urandom();
      finish_item(test_seq);

      //reading
      start_item(test_seq);
      test_seq.rst_n = 1;
      test_seq.wr_en = 0;
      test_seq.rd_en = 1;
      finish_item(test_seq);
      `uvm_info("BRINGUP", "Bringup phase of the workflow has ended", UVM_NONE)
    endtask


  endclass


  class FIFO_full_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_full_sequence)

    FIFO_seq_item seq_item;

    function new(string name = "FIFO_full_sequence");
      super.new(name);
    endfunction

    task body();
      // reset first
      seq_item = FIFO_seq_item::type_id::create("seq_item");
      // you dont have to create new transaction item after every finish , you can just rewrite the values 
      start_item(seq_item);
      seq_item.rst_n = 0;
      finish_item(seq_item);

      // releasing the reset
      start_item(seq_item);
      seq_item.rst_n = 1;
      seq_item.wr_en = 0;
      seq_item.rd_en = 0;
      finish_item(seq_item);


      // Fill up the fifo 
      repeat (FIFO_DEPTH) begin
        start_item(seq_item);
        seq_item.wr_en   = 1;
        seq_item.rd_en   = 0;
        seq_item.rst_n   = 1;
        // assert(seq_item.randomize());
        seq_item.data_in = $urandom();
        finish_item(seq_item);
      end

      // try to fill one more

      start_item(seq_item);
      seq_item.wr_en   = 1;
      seq_item.rd_en   = 0;
      seq_item.rst_n   = 1;
      seq_item.data_in = $urandom();
      finish_item(seq_item);
    endtask

  endclass

  class FIFO_empty_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_empty_sequence)

    function new(string name = "FIFO_empty_sequence");
      super.new(name);
    endfunction

    task body();
      FIFO_seq_item item;
      item = FIFO_seq_item::type_id::create("item");

      // Reset
      repeat (3) begin
        start_item(item);
        item.rst_n   = 0;
        item.wr_en   = 0;
        item.rd_en   = 0;
        item.data_in = 0;
        finish_item(item);
      end

      // Deassert reset
      start_item(item);
      item.rst_n = 1;
      item.wr_en = 0;
      item.rd_en = 0;
      finish_item(item);

      // Read from empty → underflow + empty
      start_item(item);
      item.rst_n = 1;
      item.wr_en = 0;
      item.rd_en = 1;
      finish_item(item);
    endtask
  endclass

  class FIFO_almost_empty_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_almost_empty_sequence)

    function new(string name = "FIFO_almost_empty_sequence");
      super.new(name);
    endfunction

    task body();
      FIFO_seq_item item;
      item = FIFO_seq_item::type_id::create("item");

      // Reset
      repeat (3) begin
        start_item(item);
        item.rst_n = 0;
        item.wr_en = 0;
        item.rd_en = 0;
        finish_item(item);
      end

      // Deassert
      start_item(item);
      item.rst_n = 1;
      item.wr_en = 0;
      item.rd_en = 0;
      finish_item(item);

      // Write 2 entries
      repeat (2) begin
        start_item(item);
        item.rst_n   = 1;
        item.wr_en   = 1;
        item.rd_en   = 0;
        item.data_in = $urandom();
        finish_item(item);
      end

      // Read once → almost empty should assert
      start_item(item);
      item.rst_n = 1;
      item.wr_en = 0;
      item.rd_en = 1;
      finish_item(item);
    endtask
  endclass

  class FIFO_overflow_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_overflow_sequence)

    function new(string name = "FIFO_overflow_sequence");
      super.new(name);
    endfunction

    task body();
      FIFO_seq_item item;
      item = FIFO_seq_item::type_id::create("item");

      // Reset
      repeat (3) begin
        start_item(item);
        item.rst_n = 0;
        item.wr_en = 0;
        item.rd_en = 0;
        finish_item(item);
      end

      // Deassert
      start_item(item);
      item.rst_n = 1;
      item.wr_en = 0;
      item.rd_en = 0;
      finish_item(item);

      // Fill FIFO
      repeat (FIFO_DEPTH) begin
        start_item(item);
        item.rst_n   = 1;
        item.wr_en   = 1;
        item.rd_en   = 0;
        item.data_in = $urandom();
        finish_item(item);
      end

      // Extra write → overflow
      start_item(item);
      item.rst_n   = 1;
      item.wr_en   = 1;
      item.rd_en   = 0;
      item.data_in = $urandom();
      finish_item(item);
    endtask
  endclass

  class FIFO_underflow_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_underflow_sequence)

    function new(string name = "FIFO_underflow_sequence");
      super.new(name);
    endfunction

    task body();
      FIFO_seq_item item;
      item = FIFO_seq_item::type_id::create("item");

      // Reset
      repeat (3) begin
        start_item(item);
        item.rst_n = 0;
        item.wr_en = 0;
        item.rd_en = 0;
        finish_item(item);
      end

      // Deassert
      start_item(item);
      item.rst_n = 1;
      item.wr_en = 0;
      item.rd_en = 0;
      finish_item(item);

      // Read from empty → underflow
      start_item(item);
      item.rst_n = 1;
      item.wr_en = 0;
      item.rd_en = 1;
      finish_item(item);
    endtask
  endclass

  class FIFO_almost_full_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_almost_full_sequence)

    function new(string name = "FIFO_almost_full_sequence");
      super.new(name);
    endfunction

    task body();
      FIFO_seq_item item;
      item = FIFO_seq_item::type_id::create("item");

      // Reset
      repeat (3) begin
        start_item(item);
        item.rst_n = 0;
        item.wr_en = 0;
        item.rd_en = 0;
        finish_item(item);
      end

      // Deassert
      start_item(item);
      item.rst_n = 1;
      item.wr_en = 0;
      item.rd_en = 0;
      finish_item(item);

      // Fill FIFO to depth-1
      repeat (FIFO_DEPTH - 1) begin
        start_item(item);
        item.rst_n   = 1;
        item.wr_en   = 1;
        item.rd_en   = 0;
        item.data_in = $urandom();
        finish_item(item);
      end
      // almostfull must assert here
    endtask
  endclass

  class FIFO_stress_sequence extends uvm_sequence #(FIFO_seq_item);
    `uvm_object_utils(FIFO_stress_sequence)

    function new(string name = "FIFO_stress_sequence");
      super.new(name);
    endfunction

    task body();
      FIFO_seq_item test_item;
      test_item = FIFO_seq_item::type_id::create("test_item");

      // reset the fifo 

      repeat (3) begin
        start_item(test_item);
        test_item.rst_n = 0;
        test_item.wr_en = 1;
        test_item.rd_en = 0;
        finish_item(test_item);

        // deassert teh reset and push ideal transaction 

        start_item(test_item);
        test_item.rst_n   = 1;
        test_item.rd_en   = 0;
        test_item.wr_en   = 0;
        test_item.data_in = 0;
        finish_item(test_item);

        // random traffic

        repeat (1000) begin
          start_item(test_item);
          assert (test_item.randomize());
          finish_item(test_item);
        end

      end
    endtask
  endclass



endpackage

