#This Document is just my thoughts at first.

- The basic components we've here would continue with us through every improvement (pipelining, multiple pipelines,...etc)

- So, it's important to have:
            
            -clear RTL.
            -generic code (so, if you wanna be 64, 128 bits it's pretty easy). Things like (mux, ) 
            -test bench for each block.

- The basic components for single cycle are 
    Data path
        -Program counter
        -Instruction memory 
        -Register file 
        -ALU 
        -Data memory
    Control path 
        ...

    now it's pretty early to have Memory & communication as a separte components for our CPU digital system 

now, we'll start w/ the engine (data path).

    when designing for FPGA considering guidelines is important, for example making a memory with guidelines(BRAM) is way efficient than using all 
    the F/F we had. 
    

1) data path 

    -program counter : The register containing the address of the instruction in the program being executed. So the program counter register size is        dependent on the # of memory addresses in the instruction memory. 
        
