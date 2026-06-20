##############################################################
#  Makefile — Atari 8-bit CC65 Cross-Development
#
#  Targets:
#    make              →  debug build, Atari 400/800
#    make release      →  release build (-Osir), Atari 400/800
#    make xl           →  debug build, Atari XL/XE
#    make xl-release   →  release build, Atari XL/XE
#    make run          →  debug build + launch in Atari800MacX
#    make run-release  →  release build + launch in Atari800MacX
#    make run-xl       →  XL/XE debug build + launch
#    make run-xl-release → XL/XE release build + launch
#    make clean        →  remove all build artifacts
#    make help         →  show this list
##############################################################

# ── Project Name ──────────────────────────────────────────────
#  Change this to match your project. Output files will use it.
PROJECT     := myapp

# ── Directory Layout ──────────────────────────────────────────
SRC_DIR     := src
INC_DIR     := include
OBJ_DIR     := obj
BUILD_DIR   := builds

# ── CC65 Toolchain ────────────────────────────────────────────
#  Derive bin/ and lib/ from a single CC65_HOME root.
#  If you installed CC65 elsewhere, only this one line changes.
CC65_HOME   := /usr/local/bin/cc65
CC65_BIN    := $(CC65_HOME)/bin
CC65_LIB    := $(CC65_HOME)/lib

CC65        := $(CC65_BIN)/cc65      # C compiler  → generates .s assembly
CA65        := $(CC65_BIN)/ca65      # Assembler   → generates .o object
LD65        := $(CC65_BIN)/ld65      # Linker      → generates .xex

# ── Emulator ──────────────────────────────────────────────────
#  macOS: 'open -a' works regardless of install location.
#  Windows: swap for:  "C:/Program Files/Altirra/Altirra64.exe" /run
EMULATOR    := open -a Atari800MacX

# ── Target Machine ────────────────────────────────────────────
#  atari   = Atari 400/800 OS (48K)
#  atarixl = Atari XL/XE OS  (uses extended OS entry points)
TARGET      ?= atari

# ── Build Configuration ───────────────────────────────────────
#  debug   = basic optimization + debug symbols (-g -O)
#  release = full optimization, no symbols      (-Osir)
CONFIG      ?= debug

# ── Per-Configuration Flags ───────────────────────────────────
#  -O    : basic optimization (safe with -g for development)
#  -Osir : inline subroutines + simplify + remove dead code
#  -g    : emit debug symbols (used by Altirra source-level debugger)
#  -I    : header search path
CFLAGS_debug    := -g -O    -I$(INC_DIR)
CFLAGS_release  :=    -Osir -I$(INC_DIR)

ASFLAGS_debug   := -g
ASFLAGS_release :=

CC65FLAGS   := -t $(TARGET) $(CFLAGS_$(CONFIG))
CA65FLAGS   := -t $(TARGET) $(ASFLAGS_$(CONFIG))
LD65FLAGS   := -t $(TARGET)

# ── Computed Output Paths ─────────────────────────────────────
#  Each TARGET+CONFIG combo gets its own obj/ and builds/ subdir
#  so switching configurations never causes stale-object bugs.
OBJ_SUBDIR  := $(OBJ_DIR)/$(TARGET)_$(CONFIG)
BLD_SUBDIR  := $(BUILD_DIR)/$(TARGET)_$(CONFIG)

OUTPUT      := $(BLD_SUBDIR)/$(PROJECT).xex
MAPFILE     := $(BLD_SUBDIR)/$(PROJECT).map
LBLFILE     := $(BLD_SUBDIR)/$(PROJECT).lbl

