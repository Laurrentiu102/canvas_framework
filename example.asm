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
extern fclose: proc
extern fscanf: proc
extern fopen: proc
extern fprintf: proc
extern printf: proc
extern fgets: proc
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
contor_nickname DD 0
mode_read DB "r", 0
mode_write DB "w", 0
mode_append DB "a", 0
file_name DB "scores.txt", 0
pointer_file_name DD 0
file_name_old DB "scores_old.txt", 0
pointer_file_name_old DD 0
started DB 0
nickname_score_format DB "%s %d",0ah,0
hexa_format DB "%x", 0ah, 0
decimal_format DB "%d", 0ah, 0
string_format DB "%s", 0ah, 0
decimal_formatx2 DB "%d %d", 0ah, 0
window_title DB "LaurCrush",0
area_width EQU 600;640
area_height EQU 1000;480

game_color DD 0

cluster_size DD 100

actual_score DD 0

inceput_linii_orizontale DD 200
contor_linii_orizontale DD 199
inceput_linii_verticale DD 0
contor_linii_verticale DD 0


inceput_matrice_x DD 0
inceput_matrice_y DD 200

contor_matrice_x DD 0
contor_matrice_x1 DD 0
contor_matrice_y DD 200
contor_matrice_y1 DD 200

colors DD 0f21111h,01149f2h,0ba04b1h,038ed24h,0fffc4ah

area DD 0
areav DD 0
areas DD 0
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

high_score DD 0
nickname DB 50 dup(0)
nickname_de_aruncat DB 50 dup(0)
scor_de_aruncat DD 0
game_over DD 1
coordx DD 0
coordy DD 0
game_over_size DD 0
disable_click DD 0
disable_timer DD 0
include digits.inc
include letters.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

update_highscore proc
	push ebp
	mov ebp, esp
	pusha
	
	; mov ecx,actual_score
	; cmp ecx,high_score
	; jbe nimic
	
	;mov high_score,ecx
	
	
	push offset mode_write
	push offset file_name_old
	call fopen
	add esp,8
	mov pointer_file_name_old,eax
	
	push offset mode_read
	push offset file_name
	call fopen
	add esp,8
	mov pointer_file_name,eax
	
	mov edi,1
	
bucla_citire_pana_la_final:
	push offset scor_de_aruncat
	push offset nickname_de_aruncat
	push offset nickname_score_format
	mov eax,pointer_file_name
	push eax
	call fscanf
	add esp,16
	
	mov eax,scor_de_aruncat
	cmp eax,actual_score
	ja skip_scriere_actual
	
	cmp edi,1
	jne skip_scriere_actual
	
	mov eax,actual_score
	push eax
	push offset nickname
	push offset nickname_score_format
	mov eax,pointer_file_name_old
	push eax
	call fprintf
	add esp,16
	dec edi
skip_scriere_actual:
	mov eax,scor_de_aruncat
	push eax
	push offset nickname_de_aruncat
	push offset nickname_score_format
	mov eax,pointer_file_name_old
	push eax
	call fprintf
	add esp,16
	
	cmp scor_de_aruncat,0
	jne bucla_citire_pana_la_final
	
	mov eax,pointer_file_name
	push eax
	call fclose
	add esp,4
	
	mov eax,pointer_file_name_old
	push eax
	call fclose
	add esp,4
	
	push offset mode_read
	push offset file_name_old
	call fopen
	add esp,8
	mov pointer_file_name_old,eax
	
	push offset mode_write
	push offset file_name
	call fopen
	add esp,8
	mov pointer_file_name,eax

bucla_scriere_pana_la_final:
	push offset scor_de_aruncat
	push offset nickname_de_aruncat
	push offset nickname_score_format
	mov eax,pointer_file_name_old
	push eax
	call fscanf
	add esp,16
	
	mov eax,scor_de_aruncat
	push eax
	push offset nickname_de_aruncat
	push offset nickname_score_format
	mov eax,pointer_file_name
	push eax
	call fprintf
	add esp,16
	
	cmp scor_de_aruncat,0
	jne bucla_scriere_pana_la_final
	
	mov eax,pointer_file_name
	push eax
	call fclose
	add esp,4
	
	mov eax,pointer_file_name_old
	push eax
	call fclose
	add esp,4
	
