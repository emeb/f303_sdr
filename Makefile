# Makefile for STM32F30x
# 01-28-2013 E. Brombaugh

# sub directories
VPATH = .:CMSIS:StdPeriph

# Object files
OBJECTS = 	startup_stm32f30x.o system_stm32f30x.o main.o adc.o \
			amrx.o sdr.o \
			stm32f30x_gpio.o stm32f30x_misc.o stm32f30x_rcc.o \
			stm32f30x_dma.o stm32f30x_adc.o \
			arm_biquad_cascade_df1_f32.o \
			arm_biquad_cascade_df1_init_f32.o

# Linker script
LDSCRIPT = STM32_FLASH.ld

CFLAGS  = -g -O2 -mlittle-endian -mthumb -ffunction-sections -std=c99
CFLAGS += -I. -ICMSIS -IStdPeriph -DARM_MATH_CM4 -D'__FPU_PRESENT=1'
CFLAGS += -DUSE_STDPERIPH_DRIVER -mcpu=cortex-m4 -mfloat-abi=hard
CFLAGS += -mfpu=fpv4-sp-d16
AFLAGS  = -mlittle-endian -mthumb -mcpu=cortex-m4
LFLAGS  = $(CFLAGS) -nostartfiles -T $(LDSCRIPT) -Wl,-Map=main.map
LFLAGS += -Wl,--gc-sections
#LFLAGS += --specs=nano.specs
CPFLAGS = --output-target=binary
ODFLAGS	= -x --syms

# Executables
ARCH = arm-none-eabi
CC = $(ARCH)-gcc
LD = $(ARCH)-ld -v
AS = $(ARCH)-as
OBJCPY = $(ARCH)-objcopy
OBJDMP = $(ARCH)-objdump
GDB = $(ARCH)-gdb

#CPFLAGS = --output-target=binary -j .text -j .data
CPFLAGS = --output-target=binary
ODFLAGS	= -x --syms

FLASH = st-flash

# Targets
all: main.bin

clean:
	-rm -f $(OBJECTS) *.lst *.elf *.bin *.map *.dmp

flash: gdb_flash

stlink_flash: main.bin
	$(FLASH) write main.bin 0x08000000
	
gdb_flash: main.elf
	$(GDB) -x flash_cmd.gdb -batch

disassemble: main.elf
	$(OBJDMP) -dS main.elf > main.dis
	
dist:
	tar -c *.h *.c *.s Makefile *.cmd *.cfg openocd_doflash | gzip > minimal_hello_world.tar.gz

main.ihex: main.elf
	$(OBJCPY) --output-target=ihex main.elf main.ihex

main.bin: main.elf 
	$(OBJCPY) $(CPFLAGS) main.elf main.bin
	$(OBJDMP) $(ODFLAGS) main.elf > main.dmp
	ls -l main.elf main.bin

main.elf: $(OBJECTS) $(LDSCRIPT)
	$(CC) $(LFLAGS) -o main.elf $(OBJECTS) -lnosys -lm
#	$(LD) $(LFLAGS) -o main.elf $(OBJECTS)

%.o: %.c %.h
	$(CC) $(CFLAGS) -c -o $@ $<

