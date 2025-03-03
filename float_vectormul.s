section .data

    get_size_format db "%d %d %d", 0
    get_float_element_format: db "%f", 0,
    print_float_element_format: db "%lf ", 0
    print_new_line_format: db 10, 0

	m dq 0
	n dq 0
	q dq 0

	matrix_1_address dq 0
	matrix_2_address dq 0
    matrix_result_address dq 0


section .text

	extern malloc
	extern free
    extern printf
	extern scanf

    global asm_main

asm_main:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ; NOTE : input : m n p that  n SHOULD be 4k

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	sub rsp, 8 ; alignment
    
	; Integer Function arguments : RDI, RSI, RDX, RCX, R8, R9, (Extra on stack)
    mov rdi, get_size_format
	lea rsi, [m]
	lea rdx, [n]
	lea rcx, [q]
    call scanf ; get m, n, q

	add rsp, 8
	

	; get first matrix
	push rax ; alignment
	push qword [m]
	push qword [n]
	push qword matrix_1_address

	call get_matrix ; get_matrix (row_size , col_size, where you want to store the matrix address) ; you can access to the matrix with [matrix_address]

	pop rax
	pop rax
	pop rax
	pop rax

	; get second matrix
	push rax ; alignment
	push qword [n]
	push qword [q]
	push qword matrix_2_address

	call get_matrix ; get_matrix (row_size , col_size, where you want to store the matrix address) ; you can access to the matrix with [matrix_address]

	pop rax
	pop rax
	pop rax
	pop rax

    push rax ; alignment
    push qword [m]
    push qword [n]
    push qword [q]
    push qword [matrix_1_address]
    push qword [matrix_2_address]

	call matrix_mul ; Amn * Bnq ; matrix_mul (m, n, q, matrix_1_address, matrix_2_address) ; result matrix address is in rax

    mov [matrix_result_address], rax

    pop rbx 
    pop rbx
    pop rbx
    pop rbx
    pop rbx
    pop rbx



    push rax ; alignment
    push qword [m]
    push qword [q]
    push rax ; rax = A * B matrix address

    call print_matrix ; print_matrix(row_size, col_size, matrix_address)

    pop rax
    pop rax
    pop rax
    pop rax

    sub rsp, 8

    mov rdi, [matrix_1_address]         ; Load the pointer to be freed
    call free            ; Call free

    mov rdi, [matrix_2_address]         ; Load the pointer to be freed
    call free            ; Call free

    mov rdi, [matrix_result_address]         ; Load the pointer to be freed
    call free            ; Call free

    add rsp, 8


    xor rax, rax

	ret
get_matrix:
    ; this function needs to fix alignment
    ; get argument with stack
    ; push row_size
    ; push col_size
    ; push matrix_address
    ; get_matrix (row_size , col_size, where you want to store the matrix address)
    ; [rsp + 24] ---> m
    ; [rsp + 16] ---> n
    ; [rsp + 8] ---> where you want to store the matrix address
    ; NOTE : the [rsp + 8] is not the matrix address, [rsp + 8] points to where matrix address is stored

	mov rax, [rsp + 24] ; rax = m
	mul qword [rsp + 16] ; rax = m * n
	shl rax, 2 ; rax = m * n * 4 ; 4 bytes for each element
	mov rdi, rax
	call malloc ; return address is in rax
	mov rbx, [rsp + 8] ; rbx is where you want to store the matrix address
	mov [rbx], rax ; sotre the matrix address in the [rbx]

	xor rbx, rbx ; represent i ; for  0 <= i <= m - 1
