.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern rand: proc
extern srand: proc
extern time: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
decimal_format DB "%d", 0ah, 0 
;aici declaram date
.code
start:
	push ebx                 ; Save callee saved (non-volatile) registers that we use.
                             ; EBX, EBP, ESI, EDI, ESP are non-volatile. For each
                             ; one we clobber we must save it and restore it before
                             ; returning from `main`

    push 0
    call time                ; EAX=time(0)
    add esp, 4
    push eax                 ; Use time as seed
    call srand               ; srand(time(0))
    add esp, 4

    mov ebx, 10              ; Loop 10 times

loopit:
    call rand                ; Get a random number between 0 and 32767 into EAX
	mov ecx,7
	div cx
	xor ecx,ecx
	mov cl,ah
	cmp cl,7
	jae loopit
    push ecx
    push offset decimal_format
    call printf              ; Print the random number
    add esp,8

    dec ebx
    jnz loopit               ; Loop until the counter EBX reaches 0

    pop ebx                  ; Restore callee saved registers
	
	xor eax,eax
	ret
	push 0
	call exit
end start
