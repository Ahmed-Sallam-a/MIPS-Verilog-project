`timescale 1ns / 1ps

module test_mips;

    reg clk;
    reg reset;

    // Instantiate the MIPS processor
    mips cpu(
        .clk(clk),
        .reset(reset)
    );

    // Clock generation (10ns period)
    always begin
        #5 clk = ~clk;
    end

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;

        // Wait for some time, then de-assert reset
        #10 reset = 0;

        // Run the simulation for sufficient time
        #500 $finish;
    end

    // Load instructions into the instruction memory
    initial begin : instr_mem_init
        integer i;  // Variable declaration moved before any statements

        // Wait for reset to be de-asserted
        @(negedge reset);

        // Initialize instruction memory
        for (i = 0; i < 1024; i = i + 1)
            cpu.instr_mem.memory[i] = 32'b0;

        // Instructions:
        // Memory indices correspond to word addresses (address / 4)
        // Test ADDI instruction
        cpu.instr_mem.memory[0] = 32'h20080004; // addi $t0, $zero, 4        ; $t0 = 4 (word-aligned address)
        cpu.instr_mem.memory[1] = 32'h20090003; // addi $t1, $zero, 3        ; $t1 = 3
        
        // Test R-type instructions: ADD, SUB, AND, OR, SLT
        cpu.instr_mem.memory[2] = 32'h01095020; // add $t2, $t0, $t1         ; $t2 = $t0 + $t1 = 7
        cpu.instr_mem.memory[3] = 32'h01095822; // sub $t3, $t0, $t1         ; $t3 = $t0 - $t1 = 1
        cpu.instr_mem.memory[4] = 32'h01096024; // and $t4, $t0, $t1         ; $t4 = $t0 & $t1
        cpu.instr_mem.memory[5] = 32'h01096825; // or  $t5, $t0, $t1         ; $t5 = $t0 | $t1
        cpu.instr_mem.memory[6] = 32'h0109702A; // slt $t6, $t0, $t1         ; $t6 = ($t0 < $t1) ? 1 : 0

        // Test Memory Instructions: SW, LW
        cpu.instr_mem.memory[7] = 32'had0a0000; // sw $t2, 0($t0)            ; Memory[$t0 + 0] = $t2
        cpu.instr_mem.memory[8] = 32'h8d0b0000; // lw $t3, 0($t0)            ; $t3 = Memory[$t0 + 0]

        // Test Branch Instruction: BEQ
        cpu.instr_mem.memory[9]  = 32'h11090002; // beq $t0, $t1, Skip       ; if ($t0 == $t1) skip next two instructions
        cpu.instr_mem.memory[10] = 32'h20080009; // addi $t0, $zero, 9        ; $t0 = 9 (should execute if branch not taken)
        cpu.instr_mem.memory[11] = 32'h0800000E; // j JumpTarget              ; Jump to instruction at index 14

        // Jump target labels
        cpu.instr_mem.memory[14] = 32'h00000000; // NOP (JumpTarget)
        cpu.instr_mem.memory[15] = 32'h200C0004; // addi $t4, $zero, 4        ; $t4 = 4 (after jump)
    end

    // Initialize data memory
    initial begin : data_mem_init
        integer j;  // Variable declaration moved before any statements

        // Wait for reset to be de-asserted
        @(negedge reset);

        for (j = 0; j < 1024; j = j + 1)
            cpu.data_mem.memory[j] = 32'b0;
    end

    // Monitor the PC and other important signals
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time=%0dns, PC=0x%08h, Instruction=0x%08h", $time, cpu.pc, cpu.instruction);
            $display("Registers:");
            $display(" $t0 ($8)  = %d", cpu.reg_file.registers[8]);
            $display(" $t1 ($9)  = %d", cpu.reg_file.registers[9]);
            $display(" $t2 ($10) = %d", cpu.reg_file.registers[10]);
            $display(" $t3 ($11) = %d", cpu.reg_file.registers[11]);
            $display(" $t4 ($12) = %d", cpu.reg_file.registers[12]);
            $display(" $t5 ($13) = %d", cpu.reg_file.registers[13]);
            $display(" $t6 ($14) = %d", cpu.reg_file.registers[14]);
            $display("Memory[1]  = %d", cpu.data_mem.memory[1]); // Updated to reflect correct indexing
            $display("");
        end
    end

endmodule