nimic:
	popa
	mov esp, ebp
	pop ebp
	ret
update_highscore endp

get_highscore proc
	push ebp
	mov ebp, esp
	pusha
	
	push offset mode_read
	push offset file_name
	call fopen
	add esp,8
	
	push eax
	push offset high_score
	push offset nickname_de_aruncat
	push offset nickname_score_format
	push eax
	call fscanf
	add esp,16
	pop eax
	
	push eax
	call fclose
	add esp,4
	
	popa
	mov esp, ebp
	pop ebp
	ret
get_highscore endp

last_col_grey_macro macro
local bucla_linie,bucla_verticala,bucla_jos_sus,nimic,inceput,bucla_stanga_dreapta
	mov eax,200
	mov ebx,area_width
	mul ebx
	add eax,area_width-40
	shl eax,2
	add eax,area
	mov contor_matrice_y,200
bucla_verticala:
	mov contor_matrice_x,560
bucla_orizontala:
	mov dword ptr[eax],0c2c2c2c2h
	add eax,4
	inc contor_matrice_x
	cmp contor_matrice_x,area_width
	jne bucla_orizontala
	add eax,4*area_width
	sub eax,160
	inc contor_matrice_y
	cmp contor_matrice_y,area_height
	jne bucla_verticala
endm

last_col_grey_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	last_col_grey_macro
	
	popa
	mov esp, ebp
	pop ebp
	ret
last_col_grey_proc endp

go_left_macro macro
local bucla_linie,bucla_verticala,bucla_jos_sus,nimic,inceput,bucla_stanga_dreapta

	mov eax,area_height
	mov ebx,area_width
	mul ebx
	add eax,area_width
	shl eax,2
	sub eax,8*area_width
	add eax,area
	mov contor_matrice_x,0
	mov contor_matrice_y,area_height
bucla_linie:
	
	cmp dword ptr [eax],0c2c2c2c2h
	jne nimic
	
	cmp dword ptr [eax+160],0c2c2c2c2h
	je nimic

inceput:
	push eax
	mov contor_matrice_y,area_height
bucla_jos_sus:
	mov ecx,contor_matrice_x
	mov contor_matrice_x1,ecx
	push eax
bucla_stanga_dreapta:
	mov ecx,dword ptr [eax+4]
	mov dword ptr [eax],ecx
	; pusha
	; push 2
	; push offset decimal_format
	; call printf
	; add esp,8
	; popa
	add eax,4
	inc contor_matrice_x1
	cmp contor_matrice_x1,area_width-40
	jne bucla_stanga_dreapta
	pop eax
	sub eax,4*area_width
	dec contor_matrice_y
	cmp contor_matrice_y,200
	jae bucla_jos_sus
	pop eax
	cmp dword ptr [eax],0c2c2c2c2h
	je inceput
	call last_col_grey_proc
nimic:
	add eax,4
	inc contor_matrice_x
	cmp contor_matrice_x,area_width-41
	jbe bucla_linie
endm

go_left_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	go_left_macro
	
	popa
	mov esp, ebp
	pop ebp
	ret
go_left_proc endp

update_lines_macro macro
local bucla_orizontala,bucla_verticala,nimic,if1,if2,if3
	xor edx,edx
	xor eax,eax
	
	add edx, area
	add eax, areas
	mov ebx, area_height
	dec ebx
bucla_verticala:
	mov contor_matrice_x,area_width
bucla_orizontala:
	
	; cmp dword ptr [edx],0c2c2c2h
	; jne if1
	; mov dword ptr [eax],0c2c2c2h
	
; if1:
	; cmp dword ptr [edx],0c2c2c2c2h
	; jne if2
	; mov dword ptr [eax],0c2c2c2h

if2:
	mov ecx,dword ptr [eax]
	cmp ecx,dword ptr [eax+4]
	je if3
	
	mov dword ptr [eax],0
	
if3:
	cmp ecx,dword ptr [eax+4*area_width]
	je nimic
	
	mov dword ptr [eax],0
	
