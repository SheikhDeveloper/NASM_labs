AS = /usr/bin/nasm
LD = gcc

ASFLAGS = -g -f elf64
LDFLAGS = -lm -no-pie

SRCS = main.s
OBJS = $(SRCS:.s=.o)

EXE = lab

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
		$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@

.PHONY: all clean
