VCS = vcs # vcs is the compiler 
SIMV = ./simv # simv is the simulation binary it generates 

FILELIST = src_files.list
FSDB_PATH = /tools/Synopsys_tools/verdi/U-2023.03-SP1/share/PLI/VCS/LINUX64
# vcs by itself doesnot know how to write .fsdb files 
#FSDB is a format owned by verdi
#so vcs needs a plugin (called PLI - programming language interface ) to talk to verdi and generate fsdb

# all these are called make variables 

# you are just turning on all these features with all these flags
# when you are in serious debugging mode, you turn on all these flags 

#makefile is a automation script , its just a rule book that tells which commands to run , in which order and under what name
VCS_FLAGS = -sverilog -full64 -debug_access+all -kdb \
            -ntb_opts uvm \
            -cm line+cond+fsm+tgl+branch \
            -P $(FSDB_PATH)/novas.tab $(FSDB_PATH)/pli.a \
            -l compile.log

TEST ?= FIFO_smoke_test
WAVEDIR = waves
COVDIR  = cov

compile:
	$(VCS) $(VCS_FLAGS) -f $(FILELIST) -o simv

run: compile
	mkdir -p $(WAVEDIR) $(COVDIR)
	$(SIMV) \
	+UVM_TESTNAME=$(TEST) \
	+fsdbfile=$(WAVEDIR)/$(TEST).fsdb \
	-cm_name $(TEST) \
	-cm_dir $(COVDIR)/$(TEST) \
	+ntb_random_seed_automatic

clean:
	rm -rf simv csrc *.log $(WAVEDIR) $(COVDIR) urgReport*
