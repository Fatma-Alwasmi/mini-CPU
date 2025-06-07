# MIPS Pipelined Processor

A Verilog implementation of a 5-stage pipelined MIPS processor supporting basic arithmetic and load/store operations.

## Overview

This project implements a classic 5-stage MIPS pipeline processor with the following stages:
- **IF (Instruction Fetch)**: Fetches instructions from memory
- **ID (Instruction Decode)**: Decodes instructions and reads registers
- **EX (Execute)**: Performs ALU operations
- **MEM (Memory Access)**: Handles data memory operations
- **WB (Write Back)**: Writes results back to registers

## Architecture

The processor consists of the following key components:

### Pipeline Stages
1. **Instruction Fetch (IF)**
   - `pc_counter`: Program counter management
   - `inst_mem`: Instruction memory (64 words)
   - `pc_adder`: Calculates next PC value

2. **Instruction Decode (ID)**
   - `ifid_reg`: IF/ID pipeline register
   - `control_unit`: Generates control signals
   - `register_file`: 32 general-purpose registers
   - `immediate_extender`: Sign-extends 16-bit immediates to 32-bit

3. **Execute (EX)**  
   - `idexe_reg`: ID/EX pipeline register
   - `alu`: Arithmetic Logic Unit with 6 operations
   - `alu_mux`: Selects between register and immediate values

4. **Memory Access (MEM)**
   - `exemem`: EX/MEM pipeline register  
   - `data_memory`: Data memory (64 words)

5. **Write Back (WB)**
   - `memwb`: MEM/WB pipeline register
   - `wbmux`: Selects data source for register write-back

### Supported Instructions

#### R-Type Instructions
- **ADD**: `add $rd, $rs, $rt` - Addition operation

#### I-Type Instructions  
- **LW**: `lw $rt, offset($rs)` - Load word from memory

### ALU Operations
- `0000`: AND operation
- `0001`: OR operation  
- `0010`: Addition
- `0110`: Subtraction
- `0111`: Set less than
- `1100`: NOR operation

## Memory Configuration

### Instruction Memory
- **Size**: 64 words (32-bit each)
- **PC Start**: 100 (word address 25)
- **Sample Program**:
  ```assembly
  lw $2, 0($1)    # Load from address in $1
  lw $3, 4($1)    # Load from address in $1 + 4  
  lw $4, 8($1)    # Load from address in $1 + 8
  lw $5, 12($1)   # Load from address in $1 + 12
  add $6, $2, $10 # Add $2 and $10, store in $6
  ```

### Data Memory
- **Size**: 64 words (32-bit each)
- **Initialized with test data**: `0xA00000AA`, `0x10000011`, etc.

## Control Signals

| Signal | Description |
|--------|-------------|
| `wreg` | Write enable for register file |
| `m2reg` | Select memory data for register write-back |
| `wmem` | Write enable for data memory |
| `aluc` | ALU control signals (4-bit) |
| `aluimm` | Select immediate value for ALU |
| `regrt` | Select rt vs rd as destination register |

## Usage

### Simulation
1. Compile all Verilog modules in your simulator
2. Instantiate the top-level `labv` module
3. Provide a clock signal
4. Monitor the output signals to observe pipeline operation

### Key Output Signals
- `pc`: Current program counter value
- `dinstOut`: Decoded instruction in ID stage
- `eqa`, `eqb`: ALU operands in EX stage  
- `mr`: Memory address in MEM stage
- `wbdata`: Data being written back in WB stage

## File Structure

```
├── pc_counter.v          # Program counter
├── inst_mem.v           # Instruction memory
├── pc_adder.v           # PC increment logic
├── ifid_reg.v           # IF/ID pipeline register
├── control_unit.v       # Control signal generation
├── regrt.v              # Destination register selection
├── register_file.v      # Register file (32 registers)
├── immediate_extender.v # Immediate value extension
├── idexe_reg.v          # ID/EX pipeline register
├── alu_mux.v            # ALU input multiplexer
├── alu.v                # Arithmetic Logic Unit
├── exemem.v             # EX/MEM pipeline register
├── data_memory.v        # Data memory
├── memwb.v              # MEM/WB pipeline register
├── wbmux.v              # Write-back multiplexer
└── labv.v               # Top-level module
```

## Features

- **5-stage pipeline**: Classic MIPS pipeline implementation
- **Hazard handling**: Basic pipeline registers for data forwarding
- **Memory hierarchy**: Separate instruction and data memories
- **Flexible ALU**: Supports multiple arithmetic and logical operations
- **Register file**: Standard 32-register MIPS register file

## Testing

The processor comes with a pre-loaded test program that demonstrates:
- Load word operations from data memory
- Register-to-register arithmetic operations
- Pipeline data flow through all stages