# ── Source File Discovery ─────────────────────────────────────
#  All .c files in src/ are compiled automatically.
#  All .s files in src/ are assembled automatically.
#  To exclude a file, move it out of src/ or prefix with '_'.
C_SRCS      := $(wildcard $(SRC_DIR)/*.c)
ASM_SRCS    := $(wildcard $(SRC_DIR)/*.s)

C_OBJS      := $(patsubst $(SRC_DIR)/%.c, $(OBJ_SUBDIR)/%.o,     $(C_SRCS))
ASM_OBJS    := $(patsubst $(SRC_DIR)/%.s, $(OBJ_SUBDIR)/%-asm.o, $(ASM_SRCS))
ALL_OBJS    := $(C_OBJS) $(ASM_OBJS)

# ── Header Dependency Tracking ────────────────────────────────
#  Each .c compile step generates a .d file listing which headers
#  that file depends on. Including them here makes Make aware of
#  header changes automatically — no more make clean after .h edits.
#  The leading dash suppresses errors on the very first build.
DEP_FILES   := $(patsubst $(SRC_DIR)/%.c, $(OBJ_SUBDIR)/%.d, $(C_SRCS))
-include $(DEP_FILES)

# ── Phony Targets ─────────────────────────────────────────────
.PHONY: all debug release xl xl-release build clean help \
        run run-release run-xl run-xl-release

# ── Default Target ────────────────────────────────────────────
all: debug

# ── Named Build Shortcuts ─────────────────────────────────────
debug:
	@$(MAKE) --no-print-directory build TARGET=atari   CONFIG=debug

release:
	@$(MAKE) --no-print-directory build TARGET=atari   CONFIG=release

xl:
	@$(MAKE) --no-print-directory build TARGET=atarixl CONFIG=debug

xl-release:
	@$(MAKE) --no-print-directory build TARGET=atarixl CONFIG=release

# ── Run Targets: build then launch emulator ───────────────────
#  If the build fails Make exits before the open line fires,
#  so a stale .xex is never accidentally launched.
run: debug
	@echo "  Launching Atari800MacX ..."
	@$(EMULATOR) $(BUILD_DIR)/atari_debug/$(PROJECT).xex

run-release: release
	@echo "  Launching Atari800MacX ..."
	@$(EMULATOR) $(BUILD_DIR)/atari_release/$(PROJECT).xex

run-xl: xl
	@echo "  Launching Atari800MacX ..."
	@$(EMULATOR) $(BUILD_DIR)/atarixl_debug/$(PROJECT).xex

run-xl-release: xl-release
	@echo "  Launching Atari800MacX ..."
	@$(EMULATOR) $(BUILD_DIR)/atarixl_release/$(PROJECT).xex

# ── Build Entry Point ─────────────────────────────────────────
build: $(OUTPUT)
	@echo ""
	@echo "  ┌──────────────────────────────────────────────"
	@echo "  │  Build complete"
	@echo "  │  Target  : $(TARGET)"
	@echo "  │  Config  : $(CONFIG)"
	@echo "  │  Binary  : $(OUTPUT)"
	@echo "  │  Map     : $(MAPFILE)"
	@echo "  │  Symbols : $(LBLFILE)"
	@echo "  └──────────────────────────────────────────────"

# ── Directory Rules ───────────────────────────────────────────
#  Explicit rules used as order-only prerequisites (| syntax).
#  Guarantees the directory exists before any file is written
#  into it, without treating a timestamp change as a rebuild trigger.
$(OBJ_SUBDIR):
	@mkdir -p $@

$(BLD_SUBDIR):
	@mkdir -p $@

# ── Link ──────────────────────────────────────────────────────
#  $(TARGET).lib resolves to atari.lib or atarixl.lib automatically.
#  MUST come after $(ALL_OBJS) — the linker is single-pass and only
#  pulls symbols from the library that are still unresolved at that point.
#  --dbgfile generates an Altirra-compatible symbol file for
#  source-level debugging. Load it in Altirra via Debug → Load Symbols.
$(OUTPUT): $(ALL_OBJS) | $(BLD_SUBDIR)
	@echo "  [LD]  $(notdir $@)"
	@$(LD65) $(LD65FLAGS) \
	         -o $@ \
	         -m $(MAPFILE) \
	         --dbgfile $(LBLFILE) \
	         $(ALL_OBJS) \
	         $(CC65_LIB)/$(TARGET).lib

# ── Compile + Assemble: .c → .o ───────────────────────────────
#  Both steps run in one recipe to avoid GNU Make's implicit
#  rule chain ambiguity with directory-prefixed pattern rules.
#
#  Step 1: cc65 compiles C → 6502 assembly text (.s)
#          --create-dep writes a header dependency file (.d)
#
#  Step 2: ca65 assembles .s → relocatable object (.o)
#
#  The intermediate .s is kept in obj/ so you can inspect the
#  generated assembly — useful for spotting optimisation opportunities.
$(OBJ_SUBDIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_SUBDIR)
	@echo "  [CC]  $<"
	@$(CC65) $(CC65FLAGS) \
	         --create-dep $(OBJ_SUBDIR)/$*.d \
	         -o $(OBJ_SUBDIR)/$*.s \
	         $<
	@echo "  [AS]  $(OBJ_SUBDIR)/$*.s"
	@$(CA65) $(CA65FLAGS) \
	         -o $@ \
	         $(OBJ_SUBDIR)/$*.s

# ── Assemble: hand-written .s → .o ────────────────────────────
#  VBI handlers, DLIs, player/missile routines — any .s file
#  placed in src/ is assembled directly from source.
#  The -asm suffix prevents name collision with cc65-generated objects.
$(OBJ_SUBDIR)/%-asm.o: $(SRC_DIR)/%.s | $(OBJ_SUBDIR)
	@echo "  [AS]  $< (hand-written)"
	@$(CA65) $(CA65FLAGS) \
	         -o $@ \
	         $<

# ── Clean ─────────────────────────────────────────────────────
clean:
	@echo "  Removing obj/ and builds/ ..."
	@rm -rf $(OBJ_DIR) $(BUILD_DIR)
	@echo "  Done."

# ── Help ──────────────────────────────────────────────────────
help:
	@echo ""
	@echo "  make                →  debug build, Atari 400/800 (48K)"
	@echo "  make release        →  release build (-Osir), Atari 400/800"
	@echo "  make xl             →  debug build, Atari XL/XE"
	@echo "  make xl-release     →  release build, Atari XL/XE"
	@echo "  make run            →  debug build + launch in Atari800MacX"
	@echo "  make run-release    →  release build + launch in Atari800MacX"
	@echo "  make run-xl         →  XL/XE debug build + launch"
	@echo "  make run-xl-release →  XL/XE release build + launch"
	@echo "  make clean          →  remove all obj/ and builds/"
	@echo ""
	@echo "  Add files: drop .c or .s into src/ — no Makefile edits needed."
	@echo "  Header changes are tracked automatically via .d files in obj/."
	@echo ""