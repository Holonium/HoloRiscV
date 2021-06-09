# HoloRiscV
A Verilog RISC-V core.

The current version of this code is going to implement the RV32I variant of the RISC-V ISA, with the exception of the `FENCE`, `EBREAK`, and `ECALL` instructions.

At this point, the code in the testing and implementation directories is still incomplete. The current code can be found in the Vivado directory. This is due to the need for hardware simulation. At this point, any assistance with testing would be appreciated until I can obtain QSPI flash for use.

Although it may not be present on the ASIC variant, the Vivado variant will be making use of the MMCMs for clock generation for certain features.