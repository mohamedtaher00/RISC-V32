module half_adder (
    input  x,
    input  y,
    output c,
    s
);

  assign s = x ^ y;

  assign c = x & y;

endmodule
