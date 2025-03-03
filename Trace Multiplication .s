global asm_main
extern printf
extern scanf

section .data
    input_format db "%lld",0
    output_format: db "%lld ",10, 0
    matrix_sizes dq 2 dup(0)
    input_matrix1: dq 100 dup(0)
    input_matrix2: dq 100 dup(0)
    transpose_matrix dq 100 dup(0)
    output_matrix: dq 100 dup(0)
    trace dq 0


section .text
asm_main:

    call get_input

    mov rax,[matrix_sizes + 8]
    push rax ;push n
    mov rax,[matrix_sizes]
    push rax ;push m
    lea rax,[transpose_matrix]
    push rax ;push output matrix address
    lea rax,[input_matrix1]
    push rax ;push address of first matrix
    call build_transpose

    mov rax,[matrix_sizes + 8]
    push rax ;push q(in this case same as n)
    mov rax,[matrix_sizes]
    push rax ;push m (n in last question)
    mov rax,[matrix_sizes + 8]
    push rax ;push n (m in last question)
    lea rax,[transpose_matrix]
    push rax ;push address of transpose of first matrix
    lea rax,[input_matrix2]
    push rax ;push address of second matrix 
    lea rax,[output_matrix]
    push rax ;push output matrix address
    call multiply_matrix 

    mov rax,[matrix_sizes + 8]
    push rax ; push n
    lea rax,[output_matrix]
    push rax; push matrix that we want calaculate its trace (n*n)
    call calculate_trace

    call print_output
    jmp end_program

calculate_trace:
    push rbp
    mov rbp,rsp
    add rbp,16
    mov rax,[rbp] ;matrix
    add rbp,8
    mov rbx,[rbp] ;m
    mov r9,rbx
    shl r9,3 ;scaled index for mov on row
    add r9,8 ; scaled index for move on diameter 
    mov rcx,rbx
    sum_of_elements:
        add rdx,[rax]
        add rax,r9
        loop sum_of_elements
    pop rbp
    mov [trace],rdx
    ret 16


build_transpose:
    push rbp
    mov rbp,rsp
    add rbp,16
    mov r10,[rbp] ;input_matrix1
    add rbp,8
    mov r11,[rbp] ;transpose_matrix
    add rbp,8
    mov r12,[rbp] ;m
    add rbp,8
    mov r13,[rbp] ;n
    mov r9,r13
    shl r9,3 ;scaled index for go to next row
    mov rcx,r13
    build_collumns:
        push rcx
        push r10
        mov rcx,r12
        put_elements:
            mov rax,[r10]
            mov [r11],rax
            add r11,8
            add r10,r9
            loop put_elements
        pop r10
        add r10,8
        pop rcx
        loop build_collumns
    
    pop rbp
    ret 32

multiply_matrix:
    push rbp
    mov rbp,rsp
    add rbp,16
    mov r10,[rbp] ;outputMatrix
    add rbp,8
    mov r12,[rbp] ;input1_matrix2
    add rbp,8
    mov r11,[rbp] ;input_matrix1
    add rbp,8
    mov r13,[rbp] ;m
    add rbp,8
    mov r14,[rbp] ;n
    add rbp,8
    mov r15,[rbp] ;q
    mov rcx,r13 ;number of rows of output martix
    mov r8,r15
    mov r9,r14
    shl r8,3 ; q * 8 for move on collumn
    shl r9,3 ; n * 8 for move on rows


    calculate:
        push rcx
        push r11
        push r12
        mov rcx,r15 ;number of elements in each row
        calculate_row:
            push rcx
            push r12
            push r11
            mov rcx,r14 ;number of multiply that we need for calculate each element

            xor rbx,rbx

            calculate_one:
                mov rax,[r11]
                mov rdx,[r12]
                imul rax,rdx
                add rbx,rax
                add r11,8 ;next element in row (first matrix)
                add r12,r8 ;next element in collumn (second matrix)
                loop calculate_one

            mov [r10],rbx
            add r10,8 ;next element in output matrix
            pop r11
            pop r12
            add r12,8 ;next collumn in second matrix
            pop rcx
            loop calculate_row
        
        pop r12
        pop r11
        add r11,r9 ;next row in first matrix
        pop rcx
        loop calculate


    pop rbp
    ret 48 


get_input:
    
    mov rdi,input_format
    lea rsi,[matrix_sizes] ;m
    call scanf
    mov rdi,input_format
    lea rsi,[matrix_sizes + 8] ;n
    call scanf
    mov rax,[matrix_sizes]
    mov rcx,[matrix_sizes + 8] ;m
    imul rcx,rax ; m*n
    lea rsi,[input_matrix1]
    
    first_matrix:
        mov rdi,input_format
        push rsi
        push rcx ;scanf change registers so we should push rcx and rsi before call it
        call scanf
        pop rcx
        pop rsi
        add rsi,8 ;next element of matrix
        loop first_matrix

    lea rsi,[input_matrix2]
    mov rax,[matrix_sizes] ;m
    mov rcx,[matrix_sizes + 8] ;n
    imul rcx,rax ; m * n

    second_matrix:
        mov rdi,input_format
        push rsi
        push rcx ;scanf change registers so we should push rcx and rsi before call it
        call scanf
        pop rcx
        pop rsi
        add rsi,8 ;next element of matrix
        loop second_matrix

    ret


print_output:
    mov rdi,output_format
    mov rsi,[trace]
    call printf
    ret

end_program:
    ret

   


    


    
