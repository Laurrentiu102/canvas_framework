.386
.586

.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern exit: proc
extern printf: proc
extern rand: proc
extern srand: proc
extern time: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
hexa_format DB "edi: %x", 0ah, 0
decimal_format DB "%d", 0ah, 0
decimal_formatx2 DB "%d %d", 0ah, 0
window_title DB "LaurCrush",0
area_width EQU 601;640
area_height EQU 1000;480

editest DD 2

inceput_linii_orizontale DD 199
contor_linii_orizontale DD 199
inceput_linii_verticale DD 0
contor_linii_verticale DD 0

inceput_matrice_x DD 1
inceput_matrice_y DD 200

contor_matrice_x DD 1
contor_matrice_y DD 200

colors DD 0f21111h,01149f2h,0ba04b1h,038ed24h,0fffc4ah

area DD 0
clickcolor DD 0
pixel1color DD 0
pixel2color DD 0

redc dd 0f21111h
bluec dd 01149f2h
violetc dd 0ba04b1h
greenc dd 038ed24h
yellowc dd 0fffc4ah

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

color_macro macro x, y, color
	local coloreaza,nimic,final
	mov ecx,x
	cmp ecx,area_width
	jae nimic
	
	mov ecx,y
	cmp ecx,area_height
	jae nimic
	
	mov ecx,y
	cmp ecx,200
	jbe nimic
	
	mov ecx,x
	cmp ecx,1
	jbe nimic
	
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax, 2
	add eax, area
	mov ecx,dword ptr [eax]
	
	cmp ecx,0c2c2c2c2h
	je nimic
	
	cmp ecx,0
	je nimic
	
	cmp ecx,0ffffffh
	je nimic
	
	cmp ecx,clickcolor
	je coloreaza
	
	
	; cmp ecx,0
	; je coloreaza
	
	jmp nimic

coloreaza:
	mov dword ptr [eax],0
	mov eax,-1
	jmp final
coloreaza_alb:
	mov dword ptr [eax],0ffffffh
	mov eax,-1
	jmp final
nimic:
	mov eax,0
final:
endm

color_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	
	push [ebp+arg2]
	push [ebp+arg1]
	push offset decimal_formatx2
	call printf
	add esp,12
	
	color_macro [ebp+arg1], [ebp+arg2],clickcolor
	
	cmp eax,0
	je return
	
	;
	; add dword ptr [ebp+arg1],1
	; push [ebp+arg2]
	; push [ebp+arg1]
	; call color_proc
	; add esp,12	
	
	sub dword ptr [ebp+arg1],1
	push [ebp+arg2]
	push [ebp+arg1]
	call color_proc
	add esp,8
	
	add dword ptr [ebp+arg1],1
	add dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call color_proc
	add esp,8
	
	add dword ptr [ebp+arg1],1
	sub dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call color_proc
	add esp,8
	
	sub dword ptr [ebp+arg1],1
	sub dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call color_proc
	add esp,8
	
return:
	popa
	mov esp, ebp
	pop ebp
	ret
color_proc endp

get_color macro x, y, color
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax, 2
	add eax, area
	mov eax,dword ptr [eax]
	mov color,eax
endm

randomNumberGen proc
	push EBP
	mov EBP, ESP
	sub ESP, 0

	rdtsc
	xor ecx,ecx
	mov cl,al
	xor eax,eax
	mov eax,ecx
	mov ecx,5
	div cl
	mov al,ah
	mov ah,0

	mov ESP, EBP
	pop EBP
	ret 0
randomNumberGen ENDP

linie_orizontala macro x, y, len, color
	local bucla_linie
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_linie:
	mov dword ptr [eax],color
	add eax,4
	loop bucla_linie
endm

square macro x, y, len, color
	local bucla_linie,bucla_patrat
	push edx
	mov eax,y
	mov ebx, area_width
	mul ebx
	
	pop edx
	
	add eax,x
	shl eax, 2
	add eax, area
	mov ebx,len
bucla_patrat:
	mov ecx, len
bucla_linie:
	mov dword ptr [eax],color
	add eax,4
	loop bucla_linie
	sub eax,len*4
	add eax,4*area_width
	dec ebx
	jnz bucla_patrat
endm

