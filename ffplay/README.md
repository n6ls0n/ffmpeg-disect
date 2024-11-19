# ffplay

## Table of Contents

- [Introduction](#introduction)
- [References](#references)

### Introduction

- This is a C++ port of ffplay with a GUI via DearImgui

- There is not explicit config.h file. Rather the variables from it that are accessed by the relevant files (header and source) are hard-coded at the beginning of the files. Edit/augment these as you see fit. The functions that use these config.h variables are also marked via a "config.h var" comment to make it clear where these variables come from

### References

- FFmpeg guide on Mingw usage: <https://www.ffmpeg.org/platform.html#Native-Windows-compilation-using-MinGW-or-MinGW_002dw64>
