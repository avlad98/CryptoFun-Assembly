;					VLAD ANDREI-ALEXANDRU
;							321CB


extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

;============== TASK 1 ==============

xor_strings:
	; TODO TASK 1
	push ebp
	mov ebp, esp
	push ecx
	push edx
	xor ecx, ecx
	xor edx, edx

	mov eax, [ebp + 8]         ;in eax se gaseste string-ul encodat
	mov ebx, [ebp + 12]        ;in ebx se gaseste cheia
xor_advance:

    ;fac xor intre toate caracterele pe rand pana la final
	cmp [eax], byte 0x00
	je xor_finish
	mov cl, byte [eax]
	mov dl, byte [ebx]
	xor cl, dl

    ;scriu rezultatul in sirul initial
	mov byte [eax], cl
	inc eax
	inc ebx
	jmp xor_advance

xor_finish:
	pop edx
	pop ecx
	leave
	ret

;============== TASK 2 ==============

rolling_xor:
	; TODO TASK 2
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor esi, esi
	xor edi, edi

	mov esi, [ebp + 8]
	mov edi, esi           ;in esi tin c-ul curent
	inc edi                ;si in edi tin c-ul urmator
	mov bl, byte [esi]

rolling_xor_advance:
	cmp byte [edi], byte 0x00
	je rolling_xor_finish
	mov cl, bl             ;in cl pastrez c-ul anterior pentru ca in sirul original
                           ;va fi suprascris 
	mov dl, byte [edi]
	xor cl, dl
	inc esi
	inc edi
	mov bl, byte [esi]
	mov byte [esi], cl
	jmp rolling_xor_advance


rolling_xor_finish:

	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	leave
	ret


;============== TASK 3 ==============
	cvt_char:                              ;functia converteste rezultatul in al
		push ebp
		mov ebp, esp
		xor eax, eax
		mov al, byte [ebp + 8]
		cmp al, '9'
		ja 	litera
		sub al, 0x30
		jmp finish_cvt_char

	litera:
		sub al, 0x57

finish_cvt_char:

		leave
		ret

xor_hex_strings:
	; TODO TASK 3
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	mov esi, [ebp + 8]	;enc_string
	mov edi, [ebp + 12]	;enc_key

	xor edx, edx
	xor ebx, ebx
	xor ecx, ecx

	cvt_string:
		cmp	byte [esi + edx], 0x00
		je 	pre_cvt_key

		;convertire primul char
		push dword [esi + edx]
		call cvt_char
		add esp, 4
		mov bh, al

		;convertire al doilea char
		push dword [esi + edx + 1]
		call cvt_char
		add esp, 4
		mov bl, al

		;combinare octeti
		shl bl, 4
		shr bx, 4

        ;suprascriu in sir caracterul convertit
		mov byte [esi + ecx], bl
		add edx, 2
		inc ecx
		jmp cvt_string

	pre_cvt_key:
        ;pregatesc "teritoriul" pentru convertirea cheii
		mov byte [esi + ecx], 0x00
		xor ecx, ecx
        xor edx, edx

	cvt_key:
		cmp	byte [edi + edx], 0x00
		je 	finish_cvt

		;convertire primul char
		push dword [edi + edx]
		call cvt_char
		add esp, 4
		mov bh, al

		;convertire al doilea char
		push dword [edi + edx + 1]
		call cvt_char
		add esp, 4
		mov bl, al

		;combinare octeti
		shl bl, 4
		shr bx, 4

		mov byte [edi + ecx], bl
		add edx, 2
		inc ecx
		jmp cvt_key

	finish_cvt:
		mov byte [edi + ecx], 0x00

		push edi
		push esi
		call xor_strings
		add esp, 8
	

	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	leave
	ret


;============== TASK 4 ==============

base32decode:
    ; TODO TASK 4

    push ebp
    mov ebp, esp
    pusha

    mov esi, [ebp + 8]                                  ;in esi am string-ul

    xor edi, edi                                        ;contorul pentru mers prin string
    xor ebx, ebx                                        ;contorul pentru modificat string-ul

initial:    
    xor eax, eax
    mov edx, 0                                          ;cu edx numar cate 8 caractere(octeti) din string-ul initial
    mov al, byte [esi + edi]                            ;verific daca am ajuns la finalul string-ului
    cmp al, 0
    je  finalTask4
    xor eax, eax

    mov ah, byte [esi + edi]                            ;iau primul octet in ah
    inc edi
    inc edx                                             ;edx e 1, mai iau 7 octeti

    cmp ah, '9'                                         ;il convertesc conform base32decode
    jl cifra
    sub ah, 'A'
    jmp vezi_edx

