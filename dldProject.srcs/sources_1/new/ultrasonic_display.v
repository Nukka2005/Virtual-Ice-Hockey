module infra(
    input wire clk,
    input wire reset,
    input wire [8:0] ir,              // 5 IR sensor inputs
    output reg [15:0] distance        // Common distance output for both sliders
);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
        end else begin
            distance <= 9;
            
            if (~ir[0])
                distance <= 8;
            else if (~ir[1])
                distance <= 7;
            else if (~ir[2])
                distance <= 6;
            else if (~ir[3])
                distance <= 5;
            else if (~ir[4])
                distance <= 4;
            else if (~ir[5])
                distance <= 3;
            else if (~ir[6])
                distance <= 2;
            else if (~ir[7])
                distance <= 1;
            else if (~ir[8])
                distance <= 0;
                
                
        end
    end
endmodule

