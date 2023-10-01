# Image Processing in MIPS Assembly: A Journey to Pixels & Colors

Welcome to the University of Cape Town's MIPS assembly hub for the CSC2002S computer architecture assignment. Dive into the fascinating world of image processing, where we manipulate pixels to increase brightness or simply turn them into vintage greyscale. Ready to bring your photos to life?

## 🖥️ Getting Started
Before you let your creativity soar, ensure you've got QTSpim, our trusty MIPS simulator. If not, install and configure it pronto. It's your key to unlocking these assembly magic spells.

### 🗂️ Setting The Stage: File Paths
- Locate the labels `input_filename` and `output_filename`. Here, you're going to hardcode the file's journey. 
- Absolute paths are your best friends! They ensure our programs find their way to the right files.
- Our assembly knights have made assumptions:
  - There exist sacred `\sample_images` and `\sample_output_images` chambers (directories) where files rest before and after their transformation.
  - Post the mystical transformations, files take on new identities: `output_greyscale.ppm` and `output_increase_brightness.ppm`.
- Remember, a phoenix can't rise from ashes that don’t exist. Create your output files before you cast the program spells.

### 📝 Notes from the Scroll: End-of-Line Characters
- Our assembly scripts treasure the LF (Line Feed) end-of-line runes (ASCII 10). They’re the only runes these scripts understand.
- When our programs pen their tales (write output), they use the LF rune. But beware! Some realms, like Windows (with its CRLF), might change this tale.

## 🧙‍♂️ Crafted in the Enchanted Windows Forest
Our assembly enchantments were brewed in the mystical Windows woods.

🎉 Embark on this pixelated quest, harness the power of assembly, and reimagine your images like never before! 📸