cifra:
    sub ah, 24

vezi_edx:
    cmp edx, 8
    jl ia_octet
    jmp initial

ia_octet:
    mov al, byte [esi + edi]                            ;iau urmatorul octet din grupul de 8
    inc edi
    inc edx

    cmp al, "="
    je padding
    jmp continuare

padding:
    mov al, 0
    jmp continua_ia_octet

continuare:
    cmp al, '9'
    jl cifra_iar
    sub al, 'A'
    jmp continua_ia_octet

cifra_iar:
    sub al, 24  

continua_ia_octet:
    cmp edx, 2
    je al_doilea_octet
    cmp edx, 3
    je al_treilea_octet
    cmp edx, 4
    je al_patrulea_octet
    cmp edx, 5
    je al_cincelea_octet
    cmp edx, 6
    je al_saselea_octet
    cmp edx, 7
    je al_saptelea_octet
    cmp edx, 8
    je al_optelea_octet


al_doilea_octet:                                        ; il am in al
    shl al, 3                                           ; in ah am deja 5 biti ai primului octet, imi mai trebui 3 din al
    shl ax, 3                                           ;in al mai am 2 biti din 5 ai celui de-al doilea octet

    mov byte [esi + ebx], ah                            
    inc ebx

    xor ah, ah
    shl ax, 2                                           ;am doi biti in ah
    jmp ia_octet


al_treilea_octet:
    shl al, 3
    shl ax, 5                                           ;am 7 biti in ah, mai am nevoie de 1 din al patrulea

    jmp ia_octet

al_patrulea_octet:
    shl al, 3
    shl ax, 1                                           ;am in ah cei 8 biti, raman 4 biti in al

    mov byte [esi + ebx], ah
    inc ebx

    xor ah, ah
    shl ax, 4                                           ;trec cei 4 biti in ah
    jmp ia_octet

al_cincelea_octet:
    shl al, 3
    shl ax, 4                                           ;mai pun inca 4 biti in ah pentru a avea 8, ramane in al un singur bit 

    mov byte [esi + ebx], ah
    inc ebx

    xor ah, ah
    shl ax, 1                                           ;bag bitul ramas in ah
    jmp ia_octet

al_saselea_octet:
    shl al, 3
    shl ax, 5                                           ;bag in ah toti cei 5 biti noi , o sa am 6 , mai trebui 2

    jmp ia_octet

al_saptelea_octet:
    shl al, 3
    shl ax, 2                                           ;iau 2 biti din al si pun in ah pentru a face 8, mai raman 3 biti in al

    mov byte [esi + ebx], ah
    inc ebx

    xor ah, ah
    shl ax, 3                                           ;bag cei 3 biti ramasi in ah
    jmp ia_octet

al_optelea_octet:
    shl al, 3
    shl ax, 5

    mov byte [esi + ebx], ah
    inc ebx
    jmp vezi_edx


finalTask4:
    popa 
    leave
    ret


;============== TASK 5 ==============

bruteforce_singlebyte_xor:
	; TODO TASK 5
    push ebp
    mov ebp, esp
    push ecx
    push edx
    xor eax, eax    ;registru pentru testarea cheilor 0-255
    xor ecx, ecx    ;registru pentru index in string
    xor edx, edx    ;registru pentru testare octet din string

    mov esi, [ebp + 8]  ;string-ul encodat

bucla_brute:
    mov dl, byte [esi + ecx]
    cmp dl, 0
    je  change_key_brute
    xor dl, al                                          
    cmp dl, 'f'                                         ;f
    je  litera_urm_o
    jne fail_brute
        
        litera_urm_o:                                   ;fo
        mov dl, byte [esi + ecx + 1]                    
        xor dl, al
        cmp dl, 'o'
        je  litera_urm_r
        jne fail_brute

        litera_urm_r:                                   ;for
            mov dl, byte [esi + ecx + 2]                
            xor dl, al
            cmp dl, 'r'
            je  litera_urm_c
            jne fail_brute

            litera_urm_c:                               ;forc
                mov dl, byte [esi + ecx + 3]            
                xor dl, al
                cmp dl, 'c'
                je  litera_urm_e
                jne fail_brute

                litera_urm_e:                           ;force
                    mov dl, byte [esi + ecx + 4]        
                    xor dl, al
                    cmp dl, 'e'
                    jne change_key_brute
                    jmp succes_brute


    jmp bucla_brute

fail_brute:
    inc ecx
    jmp bucla_brute


change_key_brute:
    xor ecx, ecx
    inc al
    jmp bucla_brute

