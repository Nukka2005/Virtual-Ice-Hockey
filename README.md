# Digital Logic Design FPGA Project  

A **Digital Logic Design project** implemented on the **Digilent Basys3 FPGA board** using **Xilinx Vivado Design Suite**.  
This project demonstrates the design of a **real-time interactive paddle-ball game** with hardware-driven physics, sensor integration, and VGA display output.  

## Project Overview  

The project recreates a two-player paddle-ball game where paddles are physically moved on **wooden tracks** built in the workshop.  
The movement is detected using **infrared (IR) sensors**, processed in real time, and displayed as paddle movement on the VGA screen.  
The game includes **real-time ball physics**, a **goal counter**, and a **countdown timer** to create a complete gaming experience.  

## Key Features  

- **Real-Time Physics:** Ball movement calculated every clock cycle for smooth animation  
- **Physical Interaction:** IR sensors capture paddle movement and translate it to game coordinates  
- **VGA Output:** 640x480 @ 60Hz display timing using custom `pixel_gen.v` module  
- **Game State Tracking:** Goal counter and countdown timer displayed on-screen  
- **Synchronization:** Proper clock domain crossing and debouncing for switch/button inputs  

## Target Hardware  

- **FPGA:** Xilinx Artix-7 XC7A35T (Basys3 Board)  
- **Clock Frequency:** 100 MHz on-board oscillator divided to 25 MHz pixel clock for VGA  
- **Development Tools:** Vivado 2020.1 (Synthesis, Implementation, Timing Analysis)  

## System Architecture  

### Core Modules  
- **top.v:** Connects all submodules, manages reset and clock distribution  
- **clock_divider.v:** Generates 25 MHz pixel clock from 100 MHz master clock  
- **pixel_gen.v:** VGA controller that generates H-SYNC, V-SYNC, and pixel data per clock cycle  
- **physics_engine.v:** Handles ball trajectory, collision detection, and reflection logic  
- **input_controller.v:** Processes IR sensor data and debounces user inputs  
- **score_timer.v:** Maintains game time and increments score on successful goals  

### Timing & Clocking  

- **Master Clock:** 100 MHz input clock  
- **Derived Clocks:**  
  - 25 MHz Pixel Clock → used for VGA pixel generation (one pixel per cycle)  
  - Game Logic Clock → synchronized with pixel clock for smooth frame updates  
- **Timing Closure:**  
  - Worst Negative Slack (WNS): Met 0.00 ns (no timing violations)  
  - Setup & Hold Constraints satisfied after Place & Route  
  - Critical path optimized for collision detection and paddle updates

### Design Flow  

#HDL Sources → Synthesis → Implementation → Bitstream Generation → JTAG Programming

## Development Process  

1. **Hardware Design:** Built wooden paddle tracks and mounted IR sensors  
2. **Clock Setup:** Divided 100 MHz system clock down to 25 MHz pixel clock using clock divider  
3. **HDL Development:** Implemented game logic, VGA controller, physics engine, and input processing in Verilog  
4. **Simulation:** Verified timing, pixel synchronization, and collision detection using Vivado XSIM  
5. **Implementation:** Closed timing on 100 MHz system clock, met setup/hold requirements  
6. **Hardware Testing:** Programmed FPGA via JTAG, tested paddle movement and goal counter on real hardware  

## Learning Outcomes  

- Practical understanding of **clock domain management** and synchronization  
- Exposure to **timing closure and constraint-driven design** in Vivado  
- Implementation of **real-time physics engine** in hardware using combinational and sequential logic  
- Experience with **VGA timing specifications** and pixel-by-pixel graphics generation  

## Future Improvements  

- Add sound effects using PWM audio generation  
- Support higher VGA resolutions (800x600, 1024x768)  
- Implement wireless paddle detection (e.g., ultrasonic sensors or Bluetooth)  
- Improve graphics with sprites and smoother animations  
