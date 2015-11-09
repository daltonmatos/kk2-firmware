#!/usr/bin/env python
# encoding: utf-8


# From the .map file and the disassembly of the ELF file
# output the final address (in the ELF) of all original labels
# Also output which addresses in the ELF references each symbol (Will be useful
# when building the relocation table).


import sys
from collections import defaultdict
import re
from pprint import pprint

def write_err(s, *args):
    sys.stderr.write(s + "".join(str(i) for i in args) + "\n")
    sys.stderr.flush()

HEX_DIGITS = "[\dA-Fa-f]+"
RE_INTRUCTION_ADDRESS = "(?P<instr_addr>{})".format(HEX_DIGITS)
RE_OPCODE_HIGH_BYTE = "(?P<opcodeH>{})".format(HEX_DIGITS)
RE_OPCODE_LOW_BYTE = "(?P<opcodeL>{})".format(HEX_DIGITS)
RE_OPCODE_ADDR_HIGH_BYTE = "(?P<addrH>{})".format(HEX_DIGITS)
RE_OPCODE_ADDR_LOW_BYTE = "(?P<addrL>{})".format(HEX_DIGITS)
RE_MNEMONIC = "(?P<mnemonic>[a-z0-9]+)"
RE_ELF_ADDR = "(?P<elf_addr>(?:0x|){})".format(HEX_DIGITS)


# Opcode com parametro (jmp, call, rcall, etc)
#0:	0c 94 82 00 	jmp	0x104	; 0x104 <_binary_build_blink_jmp_asm_bin_end+0xf6>
# Opcode sem parametro
#4:	11 24       	eor	r1, r1

OBJDUMP_REGEX = re.compile(r'{}:\s+{}\s+{}\s+({}\s+{}\s+{}\s+{})?.*'.format(RE_INTRUCTION_ADDRESS,
                                                                            RE_OPCODE_LOW_BYTE,
                                                                            RE_OPCODE_HIGH_BYTE,
                                                                            RE_OPCODE_ADDR_LOW_BYTE,
                                                                            RE_OPCODE_ADDR_HIGH_BYTE,
                                                                            RE_MNEMONIC,
                                                                            RE_ELF_ADDR)
                            , re.IGNORECASE)

map_file = sys.argv[1]
external_symbols = sys.argv[2:]

#Dado um simbolo, qual seu endereço?
symbols_by_name = defaultdict(list)

#Dado um endereço, quais símbolos apontam para ele?
symbols_by_addr = defaultdict(list)

with open(map_file, 'r') as f:
    for line in f:
        if 'CSEG' in line:
            parts = line.strip().split(" ")
            symbol = parts[1]
            addr = int(parts[-1], 16)
            symbols_by_name[symbol].append(addr)
            symbols_by_addr[addr].append(symbol)

#print symbols_by_name
#print symbols_by_addr

#Dado um simbolo, qual seu novo endereço no arquivo ELF?
symbols_addr_in_elf = {}

# Dado um símbolo, quais instruçoes no ELF referenciam esse símbolo?
instructions_for_symbols = defaultdict(list)

#disassembly comes from sdtin
for line in sys.stdin:
    m = OBJDUMP_REGEX.search(line.strip())
    if m:
        group_dict = m.groupdict()
        if group_dict['addrH'] and group_dict['addrL']:  # This is a branch struction, must be relocated
            addr = int(group_dict['addrH'] + group_dict['addrL'], 16)
            if addr in symbols_by_addr:  # We found a symbol at this address in the .map file
                for _s in symbols_by_addr[addr]:
                    symbols_addr_in_elf[_s] = addr
                    instructions_for_symbols[_s].append(int(group_dict['instr_addr'], 16))

symbols_not_in_elf =  set(symbols_by_name.keys()).difference(set(instructions_for_symbols.keys()))

#This is a special entry point
for _0_addr_symbols in symbols_not_in_elf:
    print _0_addr_symbols, "I", "0x%x" % (symbols_by_name[_0_addr_symbols][0] * 2)

# Print all other symbols that were found in the ELF file
# Format: <sym_name> <sym_type> <sym_addr> <instructions, ...>
# sym_type is I=Internal E=External
for _s in symbols_addr_in_elf:
    sym_type = "I"
    if _s in external_symbols:
        sym_type = "E"
    print  _s, sym_type, "0x%x" % (symbols_addr_in_elf[_s] * 2), " ".join("0x%x" % item for item in instructions_for_symbols.get(_s, []))


