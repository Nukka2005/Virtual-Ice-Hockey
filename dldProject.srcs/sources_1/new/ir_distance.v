module ir_distance (
    input wire clk,          // System clock
    input wire rst_n,        // Active-low reset
    input wire [7:0] adc_data, // 8-bit ADC input from IR sensor OUT pin
    output reg [9:0] distance_mm // Distance output in millimeters (0-1023 mm)
);

    // Internal registers for calculation
    reg [17:0] scaled;
    reg [9:0] distance_calc;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            distance_mm <= 10'd0;
        end else begin
            if (adc_data < 50) begin
                distance_mm <= 800;
            end else if (adc_data > 200) begin
                distance_mm <= 100;
            end else begin
                scaled = (adc_data - 50) * 700;
                distance_calc = 800 - (scaled / 150);

                if (distance_calc > 800)
                    distance_mm <= 800;
                else if (distance_calc < 100)
                    distance_mm <= 100;
                else
                    distance_mm <= distance_calc;
            end
        end
    end


endmodule