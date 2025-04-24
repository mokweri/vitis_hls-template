# Vitis HLS Tcl Script (run_hls.tcl)
# Place this script in the hls/scripts/ directory
# Run from the 'hls/' directory using: vitis_hls -f scripts/run_hls.tcl

# --- Configuration ---
# Project Name
set PROJECT_NAME "my_hls_project"

# Top Function Name (Must match the function to be synthesized)
set TOP_FUNCTION "kernel_top" # CHANGE THIS to your top function name

# Target Part or Platform (Override cfg file if needed, otherwise comment out)
# set TARGET_PART "xc7z020clg484-1"
# set TARGET_PLATFORM "xilinx_u250..."

# Target Clock Period (Override cfg file if needed, otherwise comment out)
# set CLOCK_PERIOD "10ns"

# Solution Name
set SOLUTION_NAME "solution1"

# Source and Testbench Files (Relative paths from the 'hls' directory)
set SRC_FILES [glob -nocomplain ../src/*.cpp ../src/*.c ../src/*.hpp ../src/*.h]
set TB_FILES [glob -nocomplain ../tb/*.cpp ../tb/*.c]
set TB_DATA_FILES [glob -nocomplain ../tb/*.dat ../tb/*.csv] # Add other data extensions if needed

# Optional: Load configuration from vitis-hls.cfg if it exists
if {[file exists "../vitis-hls.cfg"]} {
    puts "INFO: Loading configuration from ../vitis-hls.cfg"
    source "../vitis-hls.cfg"
} else {
    puts "INFO: ../vitis-hls.cfg not found. Using defaults or Tcl script settings."
    # Set defaults if no config file is present and not set above
    if {![info exists TARGET_PART] && ![info exists TARGET_PLATFORM]} {
        set TARGET_PART "xc7z020clg484-1" ;# Default part if none specified
        puts "WARNING: No target part or platform specified. Using default: $TARGET_PART"
    }
    if {![info exists CLOCK_PERIOD]} {
        set CLOCK_PERIOD "10ns" ; # Default clock if none specified
        puts "WARNING: No clock period specified. Using default: $CLOCK_PERIOD"
    }
}


# --- Project Setup ---
puts "INFO: Creating/Opening HLS Project: $PROJECT_NAME"
open_project -reset $PROJECT_NAME

# Set the top-level function for synthesis
puts "INFO: Setting Top Function: $TOP_FUNCTION"
set_top $TOP_FUNCTION

# Add design source files
if {[llength $SRC_FILES] > 0} {
    puts "INFO: Adding Source Files: $SRC_FILES"
    add_files $SRC_FILES
} else {
    puts "ERROR: No source files found in ../src/. Please add your HLS C/C++ files."
    exit 1
}

# Add testbench files (source and data)
if {[llength $TB_FILES] > 0} {
    puts "INFO: Adding Testbench Files: $TB_FILES"
    add_files -tb $TB_FILES
} else {
    puts "WARNING: No testbench source files (.c/.cpp) found in ../tb/."
}
if {[llength $TB_DATA_FILES] > 0} {
    puts "INFO: Adding Testbench Data Files: $TB_DATA_FILES"
    add_files -tb $TB_DATA_FILES -copy_to_sim_dir
}


# --- Solution Setup ---
puts "INFO: Creating/Opening Solution: $SOLUTION_NAME"
open_solution -reset $SOLUTION_NAME

# Set target device (use platform OR part, platform usually takes precedence if both defined)
if {[info exists TARGET_PLATFORM]} {
     puts "INFO: Setting Target Platform: $TARGET_PLATFORM"
     set_part $TARGET_PLATFORM
} elseif {[info exists TARGET_PART]} {
     puts "INFO: Setting Target Part: $TARGET_PART"
     set_part $TARGET_PART
} else {
     puts "ERROR: No target part or platform defined in script or cfg file!"
     exit 1
}

# Set target clock period
if {[info exists CLOCK_PERIOD]} {
    puts "INFO: Setting Clock Period: $CLOCK_PERIOD"
    create_clock -period $CLOCK_PERIOD -name default
} else {
    puts "ERROR: No clock period defined in script or cfg file!"
    exit 1
}

# --- HLS Execution ---
# Optional: Add HLS directives here (e.g., interface pragmas, pipelining)
# Example: set_directive_interface -mode s_axilite "my_kernel" port=control
# Example: set_directive_pipeline "my_kernel/loop1"

# Run C Synthesis
puts "INFO: Starting C Synthesis..."
csynth_design
puts "INFO: C Synthesis complete."

# Run C/RTL Cosimulation (optional but recommended)
# Ensure your testbench returns 0 on success for cosim to pass
puts "INFO: Starting C/RTL Cosimulation..."
# Uncomment the following line to enable cosimulation
# cosim_design -trace_level all -tool xsim # Use 'vcs' or 'modelsim' if preferred and licensed

# Check if cosim_design command exists before trying to check status (it might be commented out)
# if {[info commands cosim_design] ne "" && [info exists ::cosim_design_status]} {
#     if {$::cosim_design_status == "PASS"} {
#         puts "INFO: C/RTL Cosimulation PASSED."
#     } else {
#         puts "ERROR: C/RTL Cosimulation FAILED."
#         # exit 1 # Optional: exit script if cosim fails
#     }
# } else {
#     puts "INFO: C/RTL Cosimulation skipped or status not available."
# }


# Export RTL (choose format: VHDL/Verilog, evaluation/syn)
puts "INFO: Exporting RTL..."
export_design -format ip_catalog -output "${PROJECT_NAME}_ip" # Export as IP Catalog for Vivado/Vitis integration
# export_design -format verilog # Or export plain Verilog/VHDL
puts "INFO: RTL Export complete. Output IP: ${PROJECT_NAME}/${SOLUTION_NAME}/impl/ip"


# --- Cleanup ---
puts "INFO: Vitis HLS script finished."
exit

