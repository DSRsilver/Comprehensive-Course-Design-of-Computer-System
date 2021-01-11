onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ram3 -L dist_mem_gen_v8_0_12 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ram3 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ram3.udo}

run -all

endsim

quit -force
