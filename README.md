# Vitis HLS Project: [Your Project Name Here]

## 1. Overview

This project implements a [briefly describe the function, e.g., hardware accelerator for matrix multiplication, image filter, etc.] using the AMD-Xilinx Vitis High-Level Synthesis (HLS) tool (Unified IDE 2023.1 or later recommended).

The goal is to synthesize the C/C++ function `kernel_top` (defined in `hls/src/`) into RTL (Verilog/VHDL) suitable for implementation on an FPGA.

## 2. Folder Structure

The project follows this standard structure:

<project_root>/│├── hls/                      # Main directory for HLS-specific files│   ││   ├── src/                  # HLS synthesizable source files (C/C++)│   │   └── kernel.cpp        # <-- YOUR KERNEL CODE HERE│   │   └── kernel.hpp        # <-- Your kernel header (optional)│   ││   ├── tb/                   # Testbench files│   │   ├── tb_kernel.cpp     # <-- YOUR TESTBENCH CODE HERE│   │   ├── input_data.dat    # <-- Example input data│   │   └── output_golden.dat # <-- Example golden output│   ││   ├── scripts/              # Scripts for automation│   │   └── run_hls.tcl       # Tcl script to run HLS│   ││   └── vitis-hls.cfg         # Vitis HLS configuration file│├── README.md                 # This file└── .gitignore                # Optional: Git ignore file
## 3. Prerequisites

* **AMD-Xilinx Vitis Unified Software Platform:** Version 2023.1 or later installed and licensed.
* The Vitis environment needs to be sourced in your terminal before running the HLS script.

## 4. Configuration

Before running the synthesis process, configure the project settings:

1.  **Top Function:**
    * Open `hls/scripts/run_hls.tcl`.
    * Modify the `set TOP_FUNCTION "kernel_top"` line to match the exact name of your top-level function you want to synthesize.
2.  **Target Device & Clock:**
    * Open `hls/vitis-hls.cfg`.
    * Set the `part=` or `platform=` variable to your target Xilinx device or platform.
    * Set the `clock.period=` variable to your desired target clock period (e.g., `10ns`, `5ns`).
    * *(Alternatively, you can uncomment and set `TARGET_PART`/`TARGET_PLATFORM` and `CLOCK_PERIOD` directly in `hls/scripts/run_hls.tcl`)*.
3.  **Source Files:** Ensure your HLS kernel source files are placed in `hls/src/` and your testbench files are in `hls/tb/`. The `run_hls.tcl` script automatically picks up `.c`, `.cpp`, `.h`, `.hpp` files from these directories.

## 5. How to Run HLS

1.  **Open Terminal:** Launch a terminal or command prompt where the Vitis environment is sourced.
2.  **Navigate to `hls` Directory:** Change directory into the `hls` folder within your project root:
    ```bash
    cd path/to/your/project_root/hls
    ```
3.  **Execute HLS Script:** Run the Vitis HLS tool with the provided Tcl script:
    ```bash
    vitis_hls -f scripts/run_hls.tcl
    ```
    This command will:
    * Create a Vitis HLS project named `my_hls_project` (or as defined in the script).
    * Add the source and testbench files.
    * Configure the target device and clock.
    * Run C synthesis (`csynth_design`).
    * *(Optional: Run C/RTL co-simulation (`cosim_design`) if uncommented in `run_hls.tcl`)*.
    * Export the RTL design as an IP Catalog (`export_design`).

## 6. Outputs

After the script completes successfully:

* **HLS Project Files:** Located in the `hls/my_hls_project/` directory. You can open this project in the Vitis HLS GUI for detailed analysis.
* **Synthesis Reports:** Found within `hls/my_hls_project/solution1/syn/report/`. Check the `kernel_top_csynth.rpt` (or similar) file for timing, resource usage, and interface information.
* **Exported IP:** If the export step is successful, the generated IP package will be located in `hls/my_hls_project/solution1/impl/ip/`. This IP can be imported into a Vivado block design or a Vitis application project.
* **Simulation Results:** If co-simulation is run, reports are in `hls/my_hls_project/solution1/sim/report/`.

## 7. Notes

* [Add any specific notes about your implementation, limitations, or further steps here.]
* Ensure your testbench (`tb_kernel.cpp`) includes a `main` function that returns `0` upon successful completion for C/RTL co-simulation to report a "PASS" status.


