set root [file dirname [file normalize [info script]]]
set out [file join $root verification]
file mkdir $out
create_project -in_memory -part xc7a35tcpg236-1
read_verilog [file join $root encoder.srcs sources_1 new encoder.v]
synth_design -top encoder -part xc7a35tcpg236-1
write_verilog -force [file join $out encoder_synth.v]
write_checkpoint -force [file join $out encoder_synth.dcp]
report_utilization -file [file join $out utilization.txt]
exit