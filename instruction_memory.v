// Instruction Memory Module
module instruction_memory(
    input [31:0] pc,
    output reg [31:0] instruction
);
    reg [31:0] memory [0:1023];

    // Initialize memory
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'b0;
    end

    always @(*) begin
        instruction = memory[pc[11:2]];
    end
endmodule