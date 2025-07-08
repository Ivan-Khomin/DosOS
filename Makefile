include config/env.mk

.PHONY: all floppy_image bootloader kernel always clean

all: floppy_image

# Floppy image
floppy_image: $(BUILD_DIR)/floppy_image.img

$(BUILD_DIR)/floppy_image.img: bootloader kernel
	@echo "Create floppy image"
	@dd if=/dev/zero of=$@ bs=512 count=2880
	@mkfs.fat -F 12 -n "DOSOS" $@
	@dd if=$(BUILD_DIR)/stage1.bin of=$@ conv=notrunc
	@mcopy -i $@ $(BUILD_DIR)/stage2.bin "::stage2.bin"
	@mcopy -i $@ $(BUILD_DIR)/kernel.bin "::kernel.bin"
	@mcopy -i $@ $(IMAGE_DIR)/test.txt "::test.txt"
	@mmd -i $@ "::mydir"
	@mcopy -i $@ $(IMAGE_DIR)/test.txt "::mydir/test.txt"
	@echo "Created -->" $@

# Bootloader
bootloader: stage1 stage2

stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: always
	@echo "Compile stage1 of bootloader"
	@$(MAKE) -C $(SRC_DIR)/bootloader/stage1

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: always
	@echo "Compile stage2 of bootloader"
	@$(MAKE) -C $(SRC_DIR)/bootloader/stage2

# Kernel
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	@echo "Compile kernel"
	@$(MAKE) -C $(SRC_DIR)/kernel

# Always
always:
	@mkdir -p $(BUILD_DIR)

# Clean
clean:
	@$(MAKE) -C $(SRC_DIR)/bootloader/stage1 clean
	@$(MAKE) -C $(SRC_DIR)/bootloader/stage2 clean
	@$(MAKE) -C $(SRC_DIR)/kernel clean
	@rm -rf $(BUILD_DIR)/*
