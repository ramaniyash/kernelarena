obj-m += ka_vuln.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	make -C $(KDIR) M=$(PWD) modules

clean:
	make -C $(KDIR) M=$(PWD) clean

# Load the module and create device node
load:
	sudo insmod ka_vuln.ko
	@echo "ka_vuln: module loaded"
	@ls -la /dev/ka_vuln

# Unload the module
unload:
	sudo rmmod ka_vuln

# Reload (unload + load)
reload: unload load
