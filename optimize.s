section .data

    get_size_format db "%d %d", 0
	get_element_format db "%d", 0
	print_trace_format: db "%d" , 10 , 0
	;
	print_element_format: db "%d ", 0
    print_new_line_format: db 10, 0
	;
	m dq 0
	n dq 0

	matrix_1_address dq 0
	matrix_2_address dq 0
	matrix_transpose_address dq 0
	matrix_multiply_address dq 0

section .text
	extern malloc
	extern free
	extern scanf
	extern printf

    global asm_main

asm_main:

	sub rsp, 8 ; alignment
    
	; Integer Function arguments : RDI, RSI, RDX, RCX, R8, R9, (Extra on stack)
    mov rdi, get_size_format
	lea rsi, [m]
	lea rdx, [n]
    call scanf ; get m, n

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
	push qword [m]
	push qword [n]
	push qword matrix_2_address

	call get_matrix ; get_matrix (row_size , col_size, where you want to store the matrix address) ; you can access to the matrix with [matrix_address]

	pop rax
	pop rax
	pop rax
	pop rax



	push rax ; alignment
	push qword [m]
	push qword [n]
	push qword [matrix_1_address] 

	call transpose ; transpose (row_size, col_size, matrix_address) ; result matrix address is in rax

	mov [matrix_transpose_address], rax

	pop rbx
	pop rbx
	pop rbx
	pop rbx

    ;;;;;;;;;
    push 0 ; alignment
	push qword [n]
    push qword [m]
    push qword [n]
    push qword [matrix_transpose_address]
    push qword [matrix_2_address]

    call optimize

    mov [matrix_multiply_address], rax

    pop rbx
    pop rbx
    pop rbx
    pop rbx
    pop rbx
	pop rax ; rax = trace
    ;;;;;;;;;;;;;;


	;push rax ; alignment
	;push qword [n]
    ;push qword [m]
    ;push qword [n]
    ;push qword [matrix_transpose_address]
    ;push qword [matrix_2_address]

	;call matrix_mul ; Amn * Bnq ; matrix_mul (m, n, q, matrix_1_address, matrix_2_address) ; alignment is fixed ; result matrix address is in rax

    ;mov [matrix_multiply_address], rax

    ;pop rbx
    ;pop rbx
    ;pop rbx
    ;pop rbx
    ;pop rbx
	;pop rbx

	;push qword [n]
	;push qword [matrix_multiply_address]

	;call find_trace ; print_trace (n, matrix_address) ; result in rax

	;pop rbx
	;pop rbx

	sub rsp, 8

	mov rdi, print_trace_format ; printf format
    mov rsi, rax ; first printf argument ; rax = trace
    call printf ; print trace


    mov rdi, [matrix_1_address]         ; Load the pointer to be freed
    call free            ; Call free

    mov rdi, [matrix_2_address]         ; Load the pointer to be freed
    call free            ; Call free

	mov rdi, [matrix_transpose_address]         ; Load the pointer to be freed
    call free            ; Call free

    ;mov rdi, [matrix_multiply_address]         ; Load the pointer to be freed
    ;call free            ; Call free

    add rsp, 8

	xor rax, rax
	ret
