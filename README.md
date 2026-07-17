# Stack-based Floating Point System

A stack-based 13-bit custom floating point processing system implemented in VHDL on the Nexys A7 FPGA.

## Project Overview

This project implements a stack-based floating point processing system in VHDL for the Nexys A7 FPGA development board.

The system uses a custom 13-bit floating-point representation together with a 32-word stack memory to demonstrate several floating point operations under the control of a finite state machine (FSM). Operands are retrieved from the stack and processed by a dedicated datapath containing floating point arithmetic, comparison, and conversion units.

The design follows a controller with datapath architecture commonly used in digital systems, where the FSM generates the control signals while the datapath performs the required computations.

## Features

- Custom 13-bit floating-point number format (1 bit sign, 4 bit exponent and 8 bit fraction)
- 32-word × 13-bit stack memory
- FSM–datapath architecture
- Floating point addition with Guard, Round and Sticky (GRS) bits
- Floating point comparison
- Floating point to 8 bit signed integer conversion with GRS-based rounding
- Integer to floating-point conversion
- Push-button controlled hardware demonstration
- Seven-segment display output
- LED result display
- Modular VHDL implementation

## System Architecture

The system consists of four primary modules:

- **FSM Controller** – Controls the overall execution sequence and generates control signals.
- **Stack Memory** – Stores 32 custom floating point values for hardware demonstrations.
- **Datapath** – Performs floating point arithmetic, comparison and FP to integer conversion.
- **Display Logic** – Routes the selected result to the LEDs and seven-segment display.

![Block Diagram](images/Block%20Diagram.svg)

## Custom Floating-Point Format

Each floating-point value consists of 13 bits:

| Field | Width |
|-------|------:|
| Sign | 1 bit |
| Exponent | 4 bits |
| Fraction | 8 bits |

The exponent uses a bias of 7, and the significand is represented in the form 0.1xxxxxxxx₂.

## FSM Operation

The controller guides the system through four operations:

1. Floating point addition
2. Floating point comparison
3. Floating point to integer conversion
4. Integer to floating point conversion

Each demonstration case consumes five floating-point operands from the stack, except for the Integer to floating point conversion which takes input from the switches. Six demonstration cases are executed before returning to the stack loading state.

![FSM](images/State%20Diagram.svg)

## Project Structure

```text
src/
    datapath_fps.vhd
    FSM_fps.vhd
    Stack.vhd
    fp_adder.vhd
    fp_greater.vhd
    fp2int.vhd
    fp_convert.vhd
    top_disp_mux.vhd
    top_fps.vhd
    debounce.vhd

tb/
    tb_fp_adder
    tb_comp
    tb_fp2int
    tb_int2fp
    tb_fsm
    tb_datapath
    tb_stack
    tb_top_fps
    

constraints/
    Nexys-A7-100T-Master.xdc

docs/
    Block diagram.drawio
    State diagram.drawio

images/
    Hardware Demonstration.png
    FSM Simulation.png
    Stack Simulation.png
    Top file Simulation.png
    Block Diagram.svg
    State Diagram.svg

```

## Hardware Demonstration

![Hardware Demonstration](images/Floating%20point%20system%20demonstration.png)

A complete hardware demonstration is available on YouTube.

Link:

## Simulation

The design was verified using dedicated testbenches for:

- Stack memory
- Floating point adder
- Floating point comparator
- Floating point to integer converter
- Integer to floating point converter
- Datapath
- FSM controller
- Top level integration

![Top level Simuation](images/Top%20file%20Simulation.png)

## Future Improvements

Potential future extensions include:

- Floating point multiplication
- Floating point division
- Exception handling
- IEEE-754 compliant format
- Larger stack memory

## Author

Mradul Singh

