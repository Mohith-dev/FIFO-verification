package FIFO_test_pkg;

  import uvm_pkg::*;
  import FIFO_env_pkg::*;
  import FIFO_sequence_pkg::*;
  import FIFO_config_obj_pkg::*;
  `include "uvm_macros.svh"

  class FIFO_base_test extends uvm_test;
    `uvm_component_utils(FIFO_base_test)

    FIFO_env env;
    FIFO_config_obj FIFO_cfg_test;

    function new(string name = "FIFO_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      env = FIFO_env::type_id::create("env", this);
      FIFO_cfg_test = FIFO_config_obj::type_id::create("FIFO_cfg_test");
      if (!uvm_config_db#(virtual FIFO_if)::get(this, "", "FIFO_IF", FIFO_cfg_test.FIFO_config_vif))
        `uvm_fatal(
            "build_phase",
            "Test - unable to retreive the virtual interface of the FIFO from the config_db");

      uvm_config_db#(FIFO_config_obj)::set(this, "*", "CFG", FIFO_cfg_test);
    endfunction
  endclass



  class FIFO_full_test extends FIFO_base_test;
  `uvm_component_utils(FIFO_full_test)

  FIFO_full_sequence test_seq;

  function new(string name = "FIFO_full_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);

    test_seq = FIFO_full_sequence::type_id::create("test_seq");
    `uvm_info("run_phase", "Full feature sequence started", UVM_NONE)
    test_seq.start(env.agt.sqr);
    `uvm_info("run_phase", "Full feature sequence ended", UVM_NONE)

    phase.drop_objection(this);
  endtask
endclass

endpackage
