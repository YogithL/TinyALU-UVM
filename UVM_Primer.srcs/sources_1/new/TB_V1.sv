`timescale 1ns / 1ps
import tinyalu_pkg::*;

function operation_e getOp();
    operation_e op;
    
    std::randomize(op) with
    {
        op dist
        {
            no_op  := 2,
            rst_op := 2,
            add_op := 1,
            and_op := 1,
            xor_op := 1,
            mul_op := 1
        };
    };
    
    return op;
endfunction: getOp



function bit[7:0] getData();
    bit[7:0] data;
    
    std::randomize(data) with
    {
        data dist
        {
            8'h00 := 10, 
            8'h01 := 10, 
            8'hFF := 10, 
            [8'h02:8'hFE] := 1    
        };
   };
    
   return data;
endfunction: getData
    
    

module top();
    byte unsigned A;
    byte unsigned B;
    bit clk;
    bit reset_n;
    bit start;
    operation_e op_set;
    
    wire[2:0] op;
    wire done;
    wire[15:0] result;
    
    assign op = op_set;
    
    TinyALU DUT (.clk(clk),
                 .reset_n(reset_n), 
                 .start(start), 
                 .op(op), 
                 .a(A), 
                 .b(B), 
                 .done(done),
                 .result(result));
    
    //Creating Covergroups         
    covergroup opcodes; 
        cp_op: coverpoint op_set
        {
            bins singleCycle[] = {no_op, add_op, and_op, xor_op, rst_op};
            bins multiCycle = {mul_op};
        }
    endgroup

    covergroup cornerCases;
        all_ops: coverpoint op_set
        {
            ignore_bins all_ops = {no_op, rst_op};
        }
        
        a_leg: coverpoint A
        {
            bins zeros = {8'h00};
            bins ones = {8'hFF}; 
            bins others = {[8'h01: 8'hFE]};
        }
        
        b_leg: coverpoint B
        {
            bins zeros = {8'h00};
            bins ones = {8'hFF}; 
            bins others = {[8'h01: 8'hFE]};
        }
    endgroup
    
    //Utilizing Covergroups
    opcodes opcodes_cg;
    cornerCases cornerCases_cg;
    
    initial begin: coverage
        opcodes_cg = new();
        cornerCases_cg = new();
        
        forever begin @(negedge clk)
            opcodes_cg.sample();
            cornerCases_cg.sample();
        end
    end: coverage
    
    //Tester Block
    always begin
        #5 clk = 1;
        #5 clk = 0;
    end
    
    initial begin: tester
        reset_n = 1'b0;
        repeat(2) @(negedge clk);
        reset_n = 1'b1;
        
        start = 1'b0;
        repeat(1000) begin
            @(negedge clk);
            op_set = getOp();
            A = getData();
            B = getData();
            start = 1'b1;
            
            case(op_set)
                no_op: begin
                    @(posedge clk);
                    start = 1'b0;
                end
                
                rst_op: begin
                    start = 1'b0;
                    reset_n = 1'b0;
                    @(negedge clk);
                    reset_n = 1'b1;
                end
                
                default: begin
                    wait(done);
                    start = 1'b0;
                end
             endcase
         end     
         $display("Simulation Finished!");
         $finish;           
    end: tester
    
    //Scoreboard
    always @(posedge done) begin
        bit signed[15:0] prediction;
           case(op_set)                    
              add_op: prediction = A + B;          
              and_op: prediction = A & B;  
              xor_op: prediction = A ^ B;  
              mul_op: prediction = A * B;  
           endcase                        

        if((op_set != rst_op) && (op_set != no_op)) begin
            if(prediction != result) begin
                $error ("Failed: A: %0h | B: %0h | OP: %s | Result: %0h", 
                        A, B, op_set.name(), result);
            end
        end
     end
    
endmodule












