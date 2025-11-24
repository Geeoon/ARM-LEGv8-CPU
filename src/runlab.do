# Create work library
vlib work

# load the rtl files (modules to be tested)
vlog "rtl/*.sv"
vlog "rtl/alu/*.sv"
vlog "rtl/regfile/*.sv"
vlog "rtl/memory/*.sv"


# load the tests
# vlog "./**/*_helper.sv"
vlog "tests/alu/*.sv"
vlog "tests/regfile/*.sv"
vlog "tests/*.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
# vsim -voptargs="+acc" -t 1ps -lib work alustim
# vsim -voptargs="+acc" -t 1ps -lib work bitwise_and_tb
# vsim -voptargs="+acc" -t 1ps -lib work bitwise_xor_tb
# vsim -voptargs="+acc" -t 1ps -lib work bitwise_or_tb
# vsim -voptargs="+acc" -t 1ps -lib work full_adder_tb
# vsim -voptargs="+acc" -t 1ps -lib work alu_zero_tb
# vsim -voptargs="+acc" -t 1ps -lib work adder_tb
# vsim -voptargs="+acc" -t 1ps -lib work sign_extender_tb
# vsim -voptargs="+acc" -t 1ps -lib work cpu_datapath_tb
vsim -voptargs="+acc" -t 1ps -lib work cpu_tb

# do modelsim/alustim_wave.do
# do modelsim/bitwise_and_wave.do
# do modelsim/bitwise_xor_wave.do
# do modelsim/bitwise_or_wave.do
# do modelsim/full_adder_wave.do
# do modelsim/alu_zero_wave.do
# do modelsim/adder_wave.do
# do modelsim/sign_extender_wave.do
# do modelsim/cpu_datapath_wave.do
do modelsim/cpu_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