nimic:
	add eax,4
	add edx,4
	
	dec contor_matrice_x
	jnz bucla_orizontala
	dec ebx
	jnz bucla_verticala
endm

update_lines_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	update_lines_macro
	
	popa
	mov esp, ebp
	pop ebp
	ret
update_lines_proc endp

update_area_macro macro
local bucla_orizontala,bucla_verticala
	xor edx,edx
	xor eax,eax
	
	add edx, area
	add eax, areas
	mov ebx, area_height
bucla_verticala:
	mov contor_matrice_x,area_width
bucla_orizontala:
	
	mov ecx,dword ptr[eax]
	mov dword ptr[edx],ecx
	
	add eax,4
	add edx,4
	
	dec contor_matrice_x
	jnz bucla_orizontala
	dec ebx
	jnz bucla_verticala
endm

update_area_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	update_area_macro
	
	popa
	mov esp, ebp
	pop ebp
	ret
update_area_proc endp

color_macrov macro x, y, color
	local coloreaza,nimic,final
	mov ecx,x
	cmp ecx,area_width
	jae nimic
	
	mov ecx,y
	cmp ecx,area_height
	jae nimic
	
	mov ecx,y
	cmp ecx,199
	jb nimic
	
	mov ecx,x
	cmp ecx,0
	jb nimic
	
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax, 2
	add eax, areav
	mov ecx,dword ptr [eax]
	
	cmp ecx,0c2c2c2h
	je nimic
	
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
	mov dword ptr [eax],0c2c2c2h
	mov eax,-1
	jmp final
coloreaza_alb:
	mov dword ptr [eax],0c2c2c2h
	mov eax,-1
	jmp final
nimic:
	mov eax,0
final:
endm

color_procv proc
	push ebp
	mov ebp, esp
	pusha
	
	
	; push [ebp+arg2]
	; push [ebp+arg1]
	; push offset decimal_formatx2
	; call printf
	; add esp,12
	
	color_macrov [ebp+arg1], [ebp+arg2],clickcolor
	
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
	call color_procv
	add esp,8
	
	add dword ptr [ebp+arg1],1
	add dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call color_procv
	add esp,8
	
	add dword ptr [ebp+arg1],1
	sub dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call color_procv
	add esp,8
	
	sub dword ptr [ebp+arg1],1
	sub dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call color_procv
	add esp,8
	
return:
	popa
	mov esp, ebp
	pop ebp
	ret
color_procv endp

go_down_macro macro
local bucla_orizontala,bucla_verticala,bucla_jos_sus,nimic,inceput

	mov eax,area_height
	mov ebx,area_width
	mul ebx
	add eax,area_width
	shl eax,2
	add eax,area
	sub eax,8*area_width
	mov contor_matrice_y,area_height
bucla_verticala:	
	mov contor_matrice_x,area_width
	add eax,4*area_width
bucla_orizontala:
	
	
	
	cmp dword ptr [eax],0c2c2c2h
	jne nimic
	cmp dword ptr [eax-4*area_width],0c2c2c2h
	jne nimic
	
inceput:
	push eax
	
	mov ecx,contor_matrice_y
	mov contor_matrice_y1,ecx
	bucla_jos_sus:	
	mov ecx,dword ptr [eax-4*area_width]
	mov dword ptr [eax],ecx
	sub eax,4*area_width
	dec contor_matrice_y1
	cmp contor_matrice_y1,200
	jne bucla_jos_sus
	
	pop eax
	cmp dword ptr [eax],0c2c2c2h
	je inceput
	nimic:
	sub eax,4
	dec contor_matrice_x
	cmp contor_matrice_x,-1
	jne bucla_orizontala
	
	sub eax,4*area_width
	dec contor_matrice_y
	cmp contor_matrice_y,200
	jne bucla_verticala
	
	; mov contor_matrice_y,area_height
; bucla_verticala:
	; mov dword ptr [eax],0
	; push eax
	; push contor_matrice_y
	; push offset decimal_format
	; call printf
	; add esp,8
	; pop eax
	
	; sub eax,4*area_width
	; dec contor_matrice_y
	; cmp contor_matrice_y,200
	; jne bucla_verticala