optimize:
    ; this function needs to fix alignment
    ; get argument with stack
    ; push m
    ; push n
    ; push q
    ; push matrix_1_address
    ; push matrix_2_address
    ; matrix_mul (m, n, q, matrix_1_address, matrix_2_address)
	; result matrix address is in rax
    

	;mov rax, [rsp + 40] ; rax = m
	;mul qword [rsp + 24] ; rax = m * q
	;shl rax, 3 	; rax = m * q * 8 ; 8 bytes for each element : because 4 bytes * 4 bytes is approximately maximum 8 bytes
	;mov rdi, rax
	;call malloc 
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
	;loop_1:
		; j = 0
        ;mov qword [rsp + 16], 0
		
		loop_2:
			; k = 0
            mov qword [rsp + 8], 0

			; sum = 0
            mov qword [rsp], 0

			loop_3: ; sum = sum of Aik * Bkj for 0 <= k <= n

				mov rax, [rsp + 16] ; rax = i
				mul qword [rsp + 72] ; rax = i * n
				add rax, [rsp + 8] ; rax = i * n + k
				shl rax, 2 ; rax = ( ( i * n ) + k ) * 4 ; 4 bytes for each element

				mov rbx, rax ; rbx = ( ( i * n ) + k ) * 4 ; rbx = ik

                mov rcx, [rsp + 56] ; rcx =  matrix_1 address
				mov eax, dword [rcx + rbx] ; we store it in eax 
				cdqe ; sign extend ; actually we mov eax to rax ; rax = Aik

                mov rbx, rax ; rbx = Aik

				mov rax, [rsp + 8] ; rax = k
				mul qword [rsp + 64] ; rax = k * q
				add rax, [rsp + 16] ; rax = k * q + j 
				shl rax, 2  ; rax = ( ( k * q ) + j ) * 4 ; 4 bytes for each element

                mov rcx, [rsp + 48] ; rcx =  matrix_2 address
				mov eax, dword [rcx + rax] ; we store it in eax 
				cdqe ; sign extend ; actually we mov eax to rax ; rax = Bkj
				

				imul rbx ; rax = Aik * Bkj

                mov rbx, rax ; rbx = Aij * Bjk

                
                add [rsp], rbx ; sum += Aij * Bjk
                

				inc qword [rsp + 8] ; k++
				
                mov rcx, [rsp + 8] ; rcx = k
				cmp rcx, [rsp + 72]
				jne loop_3 ; if k != n
			
            ;mov rax, [rsp + 16] ; rax = i
			;mul qword [rsp + 64] ; rax = i * q
			;add rax, [rsp + 16] ; rax = i * q + j 
			;shl rax, 3 ; rax = ( ( i * q ) + j ) * 8 ; 8 bytes for each element
				
            ;mov rcx, [rsp + 32] ; rcx = result matrix address
            ;mov rdx, [rsp] ; rdx = sum
            ;mov [rcx + rax], rdx ; C = result matrix ; Cij = sum

            ;;
            mov rax, [rsp] ; rax = sum
            add rax, [rsp + 88] ; rax += old_result
            mov qword[rsp + 88], rax ; new_result = rax
            ;;

			inc qword [rsp + 16] ; j++

            mov rcx, [rsp + 16] ; rcx = j
			cmp rcx, [rsp + 64]
			jne loop_2 ; if j != q

		;inc qword [rsp + 24] ; i++

        ;mov rcx, [rsp + 24] ; rcx = i
		;cmp rcx, [rsp + 80]
		;jne loop_1 ; if i != m

    pop rax
    pop rax
    pop rax
    pop rax
    pop rax ; result in rax 

	ret

transpose:
	; this function needs to fix alignment
    ; get argument with stack
    ; push row_size(m)
    ; push col_size(n)
    ; push matrix_address
    ; transpose (row_size, col_size, matrix_address)
	; result matrix address is in rax

	mov rax, [rsp + 24] ; rax = m
	mul qword [rsp + 16] ; rax = m * n
	shl rax, 2 	; rax = m * n * 4 ; 4 bytes for each element
	mov rdi, rax
	call malloc
    push rax ; where our matrix result is stored


	push 0 ; 0 <= i <= n
    push 0 ; 0 <= j <= m

	; i = [rsp + 8]
	; j = [rsp]
	; result_matris_address = [rsp + 16]
	; input_matris_address = [rsp + 32]
	; n = [rsp + 40]
	; m = [rsp + 48]

	loop__1:
		; j = 0
		mov qword [rsp], 0

		loop__2:

			mov rax, [rsp + 8] ; rax = i
			mul qword [rsp + 48] ; rax = i * m
			add rax, [rsp] ; rax = i * m + j
			shl rax, 2 ; rax = ( ( i * m ) + j ) * 4 ; 4 bytes for each element 

			mov rbx, rax ; rbx = ij

			mov rax, [rsp] ; rax = j 
			mul qword [rsp + 40] ; rax = j * n
			add rax, [rsp + 8] ; rax = j * n + i
			shl rax, 2 ; rax = ( ( j * n ) + i ) * 4 ; 4 bytes for each element ; rax = ji


			mov rcx, [rsp + 16] ; rcx = result_matris_address
			add rcx, rbx ; rcx = result_matris_address + ij

			mov rdx, [rsp + 32] ; input_matris_address
			add rdx, rax ; input_matris_address + ji
			mov eax, dword [rdx] ; eax = Aji

			mov [rcx], eax ; result_matris_ij = input_matris_ji ; NOTE: very imprtant to mov eax not rax

			inc qword [rsp] ; j++

			mov rcx, [rsp]
			cmp rcx, [rsp + 48]
			jne loop__2 ; if j != m

		inc qword [rsp + 8] ; i++

		mov rcx, [rsp + 8]
		cmp rcx, [rsp + 40]
		jne loop__1 ; if i != n
	
	pop rax
	pop rax
	pop rax

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
		mov rdi, get_element_format
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
