vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 \
"../../../../minisys1_1.srcs/sources_1/ip/uart_bmpg_0/uart_bmpg.v" \
"../../../../minisys1_1.srcs/sources_1/ip/uart_bmpg_0/upg.v" \
"../../../../minisys1_1.srcs/sources_1/ip/uart_bmpg_0/sim/uart_bmpg_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

