package FIFO_scoreboard_pkg;

  import uvm_pkg::*;
  import FIFO_seq_item_pkg::*;
  `include "uvm_macros.svh"

  parameter FIFO_WIDTH = 8;
  parameter FIFO_DEPTH = 16;

  class FIFO_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(FIFO_scoreboard)

    // TLM connections
    uvm_analysis_export #(FIFO_seq_item) sb_export;
    uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
    FIFO_seq_item seq_item_sb;

    logic [5:0] level;

    // ------------------------------
    // Reference model (DATA FIFO)
    // ------------------------------
    bit [FIFO_WIDTH-1:0] ref_fifo[$];  // queue of data, NOT sequence items
    bit [FIFO_WIDTH-1:0] data_out_ref;

    int error_count;
    int correct_count;

    function new(string name = "FIFO_scoreboard", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sb_export     = new("sb_export", this);
      sb_fifo       = new("sb_fifo", this);
      correct_count = 0;
      error_count   = 0;
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      sb_export.connect(sb_fifo.analysis_export);
    endfunction

    // ------------------------------
    // Reference model
    // ------------------------------
    task ref_model();

  // RESET
  if (!seq_item_sb.rst_n) begin
    ref_fifo.delete();
    data_out_ref = '0;
    return;
  end

  // Decode operation
  case ({seq_item_sb.wr_en, seq_item_sb.rd_en})

    2'b10: begin // WRITE only
      if (ref_fifo.size() < FIFO_DEPTH) begin
        ref_fifo.push_back(seq_item_sb.data_in);
      end
    end

    2'b01: begin // READ only
      if (ref_fifo.size() > 0) begin
        data_out_ref = ref_fifo.pop_front();
      end
    end

    2'b11: begin // BOTH asserted
      if (ref_fifo.size() == 0) begin
        // EMPTY → behave like write
        ref_fifo.push_back(seq_item_sb.data_in);
      end
      else if (ref_fifo.size() == FIFO_DEPTH) begin
        // FULL → behave like read
        data_out_ref = ref_fifo.pop_front();
      end
      else begin
        // NORMAL → read and write, count unchanged
        data_out_ref = ref_fifo.pop_front();
        ref_fifo.push_back(seq_item_sb.data_in);
      end
    end

    default: begin
      // 2'b00 → do nothing
    end

  endcase

endtask

    task level_calculator();
      if (!seq_item_sb.rst_n) level = 0;
      else begin
        if ((seq_item_sb.rd_en && level == 0) || (seq_item_sb.wr_en && level == 15) || (seq_item_sb.wr_en == 0) && (seq_item_sb.rd_en==0)) begin
          level = level;
        end else if (seq_item_sb.wr_en) level++;

        else if (seq_item_sb.rd_en) level--;

        else begin
          `uvm_info("SCOREBOARD", "ERROR with level_calculator", UVM_NONE)
        end
      end


    endtask

    // ------------------------------
    // Checker
    // ------------------------------
    task check_data();
      ref_model();
      level_calculator();
      if(!seq_item_sb.rst_n)begin
        correct_count++;
      end
      // checking the write
      else if ((({seq_item_sb.wr_en, seq_item_sb.rd_en}) == 2'b10) || ({seq_item_sb.wr_en,seq_item_sb.rd_en}==2'b11) && level == 0 ) begin
        `uvm_info("SCOREBOARD", "checking in write", UVM_NONE)
        if (seq_item_sb.wr_ack) begin
          `uvm_info("SCOREBOARD", "Write transaction is successful", UVM_NONE)
          correct_count++;
        end else if (level == FIFO_DEPTH - 1) begin
          `uvm_info("SCOREBOARD", "Write transaction is successful reached the depth", UVM_NONE)
          correct_count++;
        end else begin
          `uvm_fatal("SCOREBOARD", "Write transaction failed")
          error_count++;
        end
      end
      else if ((({seq_item_sb.wr_en, seq_item_sb.rd_en}) == 2'b01) || ({seq_item_sb.wr_en,seq_item_sb.rd_en}==2'b11) && level == FIFO_DEPTH-1) begin
        `uvm_info("SCOREBOARD", "checking in read", UVM_NONE)
        if (seq_item_sb.data_out == data_out_ref) begin
          `uvm_info("scoreboard", "data match", UVM_NONE)
          correct_count++;
        end
        else if(level == 0)begin
          `uvm_info("SCOREBOARD","READ transaction has been invoked at empty",UVM_NONE)
        end else begin
          `uvm_fatal("scoreboard", "data mismatch")
          error_count++;
        end
      end else begin
        if (({seq_item_sb.wr_en, seq_item_sb.rd_en} == 2'b11)) begin
          if ((seq_item_sb.wr_ack) && (seq_item_sb.data_out == data_out_ref)) begin
            `uvm_info("SCOREBOARD", "BOTH THE OPERATIONS WERE PERFORMED", UVM_NONE)
            correct_count++;
          end else begin
            `uvm_fatal("DOUBLE_OPERATION", "error at double operation")
            error_count++;
          end
        end
      end

    endtask

    // ------------------------------
    // Run phase
    // ------------------------------
    task run_phase(uvm_phase phase);
      super.run_phase(phase);

      forever begin
        sb_fifo.get(seq_item_sb);
        `uvm_info("Scoreboard",
                  "------------------------------------------------------------------", UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf(
                  " \nlevel is %0d\n Received seq_item:\n%s data_out_ref :%0h ",
                  level,
                  seq_item_sb.convert2string(),
                  data_out_ref
                  ), UVM_NONE)



        check_data();
        `uvm_info("SCOREBOARD", "TRANSACTION CHECK COMPLETED", UVM_NONE)
      end
    endtask


    // ------------------------------
    // Report
    // ------------------------------
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("REPORT", $sformatf("Total successful transactions : %0d", correct_count),
                UVM_MEDIUM)
      `uvm_info("REPORT", $sformatf("Total failed transactions     : %0d", error_count), UVM_MEDIUM)
    endfunction

  endclass

endpackage

// forever begin
//           @(posedge seq_item_sb.clk or negedge seq_item_sb.rst_n)

//           if (!seq_item_sb.rst_n) level = 0;
//           else begin

//             if(((({seq_item_sb.wr_en,seq_item_sb.rd_en}) == 2'b10) && !seq_item_sb.full) || ((({seq_item_sb.wr_en,seq_item_sb.rd_en}) == 2'b11) && seq_item_sb.empty))
//               level++;

//             else if (((({seq_item_sb.wr_en,seq_item_sb.rd_en}) == 2'b01) && !seq_item_sb.empty) || ((({seq_item_sb.wr_en,seq_item_sb.rd_en}) == 2'b11) && seq_item_sb.full))
//               level--;

//             else begin
//             end
//           end
//         end