endm

go_down_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	go_down_macro
	
	popa
	mov esp, ebp
	pop ebp
	ret
go_down_proc endp

is_valid_macro macro x, y, color
	local coloreaza,nimic,final
	mov ecx,x
	cmp ecx,area_width
	jae nimic
	
	mov ecx,y
	cmp ecx,area_height
	jae nimic
	
	mov ecx,y
	cmp ecx,199
	jb nimic
	
	mov ecx,x
	cmp ecx,0
	jb nimic
	
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax, 2
	add eax, areav
	mov ecx,dword ptr [eax]
	
	
	cmp ecx,0c2c2c2h
	je nimic
	
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
	mov dword ptr [eax],0c2c2c2h
	inc cluster_size
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

is_valid_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	
	; push [ebp+arg2]
	; push [ebp+arg1]
	; push offset decimal_formatx2
	; call printf
	; add esp,12
	
	is_valid_macro [ebp+arg1], [ebp+arg2],clickcolor
	
	; pusha
	; push esp
	; push offset hexa_format
	; call printf
	; add esp,8
	; popa
	
	cmp eax,0
	je return
	
	;
	; add dword ptr [ebp+arg1],1
	; push [ebp+arg2]
	; push [ebp+arg1]
	; call is_valid_proc
	; add esp,12	
	
	sub dword ptr [ebp+arg1],1
	push [ebp+arg2]
	push [ebp+arg1]
	call is_valid_proc
	add esp,8
	
	add dword ptr [ebp+arg1],1
	add dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call is_valid_proc
	add esp,8
	
	add dword ptr [ebp+arg1],1
	sub dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call is_valid_proc
	add esp,8
	
	sub dword ptr [ebp+arg1],1
	sub dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call is_valid_proc
	add esp,8
	
return:
	popa
	mov esp, ebp
	pop ebp
	ret
is_valid_proc endp

update_areas_macro macro
local bucla_orizontala,bucla_verticala
	xor edx,edx
	xor eax,eax
	
	add edx, areas
	add eax, area
	mov ebx, area_height
bucla_verticala:
	mov contor_matrice_x,area_width
bucla_orizontala:
	
	mov ecx,dword ptr[eax]
	mov dword ptr[edx],ecx
	
	add eax,4
	add edx,4
	
	dec contor_matrice_x
	jnz bucla_orizontala
	dec ebx
	jnz bucla_verticala
endm

update_areas_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	update_areas_macro
	
	popa
	mov esp, ebp
	pop ebp
	ret
update_areas_proc endp

update_areav_macro macro
local bucla_orizontala,bucla_verticala
	xor edx,edx
	xor eax,eax
	
	add edx, areav
	add eax, area
	mov ebx, area_height
bucla_verticala:
	mov contor_matrice_x,area_width
bucla_orizontala:
	
	mov ecx,dword ptr[eax]
	mov dword ptr[edx],ecx
	
	add eax,4
	add edx,4
	
	dec contor_matrice_x
	jnz bucla_orizontala
	dec ebx
	jnz bucla_verticala
endm

update_areav_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	update_areav_macro
	
	popa
	mov esp, ebp
	pop ebp
	ret
update_areav_proc endp

color_macro macro x, y, color
	local coloreaza,nimic,final
	mov ecx,x
	cmp ecx,area_width
	jae nimic
	
	mov ecx,y
	cmp ecx,area_height
	jae nimic
	
	mov ecx,y
	cmp ecx,199
	jb nimic
	
	mov ecx,x
	cmp ecx,0
	jb nimic
	
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax, 2
	add eax, area
	mov ecx,dword ptr [eax]
	
	cmp ecx,0c2c2c2h
	je nimic
	
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
	mov dword ptr [eax],0c2c2c2h
	mov eax,-1
	jmp final
coloreaza_alb:
	mov dword ptr [eax],0c2c2c2h
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
	
	
	; push [ebp+arg2]
	; push [ebp+arg1]
	; push offset decimal_formatx2
	; call printf
	; add esp,12
	
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
	add eax, areas
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
	local bucla_linie,nimic
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax, 2
	mov edx,eax
	add edx, area
	add eax, areas
	mov ecx, len
