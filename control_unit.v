// Control Unit Module
module control_unit(
    input [5:0] opcode,
    input [5:0] funct,
    output reg [2:0] alu_control,
    output reg reg_dst, jump, branch, mem_read,
    output reg mem_to_reg, mem_write, alu_src, reg_write,
    output reg branch_ne
);
    // Instruction opcodes
    parameter R_TYPE = 6'b000000;
    parameter LW     = 6'b100011;
    parameter SW     = 6'b101011;
    parameter BEQ    = 6'b000100;
    parameter BNE    = 6'b000101;
    parameter J      = 6'b000010;
    parameter ADDI   = 6'b001000;

    // Function codes for R-type instructions
    parameter FUNCT_ADD = 6'b100000;
    parameter FUNCT_SUB = 6'b100010;
    parameter FUNCT_AND = 6'b100100;
    parameter FUNCT_OR  = 6'b100101;
    parameter FUNCT_SLT = 6'b101010;

    always @(*) begin
        // Default values
        reg_dst     = 0;
        jump        = 0;
        branch      = 0;
        branch_ne   = 0;
        mem_read    = 0;
        mem_to_reg  = 0;
        mem_write   = 0;
        alu_src     = 0;
        reg_write   = 0;
        alu_control = 3'bxxx; // Undefined until set

        case(opcode)
            R_TYPE: begin
                reg_dst   = 1;      // Write to rd
                reg_write = 1;
                case(funct)
                    FUNCT_ADD: alu_control = 3'b010; // ADD
                    FUNCT_SUB: alu_control = 3'b110; // SUB
                    FUNCT_AND: alu_control = 3'b000; // AND
                    FUNCT_OR : alu_control = 3'b001; // OR
                    FUNCT_SLT: alu_control = 3'b111; // SLT
                    default  : alu_control = 3'bxxx; // Undefined
                endcase
            end

            LW: begin
                alu_src     = 1;
                mem_to_reg  = 1;
                reg_write   = 1;
                mem_read    = 1;
                alu_control = 3'b010; // ADD operation for address calculation
            end

            SW: begin
                alu_src     = 1;
                mem_write   = 1;
                alu_control = 3'b010; // ADD operation for address calculation
            end

            BEQ: begin
                branch      = 1;
                alu_control = 3'b110; // SUB for comparison
            end

            BNE: begin
                branch_ne   = 1;
                alu_control = 3'b110; // SUB for comparison
            end

            J: begin
                jump = 1;
            end

            ADDI: begin
                alu_src     = 1;
                reg_write   = 1;
                alu_control = 3'b010; // ADD operation
            end

            default: begin
                // Handle other opcodes or undefined instructions
            end
        endcase
    end
endmodule
