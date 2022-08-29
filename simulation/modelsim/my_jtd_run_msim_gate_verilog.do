transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {my_jtd.vo}

vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/bluetooth/test_zhcoded {C:/Users/HP/Desktop/bluetooth/test_zhcoded/my_jtd_tb.vt}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/bluetooth/test_zhcoded {C:/Users/HP/Desktop/bluetooth/test_zhcoded/my_ram.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/bluetooth/test_zhcoded {C:/Users/HP/Desktop/bluetooth/test_zhcoded/my_dwh.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/bluetooth/test_zhcoded {C:/Users/HP/Desktop/bluetooth/test_zhcoded/my_crc_test.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/bluetooth/test_zhcoded {C:/Users/HP/Desktop/bluetooth/test_zhcoded/my_crc.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/bluetooth/test_zhcoded {C:/Users/HP/Desktop/bluetooth/test_zhcoded/my_FEC.v}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_ver -L altera_lnsim_ver -L cyclonev_ver -L lpm_ver -L sgate_ver -L cyclonev_hssi_ver -L altera_mf_ver -L cyclonev_pcie_hip_ver -L gate_work -L work -voptargs="+acc"  my_jtd_tb

add wave *
view structure
view signals
run -all
