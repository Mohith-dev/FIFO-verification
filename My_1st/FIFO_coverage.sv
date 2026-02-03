package FIFO_coverage_pkg;
  import uvm_pkg::*;
  import FIFO_seq_item_pkg::*;
  `include "uvm_macros.svh"
  class FIFO_coverage extends uvm_component;

    `uvm_component_utils(FIFO_coverage)

    uvm_analysis_export #(FIFO_seq_item) cov_export;
    uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;
    FIFO_seq_item seq_item_cov;

    covergroup cg_full;
      cp_full: coverpoint seq_item_cov.full {
        bins not_full = {0}; bins full = {1}; bins to_full = (0 => 1); bins from_full = (1 => 0);
      }

      cp_level: coverpoint seq_item_cov.level {
        bins low = {[0 : FIFO_DEPTH - 2]};
        bins almostfull = {FIFO_DEPTH - 1};
        bins full = {FIFO_DEPTH};
      }

      cx_full_level : cross cp_full, cp_level{
        illegal_bins bad_full = binsof (cp_full.full) && !binsof (cp_level.full);
      }

      cx_full_write_overflow : cross seq_item_cov.full, seq_item_cov.wr_en, seq_item_cov.overflow;

      cx_full_read : cross seq_item_cov.rd_en, seq_item_cov.full;


    endgroup : cg_full

    covergroup cg_empty;

      cp_empty: coverpoint seq_item_cov.empty {
        bins empty = {1};
        bins not_empty = {0};

        bins to_empty = (0 => 1);
        bins from_empty = (1 => 0);
      }

      cp_level: coverpoint seq_item_cov.level {
        bins empty = {0}; bins almostempty = {1}; bins high = {[2 : FIFO_DEPTH]};
      }

      cx_empty_level : cross cp_empty, cp_level{
        illegal_bins bad_empty = binsof (cp_empty.empty) && !binsof (cp_level.empty);
      }

      cx_empty_read_underflow : cross seq_item_cov.empty,seq_item_cov.rd_en, seq_item_cov.underflow;

      cx_empty_write : cross seq_item_cov.empty, seq_item_cov.wr_en;


    endgroup : cg_empty

    covergroup cg_almostfull;

      // flag state + transitions
      cp_almostfull: coverpoint seq_item_cov.almostfull {
        bins not_af = {0}; bins af = {1}; bins to_af = (0 => 1); bins from_af = (1 => 0);
      }

      // occupancy bins
      cp_level: coverpoint seq_item_cov.level {
        bins low = {[0 : FIFO_DEPTH - 3]};
        bins almostfull = {FIFO_DEPTH - 1};
        bins full = {FIFO_DEPTH};
      }

      // correctness: AF must only assert at DEPTH-1
      cx_af_level: cross cp_almostfull, cp_level{
        illegal_bins bad_af = binsof (cp_almostfull.af) && !binsof (cp_level.almostfull);
      }

      // write when almost full (should go full next)
      cx_af_write: cross seq_item_cov.almostfull, seq_item_cov.wr_en, seq_item_cov.full;

    endgroup : cg_almostfull

    covergroup cg_almostempty;

      cp_almostempty: coverpoint seq_item_cov.almostempty {
        bins not_ae = {0}; bins ae = {1}; bins to_ae = (0 => 1); bins from_ae = (1 => 0);
      }

      cp_level: coverpoint seq_item_cov.level {
        bins empty = {0}; bins almostempty = {1}; bins higher = {[2 : FIFO_DEPTH]};
      }

      cx_ae_level: cross cp_almostempty, cp_level{
        illegal_bins bad_ae = binsof (cp_almostempty.ae) && !binsof (cp_level.almostempty);
      }

      // read at almost empty -> should go empty
      cx_ae_read: cross seq_item_cov.almostempty, seq_item_cov.rd_en, seq_item_cov.empty;

      // write at almost empty -> should move away from boundary
      cx_ae_write: cross seq_item_cov.almostempty, seq_item_cov.wr_en;

    endgroup


    covergroup cg_overflow;

      cp_overflow: coverpoint seq_item_cov.overflow {
        bins no_of = {0}; bins of = {1}; bins to_overflow = (0 => 1);
      }

      cp_full: coverpoint seq_item_cov.full {bins not_full = {0}; bins full = {1};}

      cp_wr: coverpoint seq_item_cov.wr_en {bins wr0 = {0}; bins wr1 = {1};}

    // Overflow correctness — MUST only happen when write + full
          cx_overflow_correct: cross cp_overflow, cp_full, cp_wr {
      illegal_bins bad_overflow =
        binsof(cp_overflow.of)
        with !(cp_full.full && cp_wr.wr1);
    }


    endgroup


    covergroup cg_underflow;

      cp_underflow: coverpoint seq_item_cov.underflow {
        bins no_uf = {0}; bins uf = {1}; bins to_underflow = (0 => 1);
      }

      cp_empty: coverpoint seq_item_cov.empty {bins not_empty = {0}; bins empty = {1};}

      cp_rd: coverpoint seq_item_cov.rd_en {bins rd0 = {0}; bins rd1 = {1};}

//     correctness check
    cx_underflow_correct: cross cp_underflow, cp_empty, cp_rd{
      illegal_bins bad_underflow =
      binsof(cp_underflow.uf) &&
     !(binsof(cp_empty.empty) && binsof(cp_rd.rd1));
    }

    endgroup


    covergroup cg_wr_ack;

      cp_ack: coverpoint seq_item_cov.wr_ack {
        bins no_ack = {0}; bins ack = {1}; bins to_ack = (0 => 1);
      }

      cp_full: coverpoint seq_item_cov.full {bins not_full = {0}; bins full = {1};}

      cp_wr: coverpoint seq_item_cov.wr_en {bins wr0 = {0}; bins wr1 = {1};}

      // correctness — ack must not assert when full
      cx_ack_correct: cross cp_ack, cp_full, cp_wr{
        illegal_bins bad_ack = binsof (cp_ack.ack) && binsof (cp_full.full);
      }

    endgroup

    function new(string name = "FIFO_coverage", uvm_component parent = null);
      super.new(name, parent);
      cg_full = new();
      cg_empty = new();
      cg_overflow = new();
      cg_underflow = new();
      cg_almostempty = new();
      cg_almostfull = new();
      cg_wr_ack = new();
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      cov_export = new("cov_export", this);
      cov_fifo   = new("cov_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      cov_export.connect(cov_fifo.analysis_export);
    endfunction


    task run_phase(uvm_phase phase);
      super.run_phase(phase);

      forever begin
        cov_fifo.get(seq_item_cov);
        cg_full.sample();
        cg_empty.sample();
        cg_overflow.sample();
        cg_underflow.sample();
        cg_almostempty.sample();
        cg_almostfull.sample();
        cg_wr_ack.sample();
      end


    endtask


  endclass


endpackage