linie_verticala macro x, y, len, color
	local bucla_linie
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_linie:
	mov dword ptr [eax],color
	add eax,4*area_width
	loop bucla_linie
endm

make_matrix_squares proc
	push ebp
	mov ebp, esp
	pusha
	
	xor edx,edx
	mov edx,inceput_matrice_x
	mov contor_matrice_x,edx
	
	mov edx,inceput_matrice_y
	mov contor_matrice_y,edx
loop_orizontala:
	mov contor_matrice_x,1
loop_verticala:
	push contor_matrice_y
	push contor_matrice_x
	call make_square
	add esp,8
	add contor_matrice_x,40
	cmp contor_matrice_x,area_width
	jb loop_verticala
	
	add contor_matrice_y,40
	cmp contor_matrice_y,area_height
	jb loop_orizontala
	popa
	mov esp, ebp
	pop ebp
	ret
make_matrix_squares endp

make_matrix_lines proc
	push ebp
	mov ebp, esp
	pusha
	
	mov ecx,inceput_linii_orizontale
	mov contor_linii_orizontale,ecx
bucla_linii_orizontale:
	linie_orizontala 0,contor_linii_orizontale,area_width,0FFFFFFh
	add contor_linii_orizontale,40
	cmp contor_linii_orizontale,area_height
	jb bucla_linii_orizontale
	
	mov ecx,inceput_linii_orizontale
	mov contor_linii_orizontale,ecx


	mov ecx,inceput_linii_verticale
	mov contor_linii_verticale,ecx
bucla_linii_verticale:
	linie_verticala contor_linii_verticale,inceput_linii_orizontale,800,0FFFFFFh
	add contor_linii_verticale,40
	cmp contor_linii_verticale,area_width
	jb bucla_linii_verticale
	
	popa
	mov esp, ebp
	pop ebp
	ret
make_matrix_lines endp

make_square proc
	push ebp
	mov ebp, esp
	pusha
	
	call randomNumberGen
	mov edx,0
	
	cmp eax,0
	je rosu
	
	cmp eax,1
	je albastru
	
	cmp eax,2
	je violet
	
	cmp eax,3
	je verde
	
	cmp eax,4
	je galben
	
	
rosu:
	add edx,0f21111h
	jmp final
albastru:
	add edx,01149f2h
	jmp final
violet: 
	add edx,0ba04b1h
	jmp final
verde:
	add edx,038ed24h
	jmp final
galben:
	add edx,0fffc4ah
	jmp final
	;add edx,[colors+eax]
	final:
	square [ebp+arg1],[ebp+arg2],39,edx
	
	popa
	mov esp, ebp
	pop ebp
	ret
make_square endp

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0bfc9c2h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0bfc9c2h
	push area
	call memset
	add esp, 12
	call make_matrix_squares
	call make_matrix_lines
	jmp afisare_litere
	
evt_click:
	get_color [ebp+arg2],[ebp+arg3],clickcolor
	
	push clickcolor
	push offset hexa_format
	call printf
	add esp,8
	
	push 5
	push [ebp+arg3]
	push [ebp+arg2]
	call color_proc
	add esp,12
	
	jmp afisare_litere

evt_timer:
	inc counter	

afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	make_text_macro 'L', area, 220, 18
	make_text_macro 'A', area, 230, 18
	make_text_macro 'U', area, 240, 18
	make_text_macro 'R', area, 250, 18
	;make_text_macro 'E', area, 150, 100
	;make_text_macro 'C', area, 160, 100
	;make_text_macro 'T', area, 170, 100
	
	;make_text_macro 'L', area, 130, 120
	;make_text_macro 'A', area, 140, 120
	make_text_macro 'C', area, 270, 18
	make_text_macro 'R', area, 280, 18
	make_text_macro 'U', area, 290, 18
	make_text_macro 'S', area, 300, 18
	make_text_macro 'H', area, 310, 18
	
	;make_text_macro 'A', area, 100, 140
	;make_text_macro 'S', area, 110, 140
	;make_text_macro 'A', area, 120, 140
	; make_text_macro 'M', area, 130, 140
	; make_text_macro 'B', area, 140, 140
	; make_text_macro 'L', area, 150, 140
	; make_text_macro 'A', area, 160, 140
	; make_text_macro 'R', area, 170, 140
	; make_text_macro 'E', area, 180, 140

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start