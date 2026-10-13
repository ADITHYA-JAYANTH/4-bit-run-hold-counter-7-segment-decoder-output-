`timescale 1ns/1ps
module tb_run_hold_counter;
    reg        clk = 0, reset = 0, run = 0;
    wire [3:0] count;
    wire [6:0] seg;
    run_hold_counter dut (.clk(clk), .reset(reset), .run(run), .count(count), .seg(seg));

    always #5 clk = ~clk;

    integer faults = 0;
    reg [3:0] snap;
    integer k;

    // independent reference of the 7-seg table (case form)
    function [6:0] ref_seg(input [3:0] v);
        case (v)
            4'h0: ref_seg = 7'b1111110; 4'h1: ref_seg = 7'b0110000;
            4'h2: ref_seg = 7'b1101101; 4'h3: ref_seg = 7'b1111001;
            4'h4: ref_seg = 7'b0110011; 4'h5: ref_seg = 7'b1011011;
            4'h6: ref_seg = 7'b1011111; 4'h7: ref_seg = 7'b1110000;
            4'h8: ref_seg = 7'b1111111; 4'h9: ref_seg = 7'b1111011;
            4'hA: ref_seg = 7'b1110111; 4'hB: ref_seg = 7'b0011111;
            4'hC: ref_seg = 7'b1001110; 4'hD: ref_seg = 7'b0111101;
            4'hE: ref_seg = 7'b1001111; default: ref_seg = 7'b1000111;
        endcase
    endfunction

    task expect_cnt(input [3:0] want, input [127:0] tag);
        begin
            #1;
            if (count !== want) begin
                faults = faults + 1;
                $display("FAIL %0s: count=%h expected=%h", tag, count, want);
            end
            if (seg !== ref_seg(count)) begin
                faults = faults + 1;
                $display("FAIL %0s: seg=%b for count=%h expected=%b", tag, seg, count, ref_seg(count));
            end
        end
    endtask

    // drive inputs just after the rising edge, check just after the next one
    task tick; begin @(posedge clk); #1; end endtask

    initial begin
        $dumpfile("run_hold.vcd"); $dumpvars(0, tb_run_hold_counter);

        // --- synchronous reset ---
        reset = 1; run = 1; tick; expect_cnt(4'h0, "reset");
        tick; expect_cnt(4'h0, "reset-held-with-run");
        reset = 0; run = 0;

        // --- HOLD at 0 ---
        repeat (3) begin tick; expect_cnt(4'h0, "hold@0"); end

        // --- RUN: counts +1 each edge ---
        run = 1;
        for (k = 1; k <= 5; k = k + 1) begin tick; expect_cnt(k[3:0], "run-up"); end

        // --- HOLD keeps value ---
        run = 0; snap = count;
        repeat (4) begin tick; expect_cnt(snap, "hold@5"); end

        // --- resume ---
        run = 1; tick; expect_cnt(snap + 4'd1, "resume");

        // --- full wrap: run through 16+ edges, checking every value incl. F->0 ---
        for (k = 0; k < 20; k = k + 1) begin
            snap = count; tick; expect_cnt(snap + 4'd1, "wrap-sweep");
            if (snap == 4'hF && count !== 4'h0) begin
                faults = faults + 1; $display("FAIL: no wrap F->0");
            end
        end

        // --- hold exactly at F, then wrap on resume ---
        while (count !== 4'hF) begin tick; #1; end
        run = 0; repeat (3) begin tick; expect_cnt(4'hF, "hold@F"); end
        run = 1; tick; expect_cnt(4'h0, "F->0 wrap");

        // --- reset mid-count ---
        repeat (7) tick; #1; reset = 1; tick; expect_cnt(4'h0, "mid-reset"); reset = 0;

        // --- run toggling every cycle ---
        for (k = 0; k < 8; k = k + 1) begin
            run = k[0]; snap = count; tick;
            expect_cnt(run ? snap + 4'd1 : snap, "toggle-run");
        end

        if (faults == 0) $display("PASS: all checks passed");
        else             $display("FAILED: %0d error(s)", faults);
        $finish;
    end
endmodule
