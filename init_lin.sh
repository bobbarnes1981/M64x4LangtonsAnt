#!/bin/bash
LOCATION="../Minimal-64x4-Home-Computer"

#cp $LOCATION/Revision 1.1/FLASH Images/flash.bin .
#cp $LOCATION/Support/Emulator/Minimal64x4.exe .

g++ $LOCATION/Support/Assembler/asm.cpp -O2 -o ./asm -s -static
