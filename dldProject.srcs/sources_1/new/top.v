`timescale 1ns / 1ps
module top(
    input clk_100MHz,       // from Basys 3
    input reset,            // btn
    output hsync,           // to VGA port
    output vsync,           // to VGA port
    output [11:0] rgb,      // to DAC, to VGA port
    input [8:0] ir_sens,
    input [8:0] ir_sens2
    );
    
    wire [9:0] w_x, w_y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    wire [15:0] distance_right;  // Distance from right ultrasonic sensor
    wire [15:0] distance_left;   // Distance from left ultrasonic sensor
    
    vga_controller vga(.clk_100MHz(clk_100MHz), .reset(w_reset), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    
    pixel_gen pg(.clk(clk_100MHz), .reset(w_reset), 
                 .video_on(w_vid_on), .x(w_x), .y(w_y), 
                 .distance_right(distance_right), 
                 .distance_left(distance_left), 
                 .rgb(rgb_next));
    
    debounce dbR(.clk(clk_100MHz), .btn_in(reset), .btn_out(w_reset));
    
    // Right ultrasonic sensor
    infra infra_right(
        .clk(clk_100MHz),
        .reset(reset),
        .ir(ir_sens2),
        .distance(distance_right)
    );
    
    // Left ultrasonic sensor
    infra infra_left(
        .clk(clk_100MHz),
        .reset(reset),
        .ir(ir_sens),
        .distance(distance_left)
    );
    
    // rgb buffer
    always @(posedge clk_100MHz)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;
    
endmodule