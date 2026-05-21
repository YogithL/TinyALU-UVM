import tinyalu_pkg::*;

class coverage;
    virtual tinyalu_bfm bfm;
    
    byte unsigned A;
    byte unsigned B;
    operation_e opset;
    
    covergroup aluOpps;
        
        coverpoint opset
        {
            bins simpleCheck[] = {[add_op : mul_op]};
            bins resetToOpp[] = (rst_op => [add_op : mul_op]);
            bins noopToOpp[] = (no_op => [add_op : mul_op]);
            bins resetnoop = (rst_op => no_op => {add_op, mul_op});
            bins nopTwo = (no_op[*2]);
            bins rstTwo = (rst_op[*2]);
        }
    endgroup
    
    covergroup data;
        
        allOpps: coverpoint opset
        {
            bins allOps[] = {[add_op : mul_op]};
        }
        
        A_leg: coverpoint A
        {
            bins zero = {8'b0};
            bins one = {8'b1};
            bins max = {8'hFF};
            bins others = default;
        }
        
        B_leg: coverpoint B
        {
            bins zero = {8'b0};
            bins one = {8'b1};
            bins max = {8'hFF};
            bins others = default;
        }
        
        cross A_leg, B_leg, allOpps
        {
            ignore_bins cornerCases = binsof(A_leg.others) || binsof(B_leg.others); 
        }
    endgroup
    
    function new(virtual tinyalu_bfm b);
        aluOpps = new();
        data = new();
        bfm = b;
    endfunction : new
    
    task exec();
      forever begin: sampling_block
         @(negedge bfm.clk);
         #1;
         A = bfm.A;
         B = bfm.B;
         opset = bfm.op_set;
         aluOpps.sample();
         data.sample();
      end: sampling_block
    endtask
endclass     






