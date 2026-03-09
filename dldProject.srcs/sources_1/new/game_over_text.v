module game_over_text(
    input wire [9:0] x, y,        // Current pixel coordinates
    input wire game_over,         // Game over flag
    output wire text_on,          // Text pixel is on
    output wire bg_on            // Background is on
);

    // Game over display parameters
    parameter GAME_OVER_Y = 240;
    parameter GAME_OVER_TEXT_X = 220;
    parameter GAME_OVER_TEXT_Y = 220;
    parameter LETTER_WIDTH = 20;
    parameter LETTER_HEIGHT = 40;
    parameter LETTER_SPACING = 5;
    
    // Background area
    assign bg_on = game_over && 
                  (GAME_OVER_Y - 50 <= y) && (y <= GAME_OVER_Y + 50) &&
                  (160 <= x) && (x <= 480);
    
    // Individual letter display logic
    wire g_letter = game_over && 
                   (GAME_OVER_TEXT_X <= x) && (x < GAME_OVER_TEXT_X + LETTER_WIDTH) &&
                   (GAME_OVER_TEXT_Y <= y) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT) &&
                   ((x < GAME_OVER_TEXT_X + 5) || 
                    (y < GAME_OVER_TEXT_Y + 5) || 
                    (y >= GAME_OVER_TEXT_Y + LETTER_HEIGHT - 5) || 
                    ((x >= GAME_OVER_TEXT_X + LETTER_WIDTH - 5) && (y >= GAME_OVER_TEXT_Y + LETTER_HEIGHT/2 - 5)));
    
    wire a_letter = game_over && 
                   (GAME_OVER_TEXT_X + LETTER_WIDTH + LETTER_SPACING <= x) && 
                   (x < GAME_OVER_TEXT_X + 2*LETTER_WIDTH + LETTER_SPACING) &&
                   (GAME_OVER_TEXT_Y <= y) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT) &&
                   ((x < GAME_OVER_TEXT_X + LETTER_WIDTH + LETTER_SPACING + 5) || 
                    (x >= GAME_OVER_TEXT_X + 2*LETTER_WIDTH + LETTER_SPACING - 5) || 
                    (y < GAME_OVER_TEXT_Y + 5) || 
                    ((y >= GAME_OVER_TEXT_Y + LETTER_HEIGHT/2 - 2) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT/2 + 3)));
    
    wire m_letter = game_over && 
                   (GAME_OVER_TEXT_X + 2*LETTER_WIDTH + 2*LETTER_SPACING <= x) && 
                   (x < GAME_OVER_TEXT_X + 3*LETTER_WIDTH + 2*LETTER_SPACING) &&
                   (GAME_OVER_TEXT_Y <= y) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT) &&
                   ((x < GAME_OVER_TEXT_X + 2*LETTER_WIDTH + 2*LETTER_SPACING + 5) || 
                    (x >= GAME_OVER_TEXT_X + 3*LETTER_WIDTH + 2*LETTER_SPACING - 5) || 
                    ((x >= GAME_OVER_TEXT_X + 2*LETTER_WIDTH + 2*LETTER_SPACING + LETTER_WIDTH/2 - 3) && 
                     (x < GAME_OVER_TEXT_X + 2*LETTER_WIDTH + 2*LETTER_SPACING + LETTER_WIDTH/2 + 3)) || 
                    ((y < GAME_OVER_TEXT_Y + 10) && 
                     ((x - (GAME_OVER_TEXT_X + 2*LETTER_WIDTH + 2*LETTER_SPACING) <= y - GAME_OVER_TEXT_Y) || 
                      (GAME_OVER_TEXT_X + 3*LETTER_WIDTH + 2*LETTER_SPACING - x <= y - GAME_OVER_TEXT_Y))));
    
    wire e_letter = game_over && 
                   (GAME_OVER_TEXT_X + 3*LETTER_WIDTH + 3*LETTER_SPACING <= x) && 
                   (x < GAME_OVER_TEXT_X + 4*LETTER_WIDTH + 3*LETTER_SPACING) &&
                   (GAME_OVER_TEXT_Y <= y) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT) &&
                   ((x < GAME_OVER_TEXT_X + 3*LETTER_WIDTH + 3*LETTER_SPACING + 5) || 
                    (y < GAME_OVER_TEXT_Y + 5) || 
                    (y >= GAME_OVER_TEXT_Y + LETTER_HEIGHT - 5) || 
                    ((y >= GAME_OVER_TEXT_Y + LETTER_HEIGHT/2 - 2) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT/2 + 3)));
    
    wire o_letter = game_over && 
                   (GAME_OVER_TEXT_X + 5*LETTER_WIDTH + 5*LETTER_SPACING <= x) && 
                   (x < GAME_OVER_TEXT_X + 6*LETTER_WIDTH + 5*LETTER_SPACING) &&
                   (GAME_OVER_TEXT_Y <= y) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT) &&
                   ((x < GAME_OVER_TEXT_X + 5*LETTER_WIDTH + 5*LETTER_SPACING + 5) || 
                    (x >= GAME_OVER_TEXT_X + 6*LETTER_WIDTH + 5*LETTER_SPACING - 5) || 
                    (y < GAME_OVER_TEXT_Y + 5) || 
                    (y >= GAME_OVER_TEXT_Y + LETTER_HEIGHT - 5));
    
    wire v_letter = game_over && 
                   (GAME_OVER_TEXT_X + 6*LETTER_WIDTH + 6*LETTER_SPACING <= x) && 
                   (x < GAME_OVER_TEXT_X + 7*LETTER_WIDTH + 6*LETTER_SPACING) &&
                   (GAME_OVER_TEXT_Y <= y) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT) &&
                   ((x - (GAME_OVER_TEXT_X + 6*LETTER_WIDTH + 6*LETTER_SPACING) <= y - GAME_OVER_TEXT_Y) && 
                    ((GAME_OVER_TEXT_X + 7*LETTER_WIDTH + 6*LETTER_SPACING) - x <= y - GAME_OVER_TEXT_Y));
    
    wire e2_letter = game_over && 
                    (GAME_OVER_TEXT_X + 7*LETTER_WIDTH + 7*LETTER_SPACING <= x) && 
                    (x < GAME_OVER_TEXT_X + 8*LETTER_WIDTH + 7*LETTER_SPACING) &&
                    (GAME_OVER_TEXT_Y <= y) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT) &&
                    ((x < GAME_OVER_TEXT_X + 7*LETTER_WIDTH + 7*LETTER_SPACING + 5) || 
                     (y < GAME_OVER_TEXT_Y + 5) || 
                     (y >= GAME_OVER_TEXT_Y + LETTER_HEIGHT - 5) || 
                     ((y >= GAME_OVER_TEXT_Y + LETTER_HEIGHT/2 - 2) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT/2 + 3)));
    
    wire r_letter = game_over && 
                   (GAME_OVER_TEXT_X + 8*LETTER_WIDTH + 8*LETTER_SPACING <= x) && 
                   (x < GAME_OVER_TEXT_X + 9*LETTER_WIDTH + 8*LETTER_SPACING) &&
                   (GAME_OVER_TEXT_Y <= y) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT) &&
                   ((x < GAME_OVER_TEXT_X + 8*LETTER_WIDTH + 8*LETTER_SPACING + 5) || 
                    (y < GAME_OVER_TEXT_Y + 5) || 
                    ((x >= GAME_OVER_TEXT_X + 9*LETTER_WIDTH + 8*LETTER_SPACING - 5) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT/2)) || 
                    ((y >= GAME_OVER_TEXT_Y + LETTER_HEIGHT/2 - 2) && (y < GAME_OVER_TEXT_Y + LETTER_HEIGHT/2 + 3)) || 
                    ((y >= GAME_OVER_TEXT_Y + LETTER_HEIGHT/2) && 
                     (y <= GAME_OVER_TEXT_Y + LETTER_HEIGHT/2 + (x - (GAME_OVER_TEXT_X + 8*LETTER_WIDTH + 8*LETTER_SPACING)))));
    
    // Combined text output
    assign text_on = g_letter || a_letter || m_letter || e_letter || 
                    o_letter || v_letter || e2_letter || r_letter;

endmodule