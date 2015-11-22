
SRC_DIR = Source
BIN_DIR = bin

CC_FLAGS = -Os

SRC_GIT_VERSION=$(shell git rev-parse HEAD | cut -c 1-7)

ASM_SOURCES = $(wildcard $(SRC_DIR)/*.asm)
#AVRASM2 = avrasm2
AVRASM2 = wine ~/bin/AvrAssembler2/avrasm2.exe

SOURCES = $(filter-out $(SRC_DIR)/flashvariables.c, $(wildcard $(SRC_DIR)/*.c) $(wildcard $(SRC_DIR)/display/*.c))

OBJECTS = $(SOURCES:.c=.o)
OUTPUT_OBJECTS = $(patsubst $(SRC_DIR)/%.o, $(BIN_DIR)/%.o, $(filter-out $(SRC_DIR)/flashvariables.c.o, $(OBJECTS)))

# Symbols used by the Assembly code but that are implemented in C
EXTERNAL_SYMBOLS = c_main lcd_clear lcd_command lcd_data show_version c_contrast lcd_update advanced_settings board_rotation SetDefaultLcdContrast extra_features show_confirmation_dlg esc_calibration_warning gimbal_mode

kk2++.hex: bindir kk2++.elf $(OBJECTS)
	sed -i -e 's/AiO.*\"/AiO\ $(SRC_GIT_VERSION)\"/' $(SRC_DIR)/flashvariables.c
	avr-gcc $(CC_FLAGS) -mno-interrupts -nostartfiles -mmcu=atmega644p -DF_CPU=20000000 -o $(BIN_DIR)/flashvariables.c.o $(SRC_DIR)/flashvariables.c
	sed -i -e 's/AiO.*\"/AiO\"/' $(SRC_DIR)/flashvariables.c

	avr-gcc $(CC_FLAGS) -mmcu=atmega644p -DF_CPU=20000000 -nostartfiles -o $(BIN_DIR)/kk2++.elf $(BIN_DIR)/kk2++.asm.hex.bin.elf $(filter-out $(BIN_DIR)/flashvariables.c.o, $(wildcard $(BIN_DIR)/*.o)) $(BIN_DIR)/flashvariables.c.o
	avr-objcopy -I elf32-avr -O ihex -j .text -j .data $(BIN_DIR)/kk2++.elf $(BIN_DIR)/kk2++.hex 

.PHONY: bindir
bindir:
	mkdir -p $(BIN_DIR)

kk2++.asm: $(ASM_SOURCES)
	$(AVRASM2) $(SRC_DIR)/$@ -fI -o $(BIN_DIR)/$@.hex -l $(BIN_DIR)/$@.lst -m $(BIN_DIR)/$@.map

kk2++.elf: kk2++.asm
	avr-objcopy -j .sec1 -I ihex -O binary $(BIN_DIR)/kk2++.asm.hex $(BIN_DIR)/kk2++.asm.hex.bin
	avr-objcopy --rename-section .data=.text,contents,alloc,load,readonly,code -I binary -O elf32-avr $(BIN_DIR)/kk2++.asm.hex.bin $(BIN_DIR)/kk2++.asm.hex.bin.elf

	avr-objdump -d $(BIN_DIR)/kk2++.asm.hex.bin.elf | python2 tools/extract-symbols-metadata.py $(BIN_DIR)/kk2++.asm.map $(EXTERNAL_SYMBOLS) > $(BIN_DIR)/kk2++.symtab

	cat $(BIN_DIR)/kk2++.symtab | tools/elf-add-symbol $(BIN_DIR)/kk2++.asm.hex.bin.elf

.c.o:
	avr-gcc $(CC_FLAGS) -nostartfiles -mno-interrupts -mmcu=atmega644p -DF_CPU=20000000 -c $< -o $(BIN_DIR)/$(<F).o

flash: kk2++.hex
	/usr/share/arduino/hardware/tools/avrdude -V -C /usr/share/arduino/hardware/tools/avrdude.conf -patmega644p -cusbasp -Uflash:w:$(BIN_DIR)/kk2++.hex:i

size: kk2++.hex
	avr-size bin/kk2++.elf


.PHONY: clean
clean:
	rm -f bin/*
