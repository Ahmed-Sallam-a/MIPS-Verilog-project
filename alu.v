
// ALU Module
module alu(
    input [31:0] a, b,
    input [2:0] alu_control,
    output reg [31:0] result,
    output zero
);
    // ALU operation codes
    parameter ADD = 3'b010;
    parameter SUB = 3'b110;
    parameter AND = 3'b000;
    parameter OR  = 3'b001;
    parameter SLT = 3'b111;

    always @(*) begin
        case(alu_control)
            ADD: result = a + b;
            SUB: result = a - b;
            AND: result = a & b;
            OR : result = a | b;
            SLT: result = (a < b) ? 32'd1 : 32'd0;
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);
endmodule