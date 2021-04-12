# HoloRiscV
A Verilog RISC-V core.

The current version of this code is going to implement the RV32I variant of the RISC-V ISA, with the exception of the `FENCE`, `EBREAK`, and `ECALL` instructions.

At this point, the code is incomplete. The FETCH and DECODE stages of the pipeline have been completed and tested.
In this version, the EXECUTE code is present, but has trouble with pipeline control, which will be addressed next. The testing code is not in an optimized state, making it potentially hard to read, something that will not hold true on the implementation version.

At this point, the code is ready for implementation, although it has not been tested or verified. As such, the functionality may be limited. Due to the moderately large size of the synthesized code, the next stage is to scrap it and rebuild it in a more optimized manner, likely using a more advanced memory interface such as QSPI. Due to that change, the internal and external clock speeds are undetermined, pending testing of future variations. The next version is also likely to include some sort of external cache, possibly DDR memory in order to improve the potential performance, though that has yet to be determined.

```
=== HoloRiscV ===

   Number of wires:               3391
   Number of wire bits:           5046
   Number of public wires:          61
   Number of public wire bits:    1427
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:               3877
     $_ANDNOT_                     146
     $_AND_                         47
     $_AOI3_                       165
     $_AOI4_                        71
     $_DFF_N_                        1
     $_DFF_P_                      284
     $_MUX_                       1774
     $_NAND_                        78
     $_NOR_                         53
     $_NOT_                        372
     $_OAI3_                       176
     $_OAI4_                       147
     $_ORNOT_                       43
     $_OR_                         311
     $_XNOR_                        78
     $_XOR_                        131
 ```
