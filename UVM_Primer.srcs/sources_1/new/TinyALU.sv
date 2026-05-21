import tinyalu_pkg::*;

module TinyALU(
    input logic clk,
    input logic reset_n,
    input logic start,
    input logic[2:0] op,
    input logic[7:0] a, b,
    output logic done,
    output logic[15:0] result
    );
    
    logic[1:0] count;
    
    always_ff @(posedge clk) begin
        if(!reset_n) begin
            done <= 1'b0;
            result <= 16'b0;
            count <= 2'b0;
        end
        
        else if(start) begin
            done <= 1'b0;
            
            case(op)
                no_op: begin 
                    result <= result; 
                end
                
                add_op: begin 
                    result <= a + b;
                    done <= 1'b1;
                end
                
                and_op: begin
                    result <= a & b;
                    done <= 1'b1;
                end
                
                xor_op: begin
                    result <= a ^ b;
                    done <= 1'b1;
                end
                
                rst_op: begin 
                    result <= 16'b0;
                    done <= 1'b1; 
                end
                
                mul_op: begin
                    if(count == 2'd2) begin
                        result <= a * b; 
                        count <= 0;  
                        done <= 1'b1;  
                    end
                                    
                    else 
                        count <= count + 1;
                end
                
                default: done <= 1'b0;
            endcase            
        end
        
        else count <= 2'b0;
    end
    
endmodule
























