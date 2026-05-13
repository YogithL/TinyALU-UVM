module scoreboard(tinyalu_bfm bfm);
    import tinyalu_pkg::*;
    
    always @(posedge bfm.done) begin
        bit signed[15:0] prediction;
        
        case(bfm.op_set)
            add_op: prediction = bfm.A + bfm.B;
            and_op: prediction = bfm.A & bfm.B;
            xor_op: prediction = bfm.A ^ bfm.B;
            mul_op: prediction = bfm.A * bfm.B;  
        endcase
        
        if((bfm.op_set != rst_op) && (bfm.op_set != no_op)) begin
            if(prediction != bfm.result) begin
                $error ("Failed: A: %0h | B: %0h | OP: %s | Result: %0h", 
                        bfm.A, bfm.B, bfm.op_set.name(), bfm.result);
            end
        end
    end
endmodule: scoreboard

module tester()


            







