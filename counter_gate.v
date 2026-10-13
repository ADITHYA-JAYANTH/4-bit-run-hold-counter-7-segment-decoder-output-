// 4-bit counter steered by a 2-state Moore FSM (RUN / HOLD) + 7-seg output.
// Gate-level: all combinational logic is built from not/and/or/xor primitives.
// Only the D flip-flops themselves are behavioral (primitives cannot make a flop).
//  - Incrementer is a toggle-chain: bit i flips when all lower bits are 1
//  - A 2:1 mux (select = run) picks {count+1} or {count} for the D inputs
//  - Synchronous active-high reset is folded into D with an AND against ~reset
module run_hold_counter (
    input  wire       clk,
    input  wire       reset,
    input  wire       run,
    output wire [3:0] count,
    output wire [6:0] seg
);
    wire nrst, nrun;
    not g_nrst (nrst, reset);
    not g_nrun (nrun, run);

    // ---------------- Moore FSM state (0 = HOLD, 1 = RUN) ----------------
    wire mode_d;
    reg  mode_q;
    and g_mode (mode_d, run, nrst);
    always @(posedge clk) mode_q <= mode_d;

    // ---------------- toggle-chain incrementer ----------------
    reg  [3:0] tally;
    assign count = tally;

    wire c1, c2, c3;                       // carry into bits 1,2,3
    buf  k1 (c1, tally[0]);
    and  k2 (c2, tally[0], tally[1]);
    and  k3 (c3, tally[0], tally[1], tally[2]);

    wire [3:0] inc;
    not  x0 (inc[0], tally[0]);            // bit0 always toggles
    xor  x1 (inc[1], tally[1], c1);
    xor  x2 (inc[2], tally[2], c2);
    xor  x3 (inc[3], tally[3], c3);

    // ---------------- 2:1 mux (select = run) ----------------
    wire [3:0] pick_inc, pick_hold, nxt, dval;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : lane
            and m1 (pick_inc[i],  inc[i],   run);
            and m2 (pick_hold[i], tally[i], nrun);
            or  m3 (nxt[i], pick_inc[i], pick_hold[i]);
            and m4 (dval[i], nxt[i], nrst);       // synchronous reset
        end
    endgenerate

    always @(posedge clk) tally <= dval;

    // ---------------- Display ----------------
    hex_seg_rom u_rom (.nib(tally), .lamps(seg));
endmodule
