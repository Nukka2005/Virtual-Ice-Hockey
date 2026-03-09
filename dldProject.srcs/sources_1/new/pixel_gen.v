module pixel_gen(
    input clk,
    input reset,   
    input video_on,
    input [9:0] x, y,
    input [15:0] distance_right,   // Distance from right ultrasonic sensor
    input [15:0] distance_left,    // Distance from left ultrasonic sensor
    output reg [11:0] rgb
);

    // ====== Display Parameters ======
    parameter X_MAX = 639;
    parameter Y_MAX = 479;

    // Refresh tick (start of vertical retrace)
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)); // Start of vertical blanking

    // ====== Game Elements ======
    // Wall parameters
    parameter X_WALL_L = 318;
    parameter X_WALL_R = 321;
    wire wall_on = (X_WALL_L <= x) && (x <= X_WALL_R);

    // Paddle parameters
    parameter PAD_HEIGHT = 80;
    parameter PAD_VELOCITY = 3;

    // Infrared sensor distance mapping parameters
    parameter DIST_MIN = 0;   // Minimum distance in cm (multiplied by 10)
    parameter DIST_MAX = 9;  // Maximum distance in cm (multiplied by 10)
    parameter Y_MIN = 0;      // Top position for paddle
    parameter Y_MAX_PADDLE = Y_MAX - PAD_HEIGHT; // Bottom position limit for paddle

    // Left Paddle (Player 1) - Controlled by left ultrasonic sensor
    parameter X_LPAD_L = 32;
    parameter X_LPAD_R = 35;
    reg [9:0] y_lpad_reg, y_lpad_next;
    wire [9:0] y_lpad_t = y_lpad_reg;
    wire [9:0] y_lpad_b = y_lpad_t + PAD_HEIGHT - 1;
    wire lpad_on = (X_LPAD_L <= x) && (x <= X_LPAD_R) &&
                   (y_lpad_t <= y) && (y <= y_lpad_b);

    // Right Paddle (Player 2) - Controlled by right ultrasonic sensor
    parameter X_RPAD_L = 600;
    parameter X_RPAD_R = 603;
    reg [9:0] y_rpad_reg, y_rpad_next;
    wire [9:0] y_rpad_t = y_rpad_reg;
    wire [9:0] y_rpad_b = y_rpad_t + PAD_HEIGHT - 1;
    wire rpad_on = (X_RPAD_L <= x) && (x <= X_RPAD_R) &&
                   (y_rpad_t <= y) && (y <= y_rpad_b);

    // Ball parameters
    parameter BALL_SIZE = 10;
    parameter BALL_VELOCITY_POS = 2;
    parameter BALL_VELOCITY_NEG = -2;
    parameter BALL_RESET_X = 320;
    parameter BALL_RESET_Y = 240;

    reg [9:0] x_ball_reg, y_ball_reg;
    wire [9:0] x_ball_l = x_ball_reg;
    wire [9:0] x_ball_r = x_ball_l + BALL_SIZE - 1;
    wire [9:0] y_ball_t = y_ball_reg;
    wire [9:0] y_ball_b = y_ball_t + BALL_SIZE - 1;

    reg [9:0] x_delta_reg, y_delta_reg;
    reg [9:0] x_delta_next, y_delta_next;
    reg serve_left; // Track which player should receive serve
    
    wire [9:0] x_ball_next = (refresh_tick) ? x_ball_reg + x_delta_reg : x_ball_reg;
    wire [9:0] y_ball_next = (refresh_tick) ? y_ball_reg + y_delta_reg : y_ball_reg;

    // Ball ROM shape
    wire [2:0] rom_addr = y[2:0] - y_ball_t[2:0];
    wire [2:0] rom_col = x[2:0] - x_ball_l[2:0];
    reg [7:0] rom_data;
    wire rom_bit = rom_data[rom_col];
    wire sq_ball_on = (x_ball_l <= x) && (x <= x_ball_r) &&
                      (y_ball_t <= y) && (y <= y_ball_b);
    wire ball_on = sq_ball_on & rom_bit;

    // ROM shape definition
    always @* begin
        case (rom_addr)
            3'b000: rom_data = 8'b00111100;
            3'b001: rom_data = 8'b01111110;
            3'b010: rom_data = 8'b11111111;
            3'b011: rom_data = 8'b11111111;
            3'b100: rom_data = 8'b11111111;
            3'b101: rom_data = 8'b11111111;
            3'b110: rom_data = 8'b01111110;
            3'b111: rom_data = 8'b00111100;
        endcase
    end

    // Ball trail effect
    wire ball_trail = ((x_ball_l-5 <= x) && (x <= x_ball_l) && 
                      (y_ball_t <= y) && (y <= y_ball_b) && (x_delta_reg > 0)) ||
                     ((x_ball_r <= x) && (x <= x_ball_r+5) && 
                      (y_ball_t <= y) && (y <= y_ball_b) && (x_delta_reg < 0));

    // ====== Distance to Paddle Position Conversion ======
    // Convert right distance to right paddle position
    wire [9:0] y_rpad_position;
    wire [15:0] clamped_distance_right;
    assign clamped_distance_right = (distance_right < DIST_MIN) ? DIST_MIN :
                                   (distance_right > DIST_MAX) ? DIST_MAX : distance_right;
    assign y_rpad_position = Y_MIN + ((Y_MAX_PADDLE - Y_MIN) * 
                           (clamped_distance_right - DIST_MIN)) / 
                           (DIST_MAX - DIST_MIN);

    // Convert left distance to left paddle position
    wire [9:0] y_lpad_position;
    wire [15:0] clamped_distance_left;
    assign clamped_distance_left = (distance_left < DIST_MIN) ? DIST_MIN :
                                  (distance_left > DIST_MAX) ? DIST_MAX : distance_left;
    assign y_lpad_position = Y_MIN + ((Y_MAX_PADDLE - Y_MIN) * 
                          (clamped_distance_left - DIST_MIN)) / 
                          (DIST_MAX - DIST_MIN);

    // ====== Score Counter ======
    reg [3:0] blue_score_tens = 4'd0;
    reg [3:0] blue_score_ones = 4'd0;
    reg [3:0] red_score_tens = 4'd0;
    reg [3:0] red_score_ones = 4'd0;
    
    // Score detection signals - check if ball is past the screen edges
    wire blue_scores = (x_ball_l <= 0) && !game_over;      // Ball passes left edge, red scores
    wire red_scores = (x_ball_r >= X_MAX) && !game_over;   // Ball passes right edge, blue scores
    
    // ====== Timer Implementation ======
    reg [31:0] clk_count = 0;
    reg [6:0] seconds = 120;
    wire game_over = (seconds == 0);
    
    parameter ONE_SECOND = 50000000;
    
    // Main game logic state machine
    reg [1:0] game_state;
    parameter PLAY = 2'b00;
    parameter RED_SCORED = 2'b01;
    parameter BLUE_SCORED = 2'b10;
    parameter RESET_BALL = 2'b11;
    
    // Reset delay counter
    reg [31:0] reset_delay_count;
    parameter RESET_DELAY = 50000000; // 1 second delay for ball reset

    // ====== Game Over Text Module ======
    wire game_over_text_on, game_over_bg_on;
    game_over_text game_over_display(
        .x(x),
        .y(y),
        .game_over(game_over),
        .text_on(game_over_text_on),
        .bg_on(game_over_bg_on)
    );

    // ====== Game State Logic ======
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all game state
            clk_count <= 0;
            seconds <= 120;
            blue_score_tens <= 4'd0;
            blue_score_ones <= 4'd0;
            red_score_tens <= 4'd0;
            red_score_ones <= 4'd0;
            serve_left <= 1'b0;
            game_state <= PLAY;
            reset_delay_count <= 0;
