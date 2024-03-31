module controlUnit (
        input wire clk,
        input wire [5:0] opcode,
        input wire isStackEmpty,
        input wire isStackFull,
		input wire isMemoEmpty,
        input wire isMemoFull,
        input wire NegFlagIn,
        input wire ZeroFlagIn,
        input wire CarryFlagIn,
		input wire greaterThanFlagIn,
		input wire lessThanFlagIn,
        output reg EN,
		output reg IRWR,
        output reg MemoR,
        output reg MemoWR,
		output reg pop,
		output reg push,
        output reg MemoToRF,
        output reg ReadRegisterTwoSrc,
        output reg BranchFlag,
        output reg isStackAddress,
        output reg [1:0] PCSource,
        output reg [5:0] OpcodeOut,
        output reg [1:0] ALUSrcTwo,
        output reg ALUSrcOne,
        output reg RFWR,
        output reg ExtensionSrc, 
		output reg regWriteOne,
		output reg regWriteTwo,
		output reg	retFlag,
		output reg poiFlag
);

    // DEFINING THE OPCODE FOR EACH OPERATION
    
    // R-Type
    parameter AND   = 6'b000000;
    parameter ADD   = 6'b000001;
    parameter SUB   = 6'b000010;
    
    // I-Type
    parameter ANDI  = 6'b000011;
    parameter ADDI  = 6'b000100;
    parameter LW    = 6'b000101;
    parameter LWPOI    = 6'b000110;
    parameter SW    = 6'b000111;
    parameter BGT   = 6'b001000;
    parameter BLT   = 6'b001001;
	parameter BEQ   = 6'b001010;
	parameter BNE   = 6'b001011;
	
    // J-Type
    parameter J     = 6'b001100;
    parameter CALL   = 6'b001101;
    parameter RET   = 6'b001110;
	
    // S-Type
    parameter PUSH   = 6'b001111;
    parameter POP   = 6'b010000;

	
	reg [5:0] op;	  
	// DEFINING STATES TO FLIP FROM ONE INTO ANOTHER 
	reg [3:0] state = 10;
	parameter RS = 0;
	parameter IF = 1;
	parameter pID = 2;
	parameter ID = 3;
	parameter pEX = 4;
	parameter EX = 5;
	parameter pMEM = 6;
	parameter MEM = 7;
	parameter pWB = 8;
	parameter WB = 9;
	parameter start = 10;
	
	always @(posedge clk)
		begin			 
			ZeroFlagOut <= ZeroFlagIn;
			case(state)
				start: begin
					PCSource			<= 2'b10;
					isStackAddress			<= 0; 
					state <= RS;
				end
				RS:begin
					EN				<= 1;
					MemoWR			<= 0;
					IRWR				<= 1;
					push			<= 0;
					pop <= 0;
					RFWR			<= 0;
					state				<= IF;
				end							 
				IF: begin 
					EN				<= 0; 
					IRWR				<= 0; 
					op = opcode;
					state				<= ID;
					if(op == RET)
						begin
							retFlag			<= 1;
							pop <= 1;
							state				<= MEM;
						end
					else
						begin
							retFlag			<= 0;
						end
					regWriteOne					   	<= 1;
					regWriteTwo					   	<= 1;
				end							   
				ID: begin	
					op = opcode;	 
					case (op)
							// R-Type
							AND: begin
								EN            		<= 0;
								MemoR            	<= 0;  
								MemoWR           	<= 0;
								MemoToRF           	<= 1;	
								IRWR		       	<= 0;
								ReadRegisterTwoSrc  <= 0;
								
								
								PCSource  	    <= 2'b10; 
								OpcodeOut    <= 6'b000000;
								ALUSrcTwo      	<= 2'b00;
								ALUSrcOne          	<= 1;
								RFWR          		<= 0;   
								state             <= pID; 
							end							
							
							ADD: begin
								EN            		<= 0;
								MemoR            	<= 0;  
								MemoWR           	<= 0;
								MemoToRF           	<= 1;	
								IRWR		       	<= 0;
								ReadRegisterTwoSrc  <= 0;
								
								
								PCSource  	    <= 2'b10; 
								OpcodeOut    <= 6'b000001;
								ALUSrcTwo      	<= 2'b00;
								ALUSrcOne          	<= 1;
								RFWR          		<= 0;   
								state             <= pID; 
							end	
							
							SUB: begin
								EN            		<= 0;
								MemoR            	<= 0;  
								MemoWR           	<= 0;
								MemoToRF           	<= 1;	
								IRWR		       	<= 0;
								ReadRegisterTwoSrc  <= 0;
								
								
								PCSource  	    <= 2'b10; 
								OpcodeOut    <= 6'b000010;
								ALUSrcTwo      	<= 2'b00;
								ALUSrcOne          	<= 1;
								RFWR          		<= 0;   
								state             <= pID; 
							end								  
								
							
							// LETS GO INTO I-Type :)
							ANDI: begin
								EN            		<= 0;
								MemoR            	<= 0;  
								MemoWR           	<= 0;
								MemoToRF           	<= 1;	
								IRWR		       	<= 0;
								
								
								PCSource  	    <= 2'b10; 
								OpcodeOut    <= 6'b000011;
								ALUSrcTwo      	<= 2'b10;
								ALUSrcOne          	<= 1;
								RFWR          		<= 0;
								ExtensionSrc		   <= 1;
								state             <= pID; 
							end	  
							
							ADDI: begin
								EN            		<= 0;
								MemoR            	<= 0;  
								MemoWR           	<= 0;
								MemoToRF           	<= 1;	
								IRWR		       	<= 0;
								
								
								PCSource  	    <= 2'b10; 
								OpcodeOut    <= 6'b000100;
								ALUSrcTwo      	<= 2'b10;
								ALUSrcOne          	<= 1;
								RFWR          		<= 0;
								ExtensionSrc		   <= 0;
								state             <= pID; 
							end	 
							
							LW: begin
								EN            <= 0;
								MemoR            <= 1;  
								MemoWR           <= 0;
								pop           <= 0;
								push           <= 0;
								MemoToRF           <= 0;	
								IRWR		       <= 0;
								
								
								PCSource  	       <= 2'b10; 
								OpcodeOut    <= 6'b000101;
								ALUSrcTwo            <= 2'b10;
								ALUSrcOne            <= 1;
								RFWR           <= 0; 
								ExtensionSrc		   <= 0;
								state              <= pID; 
							end
							
							LWPOI: begin
								EN            <= 0;
								MemoR            <= 1;  
								MemoWR           <= 0;
								pop           <= 0;
								push           <= 0;
								MemoToRF           <= 0;	
								IRWR		       <= 0;
								
								
								PCSource  	       <= 2'b10; 
								OpcodeOut    <= 6'b000110;
								ALUSrcTwo            <= 2'b10;
								ALUSrcOne            <= 1;
								RFWR           <= 0; 
								ExtensionSrc		   <= 0;
								state              <= pID; 
							end
							
							SW: begin
								EN            <= 0;
								MemoR            <= 0;  
								MemoWR           <= 1;
								pop           <= 0;
								push           <= 0;
								ReadRegisterTwoSrc           <= 1;	
								IRWR		       <= 0;
								
								
								PCSource  	       <= 2'b10; 
								OpcodeOut    <= 6'b000111;
								ALUSrcTwo            <= 2'b10;
								ALUSrcOne            <= 1;
								RFWR           <= 0; 
								ExtensionSrc		   <= 0;
								state              <= pID; 
							end	  
							
							BGT: begin
								EN            <= 0;
								MemoR            <= 0;  
								MemoWR           <= 0;
								pop           <= 0;
								push           <= 0;
								IRWR		       <= 0;
								ReadRegisterTwoSrc   <= 1;
								PCSource  	       <= 2'b11; 
								OpcodeOut    <= 6'b001000;
								ALUSrcTwo            <= 2'b00;
								ALUSrcOne            <= 1;
								RFWR           <= 0;
								ExtensionSrc		   <= 0;   	 	
								state              <= pID; 
							end
							
							BLT: begin
								EN            <= 0;
								MemoR            <= 0;  
								MemoWR           <= 0;
								pop           <= 0;
								push           <= 0;
								IRWR		       <= 0;
								ReadRegisterTwoSrc   <= 1;
								PCSource  	       <= 2'b11; 
								OpcodeOut    <= 6'b001001;
								ALUSrcTwo            <= 2'b00;
								ALUSrcOne            <= 1;
								RFWR           <= 0;
								ExtensionSrc		   <= 0;   	 	
								state              <= pID; 
							end
							
							BEQ: begin
								EN            <= 0;
								MemoR            <= 0;  
								MemoWR           <= 0;
								pop           <= 0;
								push           <= 0;
								IRWR		       <= 0;
								ReadRegisterTwoSrc   <= 1;
								PCSource  	       <= 2'b11; 
								OpcodeOut    <= 6'b001010;
								ALUSrcTwo            <= 2'b00;
								ALUSrcOne            <= 1;
								RFWR           <= 0;
								ExtensionSrc		   <= 0;   	 	
								state              <= pID; 
							end
							
							BNE: begin
								EN            <= 0;
								MemoR            <= 0;  
								MemoWR           <= 0;
								pop           <= 0;
								push           <= 0;
								IRWR		       <= 0;
								ReadRegisterTwoSrc   <= 1;
								PCSource  	       <= 2'b11; 
								OpcodeOut    <= 6'b001011;
								ALUSrcTwo            <= 2'b00;
								ALUSrcOne            <= 1;
								RFWR           <= 0;
								ExtensionSrc		   <= 0;   	 	
								state              <= pID; 
							end
								
							// NOW LETS GO INTO J-Type :)
							
							JMP: begin
								EN            <= 0;
								MemoR            <= 0;  
								MemoWR           <= 0;
								pop           <= 0;
								push           <= 0;
								MemoToRF           <= 0;	
								IRWR		       <= 0;
								PCSource  	       <= 2'b00; 
								OpcodeOut    <= 6'b001100;
								ALUSrcTwo            <= 2'b01;
								ALUSrcOne            <= 0;
								RFWR           <= 0;  
								state              <= pID; 
							end
								
							CALL: begin
								EN            <= 0;
								MemoR            <= 0;  
								MemoWR           <= 0;
								pop           <= 0;
								push           <= 0;
								MemoToRF           <= 0;	
								IRWR		       <= 0;
								PCSource  	       <= 2'b00; 
								OpcodeOut    <= 6'b001101;
								ALUSrcTwo            <= 2'b01;
								ALUSrcOne            <= 0;
								RFWR           <= 0;   
								state              <= pID; 
							end
							
							//RET: begin
