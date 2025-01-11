// Data Memory Module
module data_memory(
    input clk,
    input [31:0] address,
    input [31:0] write_data,
    input mem_write, mem_read,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:1023];

    // Initialize memory
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'b0;
    end

    // Read operation (asynchronous read)
    always @(*) begin
        if (mem_read)
            read_data = memory[address[11:2]];
        else
            read_data = 32'b0;
    end

    // Write operation (synchronous write)
    always @(posedge clk) begin
        if (mem_write) begin
            memory[address[11:2]] <= write_data;
            $display("Data Memory Write: Time=%0dns, Address=0x%h, Data=%d", $time, address, write_data);
        end
    end
endmodule