//            x_ball_reg <= BALL_RESET_X;
//            y_ball_reg <= BALL_RESET_Y;
            x_delta_reg <= 10'h002;  // Initial ball direction is right
            y_delta_reg <= 10'h002;  // Initial ball direction is down
        end else begin
            // Timer logic
            if (clk_count == ONE_SECOND - 1) begin
                clk_count <= 0;
                if (seconds > 0) seconds <= seconds - 1;
            end else begin
                clk_count <= clk_count + 1;
            end
            
            // Game state machine
            case (game_state)
                PLAY: begin
                    // Check for scoring conditions
                    if (red_scores) begin
                        game_state <= BLUE_SCORED;
                        reset_delay_count <= 0;
                    end else if (blue_scores) begin
                        game_state <= RED_SCORED;
                        reset_delay_count <= 0;
                    end else begin
                        // Normal gameplay - update ball position on refresh tick
                        if (refresh_tick) begin
                            x_ball_reg <= x_ball_next;
                            y_ball_reg <= y_ball_next;
                            x_delta_reg <= x_delta_next;
                            y_delta_reg <= y_delta_next;
                        end
                    end
                end
                
                RED_SCORED: begin
                    // Increment red score
                    if (red_score_ones < 9) begin
                        red_score_ones <= red_score_ones + 1;
                    end else begin
                        red_score_ones <= 4'd0;
                        if (red_score_tens < 9) 
                            red_score_tens <= red_score_tens + 1;
                    end
                    serve_left <= 1'b1; // Next serve goes to left
                    game_state <= RESET_BALL;
                end
                
                BLUE_SCORED: begin
                    // Increment blue score
                    if (blue_score_ones < 9) begin
                        blue_score_ones <= blue_score_ones + 1;
                    end else begin
                        blue_score_ones <= 4'd0;
                        if (blue_score_tens < 9) 
                            blue_score_tens <= blue_score_tens + 1;
                    end
                    serve_left <= 1'b0; // Next serve goes to right
                    game_state <= RESET_BALL;
                end
                
                RESET_BALL: begin
                    // Reset ball position and wait for a delay
                    x_ball_reg <= BALL_RESET_X;
                    y_ball_reg <= BALL_RESET_Y;
                    
                    // Set initial direction based on who scored
                    if (serve_left) begin
                        x_delta_reg <= 10'h3FE; // Left direction (negative)
                    end else begin
                        x_delta_reg <= 10'h002; // Right direction (positive)
                    end
                    
                    // Randomize y direction using clock LSB
                    y_delta_reg <= clk_count[0] ? 10'h002 : 10'h3FE;
                    
                    // Delay before returning to play state
                    if (reset_delay_count >= RESET_DELAY) begin
                        game_state <= PLAY;
                    end else begin
                        reset_delay_count <= reset_delay_count + 1;
                    end
                end
            endcase
            
            // Update paddle positions on refresh tick
            if (refresh_tick) begin
                y_lpad_reg <= y_lpad_next;
                y_rpad_reg <= y_rpad_next;
            end
        end
    end
    
    // ====== Paddle Movement Logic ======
    always @* begin
        y_lpad_next = y_lpad_position;
        y_rpad_next = y_rpad_position;
    end

    // ====== Ball Collision Logic ======
    always @* begin
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;

        if (game_over) begin
            x_delta_next = 0;
            y_delta_next = 0;
        end else begin
            // Top and bottom wall collisions
            if (y_ball_t < 1)
                y_delta_next = BALL_VELOCITY_POS;
            else if (y_ball_b > Y_MAX)
                y_delta_next = BALL_VELOCITY_NEG;
                
            // Left paddle collision
            if ((X_LPAD_L <= x_ball_l) && (x_ball_l <= X_LPAD_R) &&
                (y_lpad_t <= y_ball_b) && (y_ball_t <= y_lpad_b)) begin
                x_delta_next = BALL_VELOCITY_POS; // Simply reverse x direction
                // y_delta_next remains unchanged - no angle modification based on paddle hit position
            end
            // Right paddle collision
            else if ((X_RPAD_L <= x_ball_r) && (x_ball_r <= X_RPAD_R) &&
                     (y_rpad_t <= y_ball_b) && (y_ball_t <= y_rpad_b)) begin
                x_delta_next = BALL_VELOCITY_NEG; // Simply reverse x direction
                // y_delta_next remains unchanged - no angle modification based on paddle hit position
            end
        end
    end

    // ====== Display Elements ======
    // Timer bar
    parameter TIMER_WIDTH = 100;
    parameter TIMER_HEIGHT = 10;
    parameter TIMER_X = 320;
    parameter TIMER_Y = 20;
    
    wire [9:0] timer_current_width;
    assign timer_current_width = (TIMER_WIDTH * seconds) / 120;
    
    wire timer_outline = (TIMER_Y <= y) && (y < TIMER_Y + TIMER_HEIGHT) && 
                        (TIMER_X - TIMER_WIDTH/2 <= x) && (x < TIMER_X + TIMER_WIDTH/2);
    
    wire timer_filled = (TIMER_Y <= y) && (y < TIMER_Y + TIMER_HEIGHT) && 
                        (TIMER_X - TIMER_WIDTH/2 <= x) && (x < TIMER_X - TIMER_WIDTH/2 + timer_current_width);
    
    // Score display positions
    parameter BLUE_SCORE_X_TENS = 140;
    parameter BLUE_SCORE_X_ONES = 165;
    parameter RED_SCORE_X_TENS = 460;
    parameter RED_SCORE_X_ONES = 485;
    parameter SCORE_Y = 40;
    parameter DIGIT_WIDTH = 20;
    parameter DIGIT_HEIGHT = 30;
    
    // Display digit function for 7-segment style digits
    function display_digit;
        input [9:0] digit_x, digit_y;
        input [3:0] digit;
        input [9:0] x, y;
        
        reg top, middle, bottom, left_top, left_bottom, right_top, right_bottom;
        reg digit_on;
        
        begin
            top = (digit_y <= y) && (y <= digit_y + 3) &&
                  (digit_x + 3 <= x) && (x <= digit_x + DIGIT_WIDTH - 3);
            middle = (digit_y + DIGIT_HEIGHT/2 - 2 <= y) && (y <= digit_y + DIGIT_HEIGHT/2 + 2) &&
                     (digit_x + 3 <= x) && (x <= digit_x + DIGIT_WIDTH - 3);
            bottom = (digit_y + DIGIT_HEIGHT - 3 <= y) && (y <= digit_y + DIGIT_HEIGHT) &&
                     (digit_x + 3 <= x) && (x <= digit_x + DIGIT_WIDTH - 3);
            left_top = (digit_y + 3 <= y) && (y <= digit_y + DIGIT_HEIGHT/2 - 2) &&
                       (digit_x <= x) && (x <= digit_x + 3);
            left_bottom = (digit_y + DIGIT_HEIGHT/2 + 2 <= y) && (y <= digit_y + DIGIT_HEIGHT - 3) &&
                          (digit_x <= x) && (x <= digit_x + 3);
            right_top = (digit_y + 3 <= y) && (y <= digit_y + DIGIT_HEIGHT/2 - 2) &&
                        (digit_x + DIGIT_WIDTH - 3 <= x) && (x <= digit_x + DIGIT_WIDTH);
            right_bottom = (digit_y + DIGIT_HEIGHT/2 + 2 <= y) && (y <= digit_y + DIGIT_HEIGHT - 3) &&
                           (digit_x + DIGIT_WIDTH - 3 <= x) && (x <= digit_x + DIGIT_WIDTH);
            
            case (digit)
                4'd0: digit_on = top || bottom || left_top || left_bottom || right_top || right_bottom;
                4'd1: digit_on = right_top || right_bottom;
                4'd2: digit_on = top || middle || bottom || right_top || left_bottom;
                4'd3: digit_on = top || middle || bottom || right_top || right_bottom;
                4'd4: digit_on = left_top || middle || right_top || right_bottom;
                4'd5: digit_on = top || middle || bottom || left_top || right_bottom;
                4'd6: digit_on = top || middle || bottom || left_top || left_bottom || right_bottom;
                4'd7: digit_on = top || right_top || right_bottom;
                4'd8: digit_on = top || middle || bottom || left_top || left_bottom || right_top || right_bottom;
                4'd9: digit_on = top || middle || bottom || left_top || right_top || right_bottom;
                default: digit_on = 0;
            endcase
            
            display_digit = digit_on;
        end
    endfunction
    
    // Score digit display
    wire blue_score_tens_display = display_digit(BLUE_SCORE_X_TENS, SCORE_Y, blue_score_tens, x, y);
    wire blue_score_ones_display = display_digit(BLUE_SCORE_X_ONES, SCORE_Y, blue_score_ones, x, y);
    wire red_score_tens_display = display_digit(RED_SCORE_X_TENS, SCORE_Y, red_score_tens, x, y);
    wire red_score_ones_display = display_digit(RED_SCORE_X_ONES, SCORE_Y, red_score_ones, x, y);
    
    // Background elements
    wire center_circle = ((x-320)*(x-320) + (y-240)*(y-240) <= 100*100) && 
                        !((x-320)*(x-320) + (y-240)*(y-240) <= 95*95);
    
    wire left_field_arc = ((x-0)*(x-0) + (y-240)*(y-240) <= 150*150) && 
                         ((x-0)*(x-0) + (y-240)*(y-240) >= 145*145) && (x <= 150);
                         
    wire right_field_arc = ((x-640)*(x-640) + (y-240)*(y-240) <= 150*150) && 
                          ((x-640)*(x-640) + (y-240)*(y-240) >= 145*145) && (x >= 490);

    // ====== Color Definitions ======
    wire [11:0] bg_rgb = 12'h000;
    wire [11:0] wall_rgb = 12'hFFF;
    wire [11:0] lpad_rgb = 12'h00F;
    wire [11:0] rpad_rgb = 12'hF00;
    wire [11:0] ball_rgb = 12'hFFF;
    wire [11:0] ball_trail_rgb = 12'hFA0;
    wire [11:0] timer_bg_rgb = 12'h444;
    wire [11:0] timer_rgb = (seconds < 10) ? 12'hF00 : 
                           (seconds < 30) ? 12'hF80 : 12'h0F0;
    wire [11:0] game_over_bg_rgb = 12'h008;
    wire [11:0] game_over_text_rgb = 12'hF00;
    wire [11:0] center_circle_rgb = 12'hFFF;
    wire [11:0] blue_score_rgb = 12'h00F;
    wire [11:0] red_score_rgb = 12'hF00;

    // ====== RGB Output Logic ======
    always @* begin
        if (~video_on)
            rgb = 12'h000;
        else begin
            rgb = bg_rgb;
            
            if (center_circle || left_field_arc || right_field_arc)
                rgb = center_circle_rgb;
            else if (wall_on)
                rgb = wall_rgb;
            else if (lpad_on)
                rgb = lpad_rgb;
            else if (rpad_on)
                rgb = rpad_rgb;
            else if (ball_on)
                rgb = ball_rgb;
            else if (ball_trail)
                rgb = ball_trail_rgb;
            else if (blue_score_tens_display || blue_score_ones_display)
                rgb = blue_score_rgb;
            else if (red_score_tens_display || red_score_ones_display)
                rgb = red_score_rgb;
            else if (timer_outline && !timer_filled)
                rgb = timer_bg_rgb;
            else if (timer_filled)
                rgb = timer_rgb;
            else if (game_over_bg_on && !game_over_text_on)
                rgb = game_over_bg_rgb;
            else if (game_over_text_on)
                rgb = game_over_text_rgb;
        end
    end

endmodule