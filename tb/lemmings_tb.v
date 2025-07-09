`timescale 1ns/1ns
`include "lemmings.v"

module lemmings_tb ();

	reg CLK, ARESET;
	reg BUMP_LEFT, BUMP_RIGHT, GROUND, DIG;

	wire WALK_LEFT, WALK_RIGHT, AAAH, DIGGING;
	
	reg [8:0] delay, delay2, delay3, delay4;

	integer i;

	lemmings UUT (	
			.clk(CLK),
			.areset(ARESET),
			.bump_left(BUMP_LEFT),
			.bump_right(BUMP_RIGHT),
			.ground(GROUND),
			.dig(DIG),
			.walk_left(WALK_LEFT),
			.walk_right(WALK_RIGHT),
			.aaah(AAAH),
			.digging(DIGGING)		);

	always #10 CLK <= !CLK;

	initial begin
		init();

		a_rst();
		bump_test(); //last input change on 180

		a_rst();
		fall_test(); //380

		a_rst();
		dig_test(); //580

		a_rst();
		splat_test(); //1040	

/*
		a_rst();
		rand_test(); //optional random testing
*/

		#40
		$stop();	
	
	end

	task init();
		begin
			CLK <= 1'b0;
			BUMP_LEFT <= 1'b0;
			BUMP_RIGHT <= 1'b0;
			GROUND <= 1'b1;	
			DIG <= 1'b0;	
		end	
	endtask
	
	task a_rst();
		begin
			@(negedge CLK);
			ARESET <= 1'b1;
			#20 ARESET <= 1'b0;
		end
	endtask

	task bump_test();
		begin
			#20 BUMP_LEFT <= 1'b1;

			#40 BUMP_LEFT <= 1'b0;
			BUMP_RIGHT <= 1'b1;
			
			#40 BUMP_LEFT <= 1'b1;

			#60 BUMP_RIGHT <= 1'b0; 
			BUMP_LEFT <= 1'b0;
		end
	endtask

	task fall_test();
		begin
			#20 GROUND <= 1'b0;
			
			#20 BUMP_LEFT <= 1'b1;
			#20 BUMP_LEFT <= 1'b0;
			
			#20 GROUND <= 1'b1;
			BUMP_LEFT <= 1'b1;

			#40 GROUND <= 1'b0;
			BUMP_LEFT <= 1'b0;

			#60 GROUND <= 1'b1;
		end
	endtask

	task dig_test();
		begin
			#20 DIG <= 1'b1;
			#20 DIG <= 1'b0;

			#20 BUMP_LEFT <= 1'b1;
			#20 BUMP_LEFT <= 1'b0;
				
			#20 GROUND <= 1'b0;

			#40 DIG <= 1'b1;
			#20 DIG <= 1'b0;

			#20 GROUND <= 1'b1;
		end
	endtask

	task splat_test();
		begin
			#20 GROUND <= 1'b0;

			#420 GROUND <= 1'b1; //assign on the 21st cycle
			repeat(3) @(posedge CLK);
		end
	endtask

	task rand_test();
			for (i=0; i<10; i=i+1) begin
				delay = {$random} % 128;
				delay2 = {$random} % 128;
				delay3 = {$random} % 128;
				delay4 = {$random} % 128;

				$display("Loop %0d",i);

				fork
					begin
						$display("At time %0t, Bump left delay is %0d",$time,delay);
						#(delay) BUMP_LEFT <= ~BUMP_LEFT;
					end

					begin
						$display("At time %0t, Bump right delay is %0d",$time,delay2);
						#(delay2) BUMP_RIGHT <= ~BUMP_RIGHT;
					end

					begin
						$display("At time %0t, Ground delay is %0d",$time,delay3);
						#(delay3) GROUND <= ~GROUND;
					end

					begin
						$display("At time %0t, Dig delay is %0d",$time,delay4);
						#(delay4) DIG <= ~DIG;
					end
				join
			end
	endtask

endmodule
