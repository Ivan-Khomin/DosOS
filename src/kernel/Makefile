ASMFLAGS += -f bin

.PHONY: all clean

all: kernel

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: main.asm
	@$(ASM) $(ASMFLAGS) -o $@ $<
	@echo "Compiled -->" $<

clean:
	@rm -f $(BUILD_DIR)/kernel.bin