bucla_linie:
	cmp dword ptr [edx],0c2c2c2h
	je nimic
	
	cmp dword ptr [edx],0c2c2c2c2h
	je nimic
	
	mov dword ptr [eax],color
nimic:
	add eax,4
	add edx,4
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
	local bucla_linie,nimic,nimic2
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax, 2
	mov edx,eax
	add edx,area
	add eax, areas
	mov ecx, len
bucla_linie:
	cmp dword ptr [edx],0c2c2c2h
	je nimic
	
	cmp dword ptr [edx],0c2c2c2c2h
	je nimic
	
	mov dword ptr [eax],color
nimic:
	cmp dword ptr [eax],0
	je nimic2
	
	cmp dword ptr [eax-4],0
	
	mov ebx,dword ptr [eax]
	cmp ebx,dword ptr [eax-4]
	je nimic2
	
	mov dword ptr [eax],0

nimic2:
	add edx,4*area_width
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
	mov contor_matrice_x,0
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
	
	linie_orizontala 0,contor_linii_orizontale,area_width,0h
	add contor_linii_orizontale,40
	cmp contor_linii_orizontale,area_height
	jb bucla_linii_orizontale
	
	linie_orizontala 0,999,area_width,0h
	
	mov ecx,inceput_linii_orizontale
	mov contor_linii_orizontale,ecx


	mov ecx,inceput_linii_verticale
	mov contor_linii_verticale,ecx
bucla_linii_verticale:
	linie_verticala contor_linii_verticale,inceput_linii_orizontale,800,0h
	add contor_linii_verticale,40
	cmp contor_linii_verticale,600
	je scade
	jmp skip
scade:
	dec contor_linii_verticale
skip:
	cmp contor_linii_verticale,area_width
	jbe bucla_linii_verticale
	
	mov eax,199
	mov ebx, area_width
	mul ebx
	add eax,0
	shl eax, 2
	add eax,areas
	mov ecx,800
bucla_linie_stanga_tot:
	cmp dword ptr [eax],0
	jne nimic
	
	cmp dword ptr [eax+4],0c2c2c2c2h
	jne nimic
	
	mov dword ptr [eax],0c2c2c2c2h
	
nimic:
	add eax,4*area_width
	loop bucla_linie_stanga_tot
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
	mov edx,dword ptr [colors+4*eax]
	final:
	square [ebp+arg1],[ebp+arg2],40,edx
	
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

make_start_button macro
	mov eax, 450
	mov ebx, area_width
	mul ebx
	add eax, 240
	shl eax, 2
	add eax, areas
	mov ecx,50
bucla_verticala:
	mov edx,100
bucla_orizontala:
	mov dword ptr [eax],0e8e843h
	add eax,4
	dec edx
	jnz bucla_orizontala
	sub eax,400
	add eax,4*area_width
	loop bucla_verticala
endm

nickname_top_left_display macro
	make_text_macro 'N', area, 10,40
	make_text_macro 'I', area, 20,40
	make_text_macro 'C', area, 30,40
	make_text_macro 'K', area, 40,40
	make_text_macro 'N', area, 50,40
	make_text_macro 'A', area, 60,40
	make_text_macro 'M', area, 70,40
	make_text_macro 'E', area, 80,40
	
	mov al,[nickname+0]
	make_text_macro eax, area, 100,40
	mov al,[nickname+1]
	make_text_macro eax, area, 110,40
	mov al,[nickname+2]
	make_text_macro eax, area, 120,40
	mov al,[nickname+3]
	make_text_macro eax, area, 130,40
	mov al,[nickname+4]
	make_text_macro eax, area, 140,40
	mov al,[nickname+5]
	make_text_macro eax, area, 150,40
	mov al,[nickname+6]
	make_text_macro eax, area, 160,40
	mov al,[nickname+7]
	make_text_macro eax, area, 170,40
endm

