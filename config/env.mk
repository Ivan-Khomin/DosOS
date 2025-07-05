# Base toolchain
export ASM = nasm
export ASMFLAGS =
export CC = gcc
export CFLAGS = -g
export CXX = g++
export CXXFLAGS = -std=c++17
export LD = gcc
export LINKFLAGS =

export TOOLCHAIN = $(HOME)/Ivan/Toolchain/i686-elf
export PATH := $(TOOLCHAIN)/bin:$(PATH)

# Target (i686-elf) toolchain
export TARGET = i686-elf

export TARGET_ASM = nasm
export TARGET_ASMFLAGS =
export TARGET_CC = $(TARGET)-gcc
export TARGET_CFLAGS = -std=c99
export TARGET_CXX = $(TARGET)-g++
export TARGET_CXXFLAGS = -std=c++17
export TARGET_LD = $(TARGET)-gcc
export TARGET_LINKFLAGS =
export TARGET_LIBS =

# Directories
export SRC_DIR = $(abspath src)
export BUILD_DIR = $(abspath build)
export IMAGE_DIR = $(abspath image)