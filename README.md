# ARM LEGv8 CPU
## Authors: Geeoon Chung and Anna Petrbokova
A partial implementation of the ARM LEGv8 instruction set for a 64-bit 5-stage pipelined CPU with delay-slots.

Was created for the University of Washington's Fall 2025 EE 469 class, Computer Architecture I.

The following instructions are implemented:
* ADDI
* ADDS
* AND
* B
* B.LT
* CBZ
* EOR
* LDUR
* LSR
* STUR
* SUBS

Block Diagram:
![CPU block diagram with 5 stages and forwarding](https://raw.githubusercontent.com/Geeoon/ARM-LEGv8-CPU/refs/heads/main/469_block_diagram.jpg "Pipelined CPU Block Diagram")