nickname_top_left_displays macro
	make_text_macro 'N', areas, 10,40
	make_text_macro 'I', areas, 20,40
	make_text_macro 'C', areas, 30,40
	make_text_macro 'K', areas, 40,40
	make_text_macro 'N', areas, 50,40
	make_text_macro 'A', areas, 60,40
	make_text_macro 'M', areas, 70,40
	make_text_macro 'E', areas, 80,40
	
	mov al,[nickname+0]
	make_text_macro eax, areas, 100,40
	mov al,[nickname+1]
	make_text_macro eax, areas, 110,40
	mov al,[nickname+2]
	make_text_macro eax, areas, 120,40
	mov al,[nickname+3]
	make_text_macro eax, areas, 130,40
	mov al,[nickname+4]
	make_text_macro eax, areas, 140,40
	mov al,[nickname+5]
	make_text_macro eax, areas, 150,40
	mov al,[nickname+6]
	make_text_macro eax, areas, 160,40
	mov al,[nickname+7]
	make_text_macro eax, areas, 170,40
endm

game_over_display macro
	make_text_macro 'G', areas, 240,100
	make_text_macro 'A', areas, 250,100
	make_text_macro 'M', areas, 260,100
	make_text_macro 'E', areas, 270,100
	make_text_macro ' ', areas, 280,100
	
	make_text_macro 'O', areas, 290,100
	make_text_macro 'V', areas, 300,100
	make_text_macro 'E', areas, 310,100
	make_text_macro 'R', areas, 320,100
endm

nickname_display macro
	make_text_macro 'E', areas, 263,360
	make_text_macro 'N', areas, 273,360
	make_text_macro 'T', areas, 283,360
	make_text_macro 'E', areas, 293,360
	make_text_macro 'R', areas, 303,360
	
	make_text_macro 'A', areas, 283,380
	
	make_text_macro 'N', areas, 250,400
	make_text_macro 'I', areas, 260,400
	make_text_macro 'C', areas, 270,400
	make_text_macro 'K', areas, 280,400
	make_text_macro 'N', areas, 290,400
	make_text_macro 'A', areas, 300,400
	make_text_macro 'M', areas, 310,400
	make_text_macro 'E', areas, 320,400
	
	mov al,[nickname+0]
	make_text_macro eax, areas, 250,420
	mov al,[nickname+1]
	make_text_macro eax, areas, 260,420
	mov al,[nickname+2]
	make_text_macro eax, areas, 270,420
	mov al,[nickname+3]
	make_text_macro eax, areas, 280,420
	mov al,[nickname+4]
	make_text_macro eax, areas, 290,420
	mov al,[nickname+5]
	make_text_macro eax, areas, 300,420
	mov al,[nickname+6]
	make_text_macro eax, areas, 310,420
	mov al,[nickname+7]
	make_text_macro eax, areas, 320,420
endm
start_screen proc
	push ebp
	mov ebp, esp
	pusha
	
	nickname_display
	;make_start_button
	popa
	mov esp, ebp
	pop ebp
	ret
start_screen endp

is_valid_macro_game macro x, y, color
	local coloreaza,nimic,final
	mov ecx,x
	cmp ecx,area_width
	jae nimic
	
	mov ecx,y
	cmp ecx,area_height
	jae nimic
	
	mov ecx,y
	cmp ecx,199
	jb nimic
	
	mov ecx,x
	cmp ecx,0
	jb nimic
	
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax, 2
	add eax, areav
	mov ecx,dword ptr [eax]
	
	
	cmp ecx,0c2c2c2h
	je nimic
	
	cmp ecx,0c2c2c2c2h
	je nimic
	
	cmp ecx,0
	je nimic
	
	cmp ecx,0ffffffh
	je nimic
	
	cmp ecx,game_color
	je coloreaza
	
	
	; cmp ecx,0
	; je coloreaza
	
	jmp nimic

coloreaza:
	mov dword ptr [eax],0c2c2c2h
	inc cluster_size
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