allocate_matrix_row:
	
	xor rcx, rcx ; represent j : for  0 <= j <= n - 1

	allocate_matrix_element:

		mov rax, rbx ; rax = i
		imul rax, [rsp + 16] ; rax = i * n
		add rax, rcx ; rax = ( i * n ) + j
		shl rax, 2 ; rax = ( ( i * n ) + j ) * 4 ; 4 bytes for each element
		mov rdx, [rsp + 8]
		add rax , [rdx] ; rax = matrix addreess + ( ( i * n ) + j ) * 4
        ; in other word, rax represents Aij


		push rcx ; push becuase alignment
		push rcx
		mov rdi, get_float_element_format
		lea rsi, [rax] ; get Aij element
		call scanf
		pop rcx ; pop becuase alignment
		pop rcx

		inc rcx ; j++
		cmp rcx, [rsp + 16]
		jne allocate_matrix_element ; if j != n
    
	inc rbx ; i++
    cmp rbx, [rsp + 24] 
	jne allocate_matrix_row ; if i != m
	
	ret

matrix_mul:
    ; this function needs to fix alignment
    ; get argument with stack
    ; push m
    ; push n
    ; push q
    ; push matrix_1_address
    ; push matrix_2_address
    ; matrix_mul (m, n, q, matrix_1_address, matrix_2_address)
    ; result matrix address is in rax
    

	mov rax, [rsp + 40] ; rax = m
	mul qword [rsp + 24] ; rax = m * q
	shl rax, 3 	; rax = m * q * 8 ; 8 bytes for each element : because 4 bytes * 4 bytes is approximately maximum 8 bytes
	mov rdi, rax
	call malloc 
    push rax ; where our matrix result is stored

	
    push 0 ; 0 <= i <= m
    push 0 ; 0 <= j <= q
    push 0 ; 0 <= k <= n
    push 0 ; sum : result of multiply each row with each col

    ; sum = [rsp]
    ; k = [rsp + 8]
    ; j = [rsp + 16]
    ; i = [rsp + 24]

    ; i = 0
	loop_1:
		; j = 0
        mov qword [rsp + 16], 0
		
		loop_2:
			; k = 0
            mov qword [rsp + 8], 0

			; sum = 0
            mov qword [rsp], 0

			loop_3: ; sum = sum of Aik * Bkj for 0 <= k <= n

				mov rax, [rsp + 24] ; rax = i
				mul qword [rsp + 72] ; rax = i * n
				add rax, [rsp + 8] ; rax = i * n + k
				shl rax, 2 ; rax = ( ( i * n ) + k ) * 4 ; 4 bytes for each element

				mov rbx, rax ; rbx = ( ( i * n ) + k ) * 4 ; rbx = ik

                mov rcx, [rsp + 56] ; rcx =  matrix_1 address
                movups xmm0, [rcx + rbx] ; xmm0 = [Aik, Aik+1, Aik+2, Aik+3] 
                ;movss xmm0, dword [rcx + rbx] ; xmm0 = Aik
                ;cvtss2sd xmm0, xmm0           ; Convert xmm0 (float) to double in xmm0

				mov rax, [rsp + 8] ; rax = k
				mul qword [rsp + 64] ; rax = k * q
				add rax, [rsp + 16] ; rax = k * q + j 
				shl rax, 2  ; rax = ( ( k * q ) + j ) * 4 ; 4 bytes for each element

                mov rcx, [rsp + 48] ; rcx =  matrix_2 address
                ;movups xmm1, [rcx + rax] ; xmm1 = Bkj
                ;movss xmm1, dword [rcx + rax] ; xmm1 = Bkj
                ;cvtss2sd xmm1, xmm1           ; Convert xmm1 (float) to double in xmm1

                ;;
                mov rbx, qword [rsp + 64] ; rbx = q
                shl rbx, 2 ; rbx = 4q
                ;;
                pinsrd xmm1, dword [rcx + rax], 0       ; xmm1 = [ Bkj, ?, ?, ?]
                add rax, rbx ; rax += 4q
                pinsrd xmm1, dword [rcx + rax], 1       ; xmm1 = [Bkj, Bk+1j, ?, ?]
                add rax, rbx ; rax += 4q
                pinsrd xmm1, dword [rcx + rax], 2       ; xmm1 = [ Bkj, Bk+1j, Bk+2j, ?]
                add rax, rbx ; rax += 4q
                pinsrd xmm1, dword [rcx + rax], 3       ; xmm1 = [ Bkj, Bk+1j, Bk+2j, Bk+3j]
                ;;
				
                dpps xmm0, xmm1, 0xF1       ; Dot Product  
                cvtss2sd xmm0, xmm0         ; Convert xmm0 (float) to double in xmm0
                ;dppd xmm0, xmm1, 
                ;mulsd xmm0, xmm1 ; xmm0 = xmm0 * xmm1 (double-precision multiply)
                

                movsd xmm1, qword [rsp] ; xmm1 = sum
                addsd xmm0, xmm1 ; xmm0 = sum + Aik * Bkj
                movsd qword [rsp], xmm0 ; sum = sum + Aik * Bkj
                
				;inc qword [rsp + 8] ; k++
                add qword [rsp + 8], 4 ; because we do mul of 4 elements in each step
				
                mov rcx, [rsp + 8] ; rcx = k
				cmp rcx, [rsp + 72]
				jne loop_3 ; if k != n
			
            mov rax, [rsp + 24] ; rax = i
			mul qword [rsp + 64] ; rax = i * q
			add rax, [rsp + 16] ; rax = i * q + j 
			shl rax, 3 ; rax = ( ( i * q ) + j ) * 8 ; 8 bytes for each element
				
            mov rcx, [rsp + 32] ; rcx = result matrix address
            mov rdx, [rsp] ; rdx = sum
            mov [rcx + rax], rdx ; C = result matrix ; Cij = sum

			inc qword [rsp + 16] ; j++

            mov rcx, [rsp + 16] ; rcx = j
			cmp rcx, [rsp + 64]
			jne loop_2 ; if j != q

		inc qword [rsp + 24] ; i++

        mov rcx, [rsp + 24] ; rcx = i
		cmp rcx, [rsp + 80]
		jne loop_1 ; if i != m

    pop rax
    pop rax
    pop rax
    pop rax
    pop rax ; result in rax 

	ret

