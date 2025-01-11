// Main MIPS Module
module mips(
    input clk, reset
);
    // Internal signals
    reg [31:0] pc;
    wire [31:0] pc_plus4;
    wire [31:0] instruction;
    wire [31:0] read_data1, read_data2, write_data;
    wire [31:0] alu_result;
    wire [31:0] mem_read_data;
    wire [31:0] sign_extended;
    wire [31:0] jump_target;
    wire [31:0] branch_target;
    wire [4:0] write_reg;
    wire zero;
    wire [2:0] alu_control;
    wire reg_dst, jump, branch, branch_ne, mem_read;
    wire mem_to_reg, mem_write, alu_src, reg_write;
    reg [31:0] next_pc;
    wire branch_taken;
    wire [5:0] opcode = instruction[31:26];
    wire [5:0] funct  = instruction[5:0];

    // PC logic
    assign pc_plus4      = pc + 32'd4;
    assign sign_extended = {{16{instruction[15]}}, instruction[15:0]};
    assign branch_target = pc_plus4 + ({sign_extended[29:0], 2'b00});
    assign jump_target   = {pc_plus4[31:28], instruction[25:0], 2'b00};

    // Determine if branch is taken
    assign branch_taken = (branch && zero) || (branch_ne && !zero);

    // Next PC logic
    always @(*) begin
        if (reset)
            next_pc = 32'b0;
        else if (jump)
            next_pc = jump_target;
        else if (branch_taken)
            next_pc = branch_target;
        else
            next_pc = pc_plus4;
    end

    // PC update
    always @(posedge clk) begin
        pc <= next_pc;
    end

    // Debug monitor
    always @(posedge clk) begin
        if (!reset) begin
            $display("Debug: PC=%h, Next_PC=%h, Jump=%b, Branch=%b, Branch_NE=%b, Zero=%b, Jump_Target=%h, Branch_Target=%h",
                    pc, 
                    next_pc,
                    jump, branch, branch_ne, zero, jump_target, branch_target);
        end
    end

    // Control Unit
    control_unit ctrl_unit(
        .opcode(opcode),
        .funct(funct),
        .alu_control(alu_control),
        .reg_dst(reg_dst),
        .jump(jump),
        .branch(branch),
        .branch_ne(branch_ne),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write)
    );

    // Register file
    assign write_reg = reg_dst ? instruction[15:11] : instruction[20:16];
    assign write_data = mem_to_reg ? mem_read_data : alu_result;

    register_file reg_file(
        .clk(clk),
        .read_reg1(instruction[25:21]),
        .read_reg2(instruction[20:16]),
        .write_reg(write_reg),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ALU
    wire [31:0] alu_operand2 = alu_src ? sign_extended : read_data2;

    alu alu_unit(
        .a(read_data1),
        .b(alu_operand2),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    // Data Memory
    data_memory data_mem(
        .clk(clk),
        .address(alu_result),
        .write_data(read_data2),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_read_data)
    );

    // Instruction Memory
    instruction_memory instr_mem(
        .pc(pc),
        .instruction(instruction)
    );

    // Debug control signals
    always @(posedge clk) begin
        if (!reset) begin
            $display("Control Signals at Time=%0dns:", $time);
            $display(" mem_read=%b, mem_write=%b, reg_write=%b, alu_src=%b, mem_to_reg=%b", mem_read, mem_write, reg_write, alu_src, mem_to_reg);
        end
    end

endmodule
