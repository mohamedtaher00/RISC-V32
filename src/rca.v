module rca
    #(parameter n = 32)(
    input [n - 1:0] x, y,
    input c_in,
    output [n - 1:0] s,
    output c_out
    );
    
    wire [n:0] c;
    assign c[0] = c_in;
    assign c_out = c[n];
    
    // generate replicated hardware structures
    generate
        // genvar type is similar to integer, but it can only
        // take positive values
        genvar k;
        
        // Loop iterator must be of type genvar
        // k++ and k-- cannot be used
        for (k = 0; k < n; k = k + 1)
        begin: stage
            full_adder FA (
                .x(x[k]),
                .y(y[k]),
                .c_in(c[k]),
                .s(s[k]),
                .c_out(c[k + 1])
            );
        
        end
    
    endgenerate
endmodule
