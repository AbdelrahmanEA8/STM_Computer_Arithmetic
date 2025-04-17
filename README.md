# STMicroelectronics Training – Computer Arithmetic

Welcome to my training repository at **STMicroelectronics**, focused on **Computer Arithmetic**. This repo includes Verilog RTL implementations of various high-performance **Adders** and **Multipliers**, reflecting industry-standard architectures and arithmetic design techniques.

---

## 📁 Repository Structure

### ➤ Adders (`/adders`)
Contains implementations of the **Brent-Kung Adder**, a parallel-prefix adder architecture known for its logarithmic delay and efficient layout.

- `brent_kung_8bit.v`  
  → 8-bit Brent-Kung Adder

- `brent_kung_64bit.v`  
  → 64-bit Brent-Kung Adder

- `brent_kung_Nbit.v`  
  → Parameterized Brent-Kung Adder for arbitrary bit-widths

### ➤ Multipliers (`/multipliers`)
Contains three different types of multipliers with varying performance, area, and latency trade-offs.

- `shift_right_multiplier.v`  
  → Classic shift-right multiplication algorithm

- `radix8_multiplier.v`  
  → Optimized Radix-8 Booth multiplier

- `array_multiplier.v`  
  → Structured Array multiplier for regular layout and ease of synthesis

---

## 🔧 Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/STMicroelectronics-Computer-Arithmetic.git
   cd STMicroelectronics-Computer-Arithmetic
