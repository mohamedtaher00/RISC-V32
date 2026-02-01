module half_adder(
    input x, y,
    output c, s
    );
    
    assign s = x ^ y;
    
    assign c = x & y;
    
endmodule
