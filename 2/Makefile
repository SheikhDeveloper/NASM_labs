AS = /usr/bin/nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

SRCS = main.s
OBJS = $(SRCS:.s=.o)

REVERSE = 0

ifeq ($(REVERSE), 1)
	ASFLAGS += -DREVERSE
endif

EXE = lab

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
		$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@

.PHONY: all clean
