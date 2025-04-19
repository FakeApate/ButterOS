# ----------- Configurable Variables -----------

ISO_ORIG       	:= base.iso
ISO_URL 		:= https://mirror.init7.net/fedora/fedora/linux/releases/42/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-42-1.1.iso
ISO_CUSTOM     	:= meow.iso
KS_FILE        	:= ks.cfg

THEME_DIR      	:= theme
BUILD_DIR		:= build

QEMU_RAM       	:= 8192
QEMU_CPU       	:= 4
QEMU_DISK		:= test.qcow2
QEMU_NAME		:= test_vm

# ----------- Targets -----------

.PHONY: all build test clean

all: build

$(ISO_ORIG):
	@echo "Downloading ISO..."
	curl -L -o "$(ISO_ORIG)" "$(ISO_URL)"

build: $(ISO_ORIG)
	@echo "Rebuilding ISO..."
	mkdir -p $(BUILD_DIR)
	sudo cp $(KS_FILE) $(BUILD_DIR)/$(KS_FILE)
	sudo cp -r $(THEME_DIR) $(BUILD_DIR)/$(THEME_DIR)
	sudo chown root:root $(BUILD_DIR)/$(KS_FILE)
	sudo chown -R root:root $(BUILD_DIR)/$(THEME_DIR)
	sudo chmod 755 $(BUILD_DIR)/$(KS_FILE)
	sudo mkksiso -a $(BUILD_DIR)/$(THEME_DIR) -V meow $(BUILD_DIR)/$(KS_FILE) $(ISO_ORIG) $(BUILD_DIR)/$(ISO_CUSTOM)
	sudo chown sam:sam $(BUILD_DIR)/$(ISO_CUSTOM)
	@echo "ISO rebuilt: $(ISO_CUSTOM)"


test:
	@echo "Booting ISO in QEMU..."
	sudo qemu-img create -f qcow2 $(BUILD_DIR)/$(QEMU_DISK) 40G
	sudo virt-install --name $(QEMU_NAME) \
		--ram $(QEMU_RAM) \
		--vcpus $(QEMU_CPU) \
		--disk path=$(BUILD_DIR)/$(QEMU_DISK),size=40,format=qcow2 \
		--cdrom $(BUILD_DIR)/$(ISO_CUSTOM) \
		--network network=default \
  		--graphics spice \
		--osinfo linux2024 \
		--boot uefi --check all=off

clean:
	@echo "Cleaning up build artifacts..."
	-virsh destroy $(QEMU_NAME) 2>/dev/null || true
	-virsh undefine $(QEMU_NAME) --nvram 2>/dev/null || true
	-rm -rf $(BUILD_DIR)
	@echo "Cleaned"


 


