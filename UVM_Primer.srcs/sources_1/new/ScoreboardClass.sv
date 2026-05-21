import tinyalu_pkg::*;

class scoreboardClass;

    virtual tinyalu_bfm bfm;
    
    task exec();
        bit signed[15:0] prediction;
        
        forever begin
            case(bfm.op_set)
                add_op: prediction = bfm.A + bfm.B;
                and_op: prediction = bfm.A & bfm.B;
                xor_op: prediction = bfm.A ^ bfm.B;
                mul_op: prediction = bfm.A * bfm.B;  
            endcase
        end
    
        forever begin
            @(posedge bfm.done);
            if(prediction != bfm.result && bfm.op_set != no_op && bfm.op_set != rst_op) begin
                $error("Failed: A: %0h | B: %0h | OP: %s | Result: %0h", 
                        bfm.A, bfm.B, bfm.op_set.name(), bfm.result); 
            end
        end
    endtask: exec
    
    function new(virtual tinyalu_bfm b);
        bfm = b;
    endfunction
    
endclass





