# 🏗️ Matrix Multiplication in x86-64 Assembly

## 🔍 Overview
This assembly program performs **matrix multiplication** for two input matrices using **x86-64 NASM**. The implementation utilizes **manual memory management, register-based computations, and loop optimizations** to efficiently compute the result matrix.

## 🎯 Objectives
- Read matrix dimensions (`m × n` and `n × q`) and input values.
- Perform **matrix multiplication** using nested loops and optimized register usage.
- Print the resulting matrix to the standard output.

## 🛠 Dependencies & Compilation
To compile and run the program, install NASM and GCC:
```bash
nasm -f elf64 matrix_mul.asm -o matrix_mul.o
gcc matrix_mul.o -no-pie -o matrix_mul -lm
./matrix_mul
```

## 🔑 Key Components
### 1️⃣ Data Section
- **`matrix_sizes`**: Stores dimensions `(m, n, q)`.
- **`input_matrix1` & `input_matrix2`**: Input matrices.
- **`output_matrix`**: Resultant matrix.

### 2️⃣ Matrix Multiplication Algorithm
- **Registers Usage**:
  - `r11`: First matrix pointer.
  - `r12`: Second matrix pointer.
  - `r10`: Output matrix pointer.
  - `r13, r14, r15`: Store matrix dimensions.
- **Loop Structure**:
  - **Outer Loop** iterates over rows.
  - **Middle Loop** iterates over columns.
  - **Inner Loop** computes dot product using `imul` and `add`.

### 3️⃣ Input Handling (`get_input`)
- Reads matrix dimensions using `scanf`.
- Populates both matrices using a loop structure.

### 4️⃣ Output Handling (`print_output`)
- Iterates through the `output_matrix`.
- Prints formatted output using `printf`.

## 📂 Memory Management
- **Stack-based argument passing** for function calls.
- **Manual memory address calculations** for navigating matrices.
- **Loop unrolling & register optimizations** to minimize memory access latency.

## 🚀 Execution Steps
1. Compile and run the program.
2. Input matrix dimensions and elements.
3. The program computes `output_matrix = input_matrix1 × input_matrix2`.
4. The result is printed row-wise.

## ⚠️ Notes
- **Supports only integer values** for matrix elements.
- **Ensures memory alignment** for efficient access.
- **Loops optimized** for better performance on large matrices.

