module lemmings(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 
    
    /*binary encoding:
    Left
    Right
    Fall_Left
    Fall_Right
    Dig_Left
    Dig_Right
    Splatter_time
    Dead
    */
    parameter L=3'd0, R=3'd1, F_L=3'd2, F_R=3'd3, D_L=3'd4, D_R=3'd5, SP=3'd6, D=3'd7;
    
    reg [2:0] state, next_state;
    reg [31:0] count;
    wire [31:0] next_count;
    wire en; 

    //next-state logic
    always @(*) begin
        case ( state )
            L		:	next_state = ground ? ( dig ? D_L : ( bump_left ? R : L ) ) : F_L;
            R		:	next_state = ground ? ( dig ? D_R : ( bump_right ? L : R ) ) : F_R;
            F_L		:	next_state = ground ? L : ( ( count == 32'd19 ) ? SP : F_L );
            F_R		:	next_state = ground ? R : ( ( count == 32'd19 ) ? SP : F_R );
            D_L		:	next_state = ground ? D_L : F_L;
            D_R		:	next_state = ground ? D_R : F_R;
            SP		:	next_state = ground ? D : SP;
            D		:	next_state = D;
            default	:	next_state = L;
        endcase
    end

    //countdown till splatter time
    assign en = ( ( ( state == F_L ) | ( state == F_R ) ) & ~ground );
    assign next_count = ( en ? ( count + 1 ) : 32'b0 );

    //state flip-flops
    always @(posedge clk, posedge areset) begin
        if (areset) begin
            state <= L;
            count <= 32'b0;
        end
        else begin
            state <= next_state;
            count <= next_count;
        end
        
    end

    //output logic
    assign walk_left	=	( state == L );
    assign walk_right	=	( state == R );
    assign aaah		=	( state == F_L ) | ( state == F_R ) | ( state == SP );
    assign digging		=	( state == D_L ) | ( state == D_R );

endmodule
