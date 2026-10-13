// Gate-level hex -> 7-segment decoder (common cathode, active high)
// seg bit order: {a,b,c,d,e,f,g}  (lamps[6]=a ... lamps[0]=g)
// Each lamp is a minimised sum-of-products built only from not/and/or primitives.
module hex_seg_rom (
    input  wire [3:0] nib,
    output wire [6:0] lamps
);
    wire nb3, nb2, nb1, nb0;
    not i3 (nb3, nib[3]);
    not i2 (nb2, nib[2]);
    not i1 (nb1, nib[1]);
    not i0 (nb0, nib[0]);


    // segment a
    wire p_a0; and a_a0 (p_a0, nib[1], nib[2]);
    wire p_a1; and a_a1 (p_a1, nib[1], nb3);
    wire p_a2; and a_a2 (p_a2, nib[3], nb0);
    wire p_a3; and a_a3 (p_a3, nb0, nb2);
    wire p_a4; and a_a4 (p_a4, nib[0], nib[2], nb3);
    wire p_a5; and a_a5 (p_a5, nib[3], nb1, nb2);
    or  o_a (lamps[6], p_a0, p_a1, p_a2, p_a3, p_a4, p_a5);

    // segment b
    wire p_b0; and a_b0 (p_b0, nb0, nb2);
    wire p_b1; and a_b1 (p_b1, nb2, nb3);
    wire p_b2; and a_b2 (p_b2, nib[0], nib[1], nb3);
    wire p_b3; and a_b3 (p_b3, nib[0], nib[3], nb1);
    wire p_b4; and a_b4 (p_b4, nb0, nb1, nb3);
    or  o_b (lamps[5], p_b0, p_b1, p_b2, p_b3, p_b4);

    // segment c
    wire p_c0; and a_c0 (p_c0, nib[0], nb1);
    wire p_c1; and a_c1 (p_c1, nib[0], nb3);
    wire p_c2; and a_c2 (p_c2, nib[2], nb3);
    wire p_c3; and a_c3 (p_c3, nib[3], nb2);
    wire p_c4; and a_c4 (p_c4, nb1, nb3);
    or  o_c (lamps[4], p_c0, p_c1, p_c2, p_c3, p_c4);

    // segment d
    wire p_d0; and a_d0 (p_d0, nib[3], nb1);
    wire p_d1; and a_d1 (p_d1, nib[0], nib[1], nb2);
    wire p_d2; and a_d2 (p_d2, nib[0], nib[2], nb1);
    wire p_d3; and a_d3 (p_d3, nib[1], nib[2], nb0);
    wire p_d4; and a_d4 (p_d4, nb0, nb2, nb3);
    or  o_d (lamps[3], p_d0, p_d1, p_d2, p_d3, p_d4);

    // segment e
    wire p_e0; and a_e0 (p_e0, nib[1], nib[3]);
    wire p_e1; and a_e1 (p_e1, nib[2], nib[3]);
    wire p_e2; and a_e2 (p_e2, nib[1], nb0);
    wire p_e3; and a_e3 (p_e3, nb0, nb2);
    or  o_e (lamps[2], p_e0, p_e1, p_e2, p_e3);

    // segment f
    wire p_f0; and a_f0 (p_f0, nib[1], nib[3]);
    wire p_f1; and a_f1 (p_f1, nib[2], nb0);
    wire p_f2; and a_f2 (p_f2, nib[3], nb2);
    wire p_f3; and a_f3 (p_f3, nb0, nb1);
    wire p_f4; and a_f4 (p_f4, nib[2], nb1, nb3);
    or  o_f (lamps[1], p_f0, p_f1, p_f2, p_f3, p_f4);

    // segment g
    wire p_g0; and a_g0 (p_g0, nib[0], nib[3]);
    wire p_g1; and a_g1 (p_g1, nib[1], nb0);
    wire p_g2; and a_g2 (p_g2, nib[1], nb2);
    wire p_g3; and a_g3 (p_g3, nib[3], nb2);
    wire p_g4; and a_g4 (p_g4, nib[2], nb1, nb3);
    or  o_g (lamps[0], p_g0, p_g1, p_g2, p_g3, p_g4);
endmodule
