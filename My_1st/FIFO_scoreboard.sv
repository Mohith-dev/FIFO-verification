package FIFO_scoreboard_pkg;

import uvm_pkg::*;
import FIFO_seq_item_pkg::*;
`include "uvm_macros.svh"

parameter FIFO_WIDTH = 8;
parameter FIFO_DEPTH = 16;

class FIFO_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(FIFO_scoreboard)

  // TLM connections
  uvm_analysis_export #(FIFO_seq_item)        sb_export;
  uvm_tlm_analysis_fifo #(FIFO_seq_item)     sb_fifo;
  FIFO_seq_item                              seq_item_sb;

  // ------------------------------
  // Reference model (DATA FIFO)
  // ------------------------------
  bit [FIFO_WIDTH-1:0] ref_fifo[$];   // queue of data, NOT sequence items
  bit [FIFO_WIDTH-1:0] data_out_ref;

  int error_count;
  int correct_count;

  function new(string name="FIFO_scoreboard", uvm_component parent=null);
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

    // RESET behavior
    if (!seq_item_sb.rst_n) begin
      ref_fifo.delete();
      data_out_ref = '0;
      return;
    end

    // WRITE
    if (seq_item_sb.wr_en && ref_fifo.size() < FIFO_DEPTH) begin
      ref_fifo.push_back(seq_item_sb.data_in);
    end

    // READ
    if (seq_item_sb.rd_en && ref_fifo.size() > 0) begin
      data_out_ref = ref_fifo.pop_front();
    end

  endtask

  // ------------------------------
  // Checker
  // ------------------------------
  task check_data();
    ref_model();

    if (seq_item_sb.data_out !== data_out_ref) begin
      `uvm_error("SCOREBOARD",
        $sformatf("DATA MISMATCH: Expected = %0h, Got = %0h",
                  data_out_ref, seq_item_sb.data_out))
      error_count++;
    end
    else begin
      `uvm_info("SCOREBOARD",
        $sformatf("DATA MATCH: %0h at time %0t", data_out_ref, $time),
        UVM_HIGH)
      correct_count++;
    end
  endtask

  // ------------------------------
  // Run phase
  // ------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      sb_fifo.get(seq_item_sb);
      check_data();
    end
  endtask

  // ------------------------------
  // Report
  // ------------------------------
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("REPORT",
      $sformatf("Total successful transactions : %0d", correct_count),
      UVM_MEDIUM)
    `uvm_info("REPORT",
      $sformatf("Total failed transactions     : %0d", error_count),
      UVM_MEDIUM)
  endfunction

endclass

endpackage