print_matrix:

    ; this function needs to fix alignment
    ; get argument with stack
    ; push row_size
    ; push col_size
    ; push matrix_address
    ; print_matrix(row_size, col_size, matrix_address)
    ; NOTE : print matrix with 8 bytes size for each element

    push 0 ; i = 0 ; 0 <= i <= row_size
    push 0 ; j = 0 ; 0 <= j <= col_size

    loop__1:
        mov qword [rsp], 0 ; j = 0

        loop__2:

            mov rax, [rsp + 8] ; rax = i
            mul qword [rsp + 32] ; rax = i * col_size
            add rax, [rsp] ; rax = i * col_size + j
            shl rax, 3 ; rax = ( ( i * col_size ) + j ) * 8 ; 8 bytes for each element

            add rax, [rsp + 24]  ; rax = matrix address + ( ( i * col_size ) + j ) * 8 ; rax points to Aij


            mov rdi, print_float_element_format ; printf format
            movsd xmm0, [rax] ; xmm0(first float arg) = [rax] = Aij
            mov al, 1 
            ; NOTE: al must be 1 because we pass a floating point argument.
            ; https://stackoverflow.com/questions/20594800/printf-float-in-nasm-assembly-64-bit
            ; if al = 0, then it prints 0.000000
            call printf

            inc qword [rsp] ; j++

            mov rax, [rsp] ; rax = j
            cmp rax, [rsp + 32]
            jne loop__2 ; if j != col_size

        

        mov rdi, print_new_line_format ; printf format 
        call printf ; print new line
        
        inc qword [rsp + 8] ; i++

        mov rax, [rsp + 8] ; rax = i
        cmp rax, [rsp + 40]
        jne loop__1 ; if i != row_size

    pop rax
    pop rax
    ret
    



