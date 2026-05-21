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

module coverage(tinyalu_bfm bfm);
    import tinyalu_pkg::*;
    
    byte unsigned A;
    byte unsigned B;
    operation_t  op_set;

    
    covergroup op_cov;
        opcodes: coverpoint op_set
        {
            bins single_cycle[] = {[add_op : xor_op], rst_op, no_op};
            bins multi_cycle[] = {mul_op};
            
            bins rst_opn[] = (rst_op => [add_op : xor_op]); 
            bins noop_opn[] = (no_op => [add_op : xor_op]);
        }
    endgroup: op_cov
    
    covergroup corner_cases;
        all_ops: coverpoint op_set
        {
            ignore_bins null_ops = {rst_op, no_op};
        }
        
        aValues: coverpoint A
        {
            bins corners[] = {8'h00, 8'hFF};
            bins ones = {8'h01};
            bins others = default;
        }
        
        bValues: coverpoint B
        {
            bins corners[] = {8'h00, 8'hFF};
            bins ones = {8'h01};
            bins others = default;
        }
        
        maxTest: cross aValues, bValues, all_ops
        {
            ignore_bins a_not_max = binsof(aValues) intersect {['h00:'hFE]};
            ignore_bins b_not_max = binsof(bValues) intersect {['h00:'hFE]};        
        }
    endgroup: corner_cases
    
    op_cov opCov;
    corner_cases Corner;
    
    initial begin: coverageblock;
        opCov = new();
        Corner = new();
        
        forever @(negedge bfm.clk) begin
            A = bfm.A;
            B = bfm.B;
            op_set = bfm.op_set;
            
            opCov.sample();
            Corner.sample();
        end
    end: coverageblock

endmodule: coverage



module tester(tinyalu_bfm bfm);
    import tinyalu_pkg::*;
    
    function byte getData();
    
        byte data;
        std::randomize(data) with
        {
            data dist
            {
                8'h00 := 10,
                8'h01 := 10,
                8'hFF := 10,
                [8'h02 : 8'h01] := 1
            };
        };
    endfunction
    
    function operation_e getOp();
        operation_e op;
        
        std::randomize(op) with
        {
            op dist
            {
                no_op := 2,
                rst_op := 2,
                add_op := 1,
                and_op := 1,
                xor_op := 1,
                mul_op := 1
            };
        };
    endfunction
    
    initial begin: tester
        byte iA;
        byte iB;
        operation_e iop;
        
        reset_alu();
        repeat (1000) begin
            iA = getData();
            iB = getData();
            iop = getOp();
            bfm.send_op(iA, iB, iop, bfm.result);
        end
    end
endmodule: tester



module top2();

   tinyalu_bfm bfm();
   tester tester_i (bfm);
   coverage coverage_i (bfm);
   scoreboard scoreboard_i(bfm);
   
   tinyalu DUT(.A(bfm.A), .B(bfm.B), .op(bfm.op), 
                .clk(bfm.clk), .reset_n(bfm.reset_n), 
                .start(bfm.start), .done(bfm.done), .result(bfm.result));
endmodule: top2

    


            
                
    
            