is_valid_game_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	
	; push [ebp+arg2]
	; push [ebp+arg1]
	; push offset decimal_formatx2
	; call printf
	; add esp,12
	
	is_valid_macro_game [ebp+arg1], [ebp+arg2],game_color
	
	; pusha
	; push esp
	; push offset hexa_format
	; call printf
	; add esp,8
	; popa
	
	cmp eax,0
	je return
	
	;
	; add dword ptr [ebp+arg1],1
	; push [ebp+arg2]
	; push [ebp+arg1]
	; call is_valid_proc
	; add esp,12	
	
	sub dword ptr [ebp+arg1],1
	push [ebp+arg2]
	push [ebp+arg1]
	call is_valid_game_proc
	add esp,8
	
	add dword ptr [ebp+arg1],1
	add dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call is_valid_game_proc
	add esp,8
	
	add dword ptr [ebp+arg1],1
	sub dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call is_valid_game_proc
	add esp,8
	
	sub dword ptr [ebp+arg1],1
	sub dword ptr [ebp+arg2],1
	push [ebp+arg2]
	push [ebp+arg1]
	call is_valid_game_proc
	add esp,8
	
return:
	popa
	mov esp, ebp
	pop ebp
	ret
is_valid_game_proc endp

game_over_macro macro
	mov game_over,0
	mov eax, 220
	mov ebx, area_width
	mul ebx
	add eax,20
	shl eax, 2
	add eax, areav
	mov coordx,20
	mov coordy,220
	mov contor_matrice_y,20 
bucla_verticala:
	mov contor_matrice_x,15
	mov coordx,20
bucla_orizontala:
	;mov dword ptr [eax],0ffffffh
	mov ecx,dword ptr [eax]
	mov game_color,ecx
	add eax,160
	add coordx,40
	cmp game_over,0
	jne skip_game_over
	pusha
	mov eax,coordy
	push eax
	mov eax,coordx
	push eax
	mov cluster_size,0
	call is_valid_game_proc
	add esp,8
	cmp cluster_size,2000
	jb skip
	mov game_over,1
skip:
	popa
	dec contor_matrice_x
	jnz bucla_orizontala
	add eax,160*area_width
	sub eax,2400
	add coordy,40
	dec contor_matrice_y
	jnz bucla_verticala
	jmp skip_game_over
skip_game_over:
endm

game_over_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	game_over_macro
	
	popa
	mov esp, ebp
	pop ebp
	ret
game_over_proc endp
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
	je evt_click
	cmp eax, 2
	je evt_timer ; nu s-a efectuat click pe nimic
	cmp eax,3
	je tasta
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0bfc9c2h
	push areas
	call memset
	add esp, 12
	call update_area_proc
	call make_matrix_squares
	cmp started,0
	je skip
afisare:
	call update_areav_proc
	call update_areas_proc
	call make_matrix_lines
	jmp afisare_litere
	
evt_click:
	nickname_top_left_display
	cmp started,0
	je skip
	cmp disable_click,1
	je skip_click
skip_score:
	
	get_color [ebp+arg2],[ebp+arg3],clickcolor
	
	; push clickcolor
	; push offset hexa_format
	; call printf
	; add esp,8
	
	cmp clickcolor,0c2c2c2h
	je no_delete
	cmp clickcolor,0c2c2c2c2h
	je no_delete
	cmp clickcolor,0h
	je no_delete

	mov cluster_size,0
	push [ebp+arg3]
	push [ebp+arg2]
	call is_valid_proc
	add esp,8
	
	cmp cluster_size,3200
	jb no_delete
	
	pusha
	mov eax,cluster_size
	xor edx,edx
	mov ebx,100
	div ebx
	xor ecx,ecx
	mov cl,al
	add actual_score,eax
	; push actual_score
	; push offset decimal_format
	; call printf
	; add esp,8
	popa
	call update_areav_proc
	push [ebp+arg3]
	push [ebp+arg2]
	call color_proc
	add esp,8
	
	push [ebp+arg3]
	push [ebp+arg2]
	call color_procv
	add esp,8
	
	mov eax,actual_score
	cmp eax,high_score
	jb skip_score
	mov high_score,eax
	
no_delete:
	call go_down_proc
	call go_left_proc
	call go_left_proc
	call go_left_proc
	call update_areav_proc
	
	call game_over_proc
	call update_areav_proc
	
	call update_areas_proc
	call make_matrix_lines
