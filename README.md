# Popcap-unpacker

A simple utility for unpacking and extracting the standalone core executable from legacy PopCap trial wrappers. It automates the manual runtime extraction trick (launching the wrapper, grabbing the hidden unpacked binary, and cleaning up the wrapper process).

## Status & Tested Games
I haven't tested this across the entire PopCap catalog. So far, I have confirmed it works cleanly on:
- **Heavy Weapon Deluxe** 
- **Insaniquarium Deluxe**

Other classic PopCap titles using the same wrapper architecture should work in theory, though they might require adjusting some hardcoded file paths or process names in the source code.

## Why?
Many older PopCap releases and legacy builds are no longer maintained, and their outdated trial wrappers often break or fail to initialize properly on modern Windows (10/11). Extracting the standalone game binary makes it possible to preserve and run these classic versions natively.

## Usage
1. Clone the repository and compile the source code yourself (built with AutoIt).
2. Run the tool and drop your executable file to it.
3. The tool will handle the extraction and drop the standalone game executable for you.

## Disclaimer
No game files or copyrighted assets are included in this repository—only the source code.