ASMFLAGS += -f bin

.PHONY: all clean

all: stage1

stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: boot.asm
	@$(ASM) $(ASMFLAGS) -o $@ $<
	@echo "Compiled -->" $<

clean:
	@rm -f $(BUILD_DIR)/stage1.bin