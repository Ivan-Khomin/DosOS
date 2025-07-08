TARGET_ASMFLAGS += -f elf
TARGET_CFLAGS += -mcmodel=small -ffreestanding -nostdlib
TARGET_LINKFLAGS += -T linker.ld -nostdlib
TARGET_LIBS += -lgcc

SRC_C=$(wildcard *.c)
OBJ_C=$(patsubst %.c, $(BUILD_DIR)/stage2/c/%.o, $(SRC_C))
SRC_ASM=$(wildcard *.asm)
OBJ_ASM=$(patsubst %.asm, $(BUILD_DIR)/stage2/asm/%.o, $(SRC_ASM))

.PHONY: all clean

all: stage2

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: $(OBJ_C) $(OBJ_ASM)
	@$(TARGET_LD) $(TARGET_LINKFLAGS) -Wl,-Map=$(BUILD_DIR)/stage2.map -o $@ $^ $(TARGET_LIBS)

$(BUILD_DIR)/stage2/c/%.o: %.c
	@mkdir -p $(@D)
	@$(TARGET_CC) $(TARGET_CFLAGS) -c -o $@ $<
	@echo "Compiled -->" $<

$(BUILD_DIR)/stage2/asm/%.o: %.asm
	@mkdir -p $(@D)
	@$(TARGET_ASM) $(TARGET_ASMFLAGS) -o $@ $<
	@echo "Compiled -->" $<

clean:
	@rm -f $(BUILD_DIR)/stage2.bin