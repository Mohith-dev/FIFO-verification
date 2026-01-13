vsim -voptargs=+acc work.FIFO_top -classdebug -uvmcontrol=all -coverage
run -all
coverage save FIFO.ucdb
coverage report -details -output func_cov.rpt