//								EN            <= 0;
//								MemoR            <= 0;  
//								MemoWR           <= 0;
//								pop           <= 0;
//								push           <= 0;
//								MemoToRF           <= 0;	
//								IRWR		       <= 0;
//								PCSource  	       <= 2'b00; 
//								OpcodeOut    <= 6'b001110;
//								ALUSrcTwo            <= 2'b01;
//								ALUSrcOne            <= 0;
//								RFWR           <= 0;   
//								state              <= pID; 
//							end
							
							// S-Type's TURN
							PUSH: begin
								EN            <= 0;
								MemoR            <= 0;  
								MemoWR           <= 0;
								pop           <= 0;
								push           <= 1;
								//MemoToRF           <= 0;	
								IRWR		       <= 0;
								PCSource  	       <= 2'b10; 
								OpcodeOut    <= 6'b001111;
								//ALUSrcTwo            <= 2'b01;
								//ALUSrcOne            <= 0;
								RFWR           <= 0;
								retFlag <= 0;
								state              <= MEM; 
							end
								
							POP: begin
								EN            <= 0;
								MemoR            <= 0;  
								MemoWR           <= 0;
								pop           <= 1;
								push           <= 0;
								MemoToRF           <= 0;	
								IRWR		       <= 0;
								PCSource  	       <= 2'b00; 
								OpcodeOut    <= 6'b010000;
								//ALUSrcTwo            <= 2'b01;
								//ALUSrcOne            <= 0;
								RFWR           <= 0;   
								state              <= MEM; 
							end
									
					endcase	   	
				end
				pID: begin
					 regWriteOne		   <= 0;
					 regWriteTwo		   <= 0;
					 state              <= EX;
				end
				

				EX: begin
					if((op == BGT) && greaterThanFlagIn)
						begin
							BranchFlag			<= 1;
						end
					else
						begin
							BranchFlag			<= 0;
						end
					if((op == BLT) && lessThanFlagIn)
						begin
							BranchFlag			<= 1;
						end
					else
						begin
							BranchFlag			<= 0;
						end
					if((op == BEQ) && zeroFlagIn)
						begin
							BranchFlag			<= 1;
						end
					else
						begin
							BranchFlag			<= 0;
						end
					if((op == BNE) && !zeroFlagIn)
						begin
							BranchFlag			<= 1;
						end
					else
						begin
							BranchFlag			<= 0;
						end
                    case (op)
                        AND: begin
                            state                  <= pWB;
                        end
                        ADD: begin
                            state                  <= pWB;
                        end
                        SUB: begin
                            state                  <= pWB;
                        end
                        ANDI: begin
                            state                  <= pWB;
                        end
                        ADDI: begin
                            state                  <= pWB;
                        end
                        LW: begin
                            state                  <= MEM;
						LWPOI: begin
                            state                  <= MEM;
                        end
                        SW: begin
                            state                  <= MEM;
                        end
                        BGT: begin
                            state                  <= RS;
                        end
						BLT: begin
                            state                  <= RS;
                        end
						BEQ: begin
                            state                  <= RS;
                        end
						BNE: begin
                            state                  <= RS;
                        end
                        J: begin
                            state                  <= RS;
                        end
                        CALL: begin
							push         	   	   <= 1;
                            state                  <= MEM;
                        end
//						RET: begin
//							pop         	   	   <= 1;
//                            state                  <= MEM;
//                        end
                    	endcase	
					end
                    MEM: begin 
					regWriteOne		   			   <= 0;
					regWriteTwo		   			   <= 0;  
                    case(op)
                        LW: begin
                            state                  <= pWB;
                        end
						LWPOI: begin
							poiFlag					<= 1;
                            state                  <= pWB;
                        end
                        SW: begin
                            state                  <= RS;
                        end
						CALL: begin
                            state                  <= RS;
                        end
						RET: begin
							//pop         	   	   <= 1;
							isStackAddress		   <= 1;
                            state                  <= RS;
                        end
						PUSH: begin
							//push         	   	   <= 1;
							isStackAddress		   <= 1;
                            state                  <= RS;
                        end
						POP: begin
							//pop         	   	   <= 1;
                            state                  <= pWB;
                        end
                    endcase
					end
					pWB: begin
						RFWR           		   <= 1;
						state <= WB;
					end
					
			

                    WB: begin
					RFWR           			   <= 1;
					regWriteOne					   <= 0;
					regWriteTwo		   			   <= 0;
                    state                 		   <= RS;
					end
					
			endcase	 
			end

endmodule

