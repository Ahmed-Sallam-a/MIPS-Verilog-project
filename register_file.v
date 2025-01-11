
// Register File Module
module register_file(
    input clk,
    input [4:0] read_reg1, read_reg2, write_reg,
    input [31:0] write_data,
    input reg_write,
    output reg [31:0] read_data1, read_data2
);
    reg [31:0] registers [0:31];

    // Initialize registers
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

    // Read operation
    always @(*) begin
        read_data1 = registers[read_reg1];
        read_data2 = registers[read_reg2];
    end

    // Write operation
    always @(posedge clk) begin
        if (reg_write && write_reg != 0) // Don't write to register 0
            registers[write_reg] <= write_data;
    end
endmodule