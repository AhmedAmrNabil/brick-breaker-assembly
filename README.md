<div align="center"> <img src="https://github.com/user-attachments/assets/6dcb30e7-f328-4d86-8721-079d55873360" alt="Game Screenshot" width="800"/> </div>

# Brick Breaker Game in 8086 Assembly 🎮

## Overview 📝

This repository contains the implementation of a **Brick Breaker** game developed using **8086 Assembly**. The game is a part of our project for the **Microprocessors Course** in our **second-year Computer Engineering** program. It features a classic brick-breaking gameplay with unique power-ups and a **separate chat mode** for communication outside of the game itself. 🚀

### Features ✨:

- **Brick Breaker Game**: The player controls a paddle and tries to break all the bricks on the screen by bouncing a ball off the paddle. 🧱🎾
- **Power-ups**: Special bricks give power-ups when hit:
  - **Bigger Paddle**: Increases the size of the paddle. ⬛
  - **Slower Paddle**: Reduces the paddle speed. 🐢
  - **Faster Paddle**: Increases the paddle speed. ⚡
- **Separate Chat Mode**: Players can communicate with each other outside of the game via a separate chat mode. 💬

## Prerequisites 📦

To run this program, you'll need the following:

- **DOSBox-X**: A DOS emulator with enhanced features. You can download it from [here](https://dosbox-x.com/).
- **Python**: To automate running the program. Download it from [python.org](https://www.python.org/).

## Installation ⚙️

1. **Clone the Repository**:

    ```bash
    git clone https://github.com/AhmedAmrNabil/brick-breaker-assembly.git 
    cd brick-breaker-assembly
    ```

2. **Set Up DOSBox-X**:

    - Ensure **DOSBox-X** is installed on your computer and its path properly configured.

3. **Run the Program Using Python**:
   The provided `run_multi.py` script will automate launching the program in **DOSBox-X**: 

    ```bash
    python run_multi.py
    ```

    This script assembles the code (if needed) and executes the program seamlessly in **DOSBox-X**. 🚀

## Game Controls 🎮

- **A**: Move the paddle to the left. ⬅️
- **D**: Move the paddle to the right. ➡️

## Power-ups 💡

- **Bigger Paddle**: The paddle size increases, allowing better control. 🔼
- **Slower Paddle**: The paddle slows down, making it harder to control but giving a more strategic advantage in some cases. 🐢
- **Faster Paddle**: The paddle speed increases, making the game more challenging but exciting. ⚡

## Chat Mode 💬

The game includes a **chat mode** where players can communicate with each other.😄

## Development 🖥️

This project was developed as part of the **Microprocessors Course** and demonstrates our understanding of **8086 assembly language** and microprocessor concepts, such as memory management, input/output handling, and system interrupts. 🔧

## License 📜

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 📄
