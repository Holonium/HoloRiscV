# HoloRiscV
A Verilog RISC-V core.

The current version of this code is going to implement the RV32I variant of the RISC-V ISA, with the exception of the `FENCE`, `EBREAK`, and `ECALL` instructions.

At this point, the code is incomplete. The FETCH and DECODE stages of the pipeline have been completed and tested. The EXECUTE stage is currently nearing completion with only the ALU instructions left to implement. The testing code is not in an optimized stage, making it potentially hard to read, something that will not hold true on the implementation version.

The current goals are to finish writing the code and to find an efficient way to test it.
