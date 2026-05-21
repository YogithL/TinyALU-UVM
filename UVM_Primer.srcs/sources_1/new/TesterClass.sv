import tinyalu_pkg::*;

class TesterClass;
    virtual tinyalu_bfm bfm;
    
    function new(virtual tinyalu_bfm b);
        bfm = b;
    endfunction
    
    function getData();
        byte data;
        
        std::randomize(data) with
        {
            data dist
            {
                8'h00 := 10,
                8'h01 := 10,
                8'hFF := 10,
                [8'h02: 8'hFE] := 10
            };
        };
    endfunction
    
    function getOp();
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
    
    task exec();
        reset_alu();

        repeat (1000) begin
            @(negedge bfm.clk);
            bfm. sendOp(getData(), getData(), getOp(), bfm.result);
        end
        
    endtask
        
endclass