succes_brute:

    ;aplica cheia gasita pe string
    xor ecx, ecx
    xor edx, edx
aplica_cheia:
    mov dl, byte [esi + ecx]
    cmp dl, 0x00
    je  final_bruteforce
    xor dl, al
    mov byte [esi + ecx], dl
    inc ecx
    jmp aplica_cheia


final_bruteforce:
    pop edx
    pop ecx
    leave
	ret


;============== TASK 6 ==============

decode_vigenere:
	; TODO TASK 6
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov esi, [ebp + 8]      ;string-ul criptat
    mov edi, [ebp + 12]     ;cheia vigenere
    xor eax, eax            ;in al se va face coversia fiecarei litera din string
    xor ebx, ebx            ;bl va contine pe rand octeti din cheie
    xor ecx, ecx            ;index pentru string
    xor edx, edx            ;index pentru cheie

bucla_vigenere:
        mov al, byte [esi + ecx]
        cmp al, 0x00
        je  final_vigenere

        ;aplic cheia doar cand caracterul curent este o litera mica
        ;daca e spatiu sau alt caracter sar peste
        cmp al, 'a'
        jb  skip_litera
        cmp al, 'z'
        ja  skip_litera

    reia_cheia:
        ;parcurg cheia pana o termin
        ;daca am ajuns la finalul cheii, ii resetez index-ul sa o reiau
        mov bl, byte [edi + edx]
        cmp bl, 0x00
        jne cheie_valida 
        xor edx, edx
        jmp reia_cheia

    cheie_valida:
        ;fac operatiile necesare astfel incat sa aplic diferenta de pozitii
        ;obtinuta din cheie pe litera din string
        sub bl, 'a'
        sub al, bl

        ;daca litera imi iese din domeniul alfabetului cu litere mici
        ;o readuc in alfabet
        cmp al, 'a'
        jae  scrie_litera
        add al, 26

    scrie_litera:
        ;suprascriu rezultatul in string-ul original
        mov byte [esi + ecx], al
        inc ecx
        inc edx

        jmp bucla_vigenere

    skip_litera:
        inc ecx
    
jmp bucla_vigenere


final_vigenere:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave   
	ret


;==============  MAIN  =============

main:
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 7]
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
	; TASK 1: Simple XOR between two byte streams

	; TODO TASK 1: find the address for the string and the key
	mov eax, ecx
    mov ebx, eax

advance_task1:  
    inc ebx
    cmp [ebx], byte 0x00
    jnz advance_task1
    inc ebx
    push ebx
    push eax
    call xor_strings
    add esp, 8


	; TODO TASK 1: call the xor_strings function

	push ecx
	call puts                   ;print resulting string
	add esp, 4

	jmp task_done

task2:
	; TASK 2: Rolling XOR

	; TODO TASK 2: call the rolling_xor function
	push ecx
	call rolling_xor
	add esp, 4

	push ecx
	call puts
	add esp, 4

	jmp task_done

task3:
	; TASK 3: XORing strings represented as hex strings

	; TODO TASK 1: find the addresses of both strings
	mov eax, ecx
    mov ebx, eax
advance_task3:    
    inc ebx
    cmp [ebx], byte 0x00
    jnz advance_task3
    inc ebx

	; TODO TASK 1: call the xor_hex_strings function
	push ebx
    push eax
    call xor_hex_strings
    add esp, 8
    mov al, byte [esp + 4]

	push ecx                     ;print resulting string
	call puts
	add esp, 4

	jmp task_done

task4:
	; TASK 4: decoding a base32-encoded string

	; TODO TASK 4: call the base32decode function
	push ecx
	call base32decode
	add esp, 4
	
	push ecx
	call puts                    ;print resulting string
	pop ecx
	
	jmp task_done

task5:
	; TASK 5: Find the single-byte key used in a XOR encoding

	; TODO TASK 5: call the bruteforce_singlebyte_xor function
    push ecx
    call bruteforce_singlebyte_xor
    add esp, 4
    mov esi, eax

	push ecx                    ;print resulting string
	call puts
	pop ecx

    mov eax, esi
	push eax                    ;eax = key value
	push fmtstr
	call printf                 ;print key value
	add esp, 8

	jmp task_done

task6:
	; TASK 6: decode Vignere cipher

	; TODO TASK 6: find the addresses for the input string and key
	; TODO TASK 6: call the decode_vigenere function

	push ecx
	call strlen
	pop ecx

	add eax, ecx
	inc eax

	push eax
	push ecx                   ;ecx = address of input string 
	call decode_vigenere
	pop ecx
	add esp, 4

	push ecx
	call puts
	add esp, 4

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret
