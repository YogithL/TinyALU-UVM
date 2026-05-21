import tinyalu_pkg::*;

class testbench;
    virtual tinyalu_bfm bfm;
    
    CoverageClass covererage;
    ScoreboardClass scoreboard;
    TesterClass tester;
    
    function new(virtual tinyalu_bfm b);
        bfm = b;
    endfunction
    
    task exec();
        covererage = new(bfm);
        scoreboard = new(bfm);
        tester = new(bfm);
        
        fork
            tester.exec();
            covererage.exec();
            scoreboard.exec();
        join_none
   endtask
endclass

module top3();
    tinyalu_bfm bfm();
    
    always begin
        #5 bfm.clk = 1'b1;
        #5 bfm.clk = 1'b0;
    end
    
    tinyalu DUT(.A(bfm.A), .B(bfm.B), .op(bfm.op), 
                .clk(bfm.clk), .reset_n(bfm.reset_n), 
                .start(bfm.start), .done(bfm.done), .result(bfm.result));
                
    testbench testbench_h;
    
    initial begin
        testbench_h = new(bfm);
        testbench_h.execute();
        
        #5000;
        $finish;
    end

endmodule


    
    
    
    













endclass
