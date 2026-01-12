vsim -voptargs=+acc work.FIFO_top -classdebug -uvmcontrol=all -cover
add wave -r sim:/FIFO_top/FIFO_if/*
coverage save FIFO.ucdb
coverage report -cvg -details -file func_cov.rpt
run -all
