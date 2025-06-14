include env.mk

.PHONY: all floppy_image bootloader kernel always clean

all: floppy_image

floppy_image: $(BUILD_DIR)/floppy_image.img

$(BUILD_DIR)/floppy_image.img: bootloader kernel
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n "MYOS" $@
	dd if=$(BUILD_DIR)/stage1.bin of=$@ conv=notrunc
	mcopy -i $@ $(BUILD_DIR)/stage2.bin "::stage2.bin"
	mcopy -i $@ $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $@ $(IMAGE_DIR)/test.txt "::test.txt"
	mmd -i $@ "::mydir"
	mcopy -i $@ $(IMAGE_DIR)/test.txt "::mydir/test.txt"

bootloader: stage1 stage2

stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(MAKE) -C $(SRC_DIR)/kernel

always:
	mkdir -p $(BUILD_DIR)

clean:
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1 clean
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2 clean
	$(MAKE) -C $(SRC_DIR)/kernel clean
	rm -rf $(BUILD_DIR)/*