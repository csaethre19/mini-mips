transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/alucontrol.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/datapath.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/alu.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/zerodetect.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/flopr.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/flopenr.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/mux2.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/mux4.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/mipscpu.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/mipssystem.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/exmem.v}
vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/regfile.v}

vlog -vlog01compat -work work +incdir+C:/Users/charl/OneDrive/School/ECE\ 3710/mini-mips {C:/Users/charl/OneDrive/School/ECE 3710/mini-mips/tb_mipscpu.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_mipscpu

add wave *
view structure
view signals
run -all