skip:
	cmp started,0
	jne skip_start_screen
	call start_screen
	
skip_click:
	nickname_top_left_display
	jmp afisare_litere

evt_timer:
	nickname_top_left_display
	cmp disable_timer,1
	je skip1
	inc counter
	cmp game_over,0
	jne skip1
	call update_highscore
	game_over_display
	mov disable_click,1
	mov disable_timer,1
skip1:
	; call game_over_proc
	; call update_areav_proc
	cmp started,0
	jne skip_start_screen
	call start_screen
skip_start_screen:
	nickname_top_left_display
	jmp afisare_litere
tasta:
	cmp started,0
	jne afisare_litere
	pusha
	mov cl,[ebp+arg2]
	cmp cl,65
	jb skip_nu_litera
	cmp cl,90
	ja skip_nu_litera
	mov esi,contor_nickname
	mov nickname[esi],cl
	inc contor_nickname
skip_nu_litera:
	mov cl,[ebp+arg2]
	cmp cl,8
	jne skip_backspace
	mov esi,contor_nickname
	dec esi
	mov nickname[esi],0
	dec contor_nickname
	cmp contor_nickname,0
	jg skip_backspace
	mov contor_nickname,0
skip_backspace:
	mov cl,[ebp+arg2]
	cmp cl,13
	jne skip_enter
	pusha
	; mov al,started
	; push eax
	; push offset decimal_format
	; call printf
	; add esp,8
	popa
	mov started,1
	popa
	jmp afisare
skip_enter:
	popa
	call start_screen
afisare_litere:
	mov ebx,10
	mov eax,high_score
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 580, 10
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 570, 10
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 560, 10
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 550, 10
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 540, 10
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 530, 10
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 520, 10

	
	mov ebx,10
	mov eax,actual_score
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 580, 30
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 570, 30
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 560, 30
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 550, 30
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 540, 30
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 530, 30
	mov edx, 0
	div ebx
	add edx,'0'
	make_text_macro edx, areas, 520, 30
	
	
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, areas, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, areas, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, areas, 10, 10
	
	;scriem un mesaj
	
	make_text_macro 'H', areas, 410, 10
	make_text_macro 'I', areas, 420, 10
	make_text_macro 'G', areas, 430, 10
	make_text_macro 'H', areas, 440, 10
	make_text_macro ' ', areas, 450, 10
	make_text_macro 'S', areas, 460, 10
	make_text_macro 'C', areas, 470, 10
	make_text_macro 'O', areas, 480, 10
	make_text_macro 'R', areas, 490, 10
	make_text_macro 'E', areas, 500, 10
	make_text_macro ':', areas, 510, 10
	
	make_text_macro 'Y', areas, 410, 30
	make_text_macro 'O', areas, 420, 30
	make_text_macro 'U', areas, 430, 30
	make_text_macro 'R', areas, 440, 30
	make_text_macro ' ', areas, 450, 30
	make_text_macro 'S', areas, 460, 30
	make_text_macro 'C', areas, 470, 30
	make_text_macro 'O', areas, 480, 30
	make_text_macro 'R', areas, 490, 30
	make_text_macro 'E', areas, 500, 30
	make_text_macro ':', areas, 510, 30
	
	make_text_macro 'L', areas, 220, 18
	make_text_macro 'A', areas, 230, 18
	make_text_macro 'U', areas, 240, 18
	make_text_macro 'R', areas, 250, 18
	;make_text_macro 'E', area, 150, 100
	;make_text_macro 'C', area, 160, 100
	;make_text_macro 'T', area, 170, 100
	
	;make_text_macro 'L', area, 130, 120
	;make_text_macro 'A', area, 140, 120
	make_text_macro 'C', areas, 270, 18
	make_text_macro 'R', areas, 280, 18
	make_text_macro 'U', areas, 290, 18
	make_text_macro 'S', areas, 300, 18
	make_text_macro 'H', areas, 310, 18
	
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
	call get_highscore
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov areav, eax
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov areas, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push areas
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
