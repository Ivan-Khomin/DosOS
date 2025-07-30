# Base toolchain
export ASM = nasm
export ASMFLAGS =
export CC = gcc
export CFLAGS = -g
export CXX = g++
export CXXFLAGS =
export LD = gcc
export LINKFLAGS =

# Setup toolchain variables
export TOOLCHAIN = $(HOME)/Ivan/Toolchain/ia16-elf
export TOOLCHAIN_BIN = $(TOOLCHAIN)/bin
export PATH := $(TOOLCHAIN_BIN):$(PATH)

# Target (ia16-elf) toolchain
export TARGET = ia16-elf

export TARGET_ASM = nasm
export TARGET_ASMFLAGS =
export TARGET_CC = $(TARGET)-gcc
export TARGET_CFLAGS =
export TARGET_CXX = $(TARGET)-g++
export TARGET_CXXFLAGS =
export TARGET_LD = $(TARGET)-gcc
export TARGET_LINKFLAGS =
export TARGET_LIBS =

# Directories
export SRC_DIR = $(abspath src)
export BUILD_DIR = $(abspath build)
export IMAGE_DIR = $(abspath image)