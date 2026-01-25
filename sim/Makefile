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

# all these variables get expanded when running the command 

#you have defined a target named compile 
# when you do make compile , you are saying
#"make, run the commands under teh target named compile"
compile:
	$(VCS) $(VCS_FLAGS) -f $(FILELIST) -o simv

#you have defined a target named run with dependency as compile
# what it means that before i can run teh commands of the run target , i need to run teh comamnds of compile target 
run: compile
	mkdir -p $(WAVEDIR) $(COVDIR)
	$(SIMV) \
	+UVM_TESTNAME=$(TEST) \
	+fsdbfile=$(WAVEDIR)/$(TEST).fsdb \
	-cm_name $(TEST) \
	-cm_dir $(COVDIR)/$(TEST) \
	+ntb_random_seed_automatic

#shell commands normally end at a newline , this \ tells that keep reading the next line as part of the command 
clean:
	rm -rf simv csrc *.log $(WAVEDIR) $(COVDIR) urgReport*
