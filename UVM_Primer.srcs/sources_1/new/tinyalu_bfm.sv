interface tinyalu_bfm;
    import tinyalu_pkg::*;
    
    byte unsigned A;
    byte unsigned B;
    bit clk;
    bit reset_n;
    bit start;
    operation_e op_set;
    
    wire[2:0] op;
        assign op = op_set;
    wire done;
    wire[15:0] result;
    

    task reset_alu();
        reset_n = 1'b0;
        @(negedge clk);        
        @(negedge clk);
        reset_n = 1'b1;
        start = 1'b0;
    endtask: reset_alu
    
    task sendOp(input byte iA, input byte iB, 
                input operation_e iop, 
                output shortint alu_result);
        
        op_set = operation_e'(iop);
        
        if(op == rst_op) begin
            @(posedge clk);
            reset_n = 1'b0;
            start = 1'b0;
            
            @(posedge clk);
            #1
            reset_n = 1'b1;
        end
        
        else begin
            @(negedge clk);
            A = iA;
            B = iB;
            start = 1'b1;
            
            if(iop == no_op) begin
                @(posedge clk);
                #1;
                start = 1'b0;
            end
            
            else begin
                @(negedge clk);
                while (done == 0);
                alu_result = result;
                start = 1'b0;
            end
        end
    endtask: sendOp

endinterface       
        






