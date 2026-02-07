# FIFO-verification

run the do compile.do file first and follow it up by run.do file and open the .rpt file to see teh coverage report 

the coverage is still feature centric ,but good enough , need to make it operation centric too 


enter the directory you have the soruce files and run this 
# ---------- VCS ----------
setenv VCS_HOME /tools/Synopsys_tools/vcs/U-2023.03
setenv PATH $VCS_HOME/bin:$PATH

# ---------- VERDI ----------
setenv VERDI_HOME /tools/Synopsys_tools/verdi/U-2023.03-SP1
setenv NOVAS_HOME $VERDI_HOME
setenv PATH $VERDI_HOME/bin:$PATH
setenv LD_LIBRARY_PATH $VERDI_HOME/share/PLI/VCS/LINUX64

