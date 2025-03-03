global asm_main
extern printf
extern scanf

section .data
    input_format db "%lld",0
    output_format: db "%lld ", 0
    next_line: db "",10, 0
    matrix_sizes dq 3 dup(0)
    input_matrix1: dq 100 dup(0)
    input_matrix2: dq 100 dup(0)
    output_matrix: dq 100 dup(0)


section .text
asm_main:

    call get_input
    

    mov rax,[matrix_sizes + 16]
    push rax ;push q
    mov rax,[matrix_sizes + 8]
    push rax ;push n
    mov rax,[matrix_sizes]
    push rax ;push m
    lea rax,[input_matrix1]
    push rax ;push address of first matrix
    lea rax,[input_matrix2]
    push rax ;push address of second matrix 
    lea rax,[output_matrix]
    push rax ;push output matrix address
    call multiply_matrix 

    call print_output
    jmp end_program
    
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
    shl r9,3 ; n * 8 for move on collumn

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
    mov rdi,input_format
    lea rsi,[matrix_sizes + 16] ;q
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
    mov rax,[matrix_sizes + 8] ;n
    mov rcx,[matrix_sizes + 16] ;q
    imul rcx,rax ; n * q

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
    mov rcx,[matrix_sizes] ;m (number of row in output matrix)
    mov r15,0
    print_line:
        push rcx
        mov rcx,[matrix_sizes + 16] ; number of collumn in output matrix

        print_element:
            push rcx
            mov rdi,output_format
            mov rsi,[output_matrix + r15]
            call printf
            add r15,8
            pop rcx
            loop print_element

        mov rdi,next_line
        sub rsp,8 ;fix rsp for c functions
        call printf
        add rsp,8 ;restore rsp to correct value
        pop rcx
        loop print_line
    
    ret

end_program:
    ret

   


    


    
