; напишем геттер и сеттер
; из лабы5/тест

SetElement macro iq,jq,newValue
	pusha	
	mov bx,offset mas_copy
	mov ax,ten
	mul dim ;size of dt
	mov dx,word ptr iq
	mul dx ;ax - begin of the current string
	mov si,ax
	
	mov ax,ten
	mov dx,word ptr jq
	mul dx
	mov di,ax
	xor ax,ax
	
	add si,di
	fld newValue
	fstp tbyte ptr [bx][si]
	popa
endm

GetElement macro iq,jq
	pusha	
	mov bx,offset mas_copy
	mov ax,ten
	mul dim ;size of dt
	mov dx,word ptr iq
	mul dx ;ax - begin of the current string
	mov si,ax
	
	mov ax,ten
	mov dx,word ptr jq
	mul dx
	mov di,ax
	xor ax,ax
	
	add si,di
	fld tbyte ptr [bx][si]
	popa
	
endm	


;--------------------Рамка перед титулкой---------------------
rama macro
	putchar 196,1,0,78
	putchar 196,1,24,78
	mov cx,23
	vertical:
	putchar 179,0,cl,1
	putchar 179,79,cl,1
	loop vertical
	putchar 218,0,0,1
	putchar 191,79,0,1
	putchar 192,0,24,1
	putchar 217,79,24,1
endm
;--------------------Рамка основная---------------------

rama1 macro	
	clearscreen 1,1,78,23	
	putchar 196,1,19,78
	mov cx,19
	vertical2:
	putchar 179,52,cl,1
	;putchar 179,66,cl,1
	loop vertical2	
	putchar 195,0,19,1
	putchar 180,79,19,1
	putchar 194,52,0,1
	putchar 193,52,19,1
	;putchar 194,66,0,1
	;putchar 193,66,19,1	
endm

;-----------Вывод символа--------------------
putchar macro char,x,y,n	
	pusha	
	mov ah,02h	; установка позиции курсора					
	mov bh,0	; видео страница					
	mov dl,x 						
	mov dh,y	
	int 10h	
	mov ax,char						
	mov ah,0ah	;писать символ в текущей позиции курсора					
	mov bl,0	; видео страница					
	mov cx,n	; счетчик количества символов					
	int 10h			
	popa
	endm	

;-----------Вывод строки--------------------	
printline macro s,x,y			
	pusha
	mov ah,02h						
	mov bh,0						
	mov dl,x 						
	mov dh,y	
	int 10h							
	mov ah, 9     ; выдать строку
	lea dx, s ; адрес строки
	int 21h							
	popa
	endm

;----Аннимация итый элемент------------	

i_anim macro n
pusha
putchar 91,2,21,1
printline blank 3,21
mov bl,n
call outnumber
popa
putchar 93,7,21,1
endm

;----Аннимация йотый элемент------------	

j_anim macro n
pusha
putchar 91,8,21,1
printline blank 9,21
mov bl,n
call outnumber
popa
putchar 93,13,21,1
endm

;----Аннимация элемент столбца------------	

fcol_anim macro n
pusha
putchar 91,2,21,1
printline blank 3,21
mov bl,n
call outnumber
popa
putchar 93,6,21,1
endm


;-----------Очистка экрана--------------------	
clearscreen macro x1,y1,x2,y2 				
	pusha
	mov ah,6      ; очистить окно
	mov al,0	  ; строки, сдвигаемые снизу
	mov ch,y1
	mov cl,x1
	mov dh,y2
	mov dl,x2
	mov bh,7 	  ; видео-атрибут для пустых строк
	int 10h
	popa
	endm
	
;---------------------------------------------------------------

.model 	small
.stack 	100h
.386	
	
.data

string db 12 dup(0) ;12
string1 db 20 dup (0) ;20
len_string=12
len_string1=20
ten dw 10
mess_e db "It's not a number, you should input from the beginning$"

	input db "Input dimension of matrix: $"
	blank db " $"
	result db "X': $"
	much db "Please, enter a number less then 13$"
	dim_text db "N: $"
	input_elem db "Input elements of matrix:$"
	input_fcol db "Input elements of free elements column:$"
	press_c db "Press 'c' to change matrix element$"
	press_f db "Press 'f' to change column element$"
	press_a db "Press any key to perform calculation...$"
	go_to_zeros db "Press n to stop adding elements/leave all zeros$"
	input_change db "Input [i,j] of element you want to change$"
	endofp db "The end$"
	changing_column db "Now changing a column of matrix...press any key$"
	lower_matrix db "You can see upper triangular matrix on the base of A$"
	becoming_answer db "We've got an answer!$"
	matrix_a db "Matrix A:$"
	column_b db "Column b:$"
	det_a db "D:$"
	tp db ":$"
	err_msg db "Print a number please$"
	virozh db "It's a degenerate matrix!$"
	it db "i:$"
	jt db "j:$"
	et db "New value:$"
	
	variant db "Solution of a system of linear equations with Cramer's rule$"
	student db "Gonchar Alexandr, group KM-12$"
	anykey db "Press any key to continue...$"
		 
	mas dt 255 dup (0)
	mas_copy dt 255 dup (0)
	mas_nil dt 255 dup(0)
	fcol dt 15 dup(0)
	dim dw ?
	dim2 dw ?
	
	index dw 0
	x dw ?
	y dw ?
	i dw ?
	j dw ?
	k dw ?
	el dt ?
	elem dt ?	
	det dt 1
	det_start dt ?
	thr dt ?
	nil dq 0
	
	massii dt ?
	massji dt ?
	massjk dt ?
	massik dt ?
	massikb dt ?
	bb dt ?
	 
	
.code


outnumber   proc  far   ;процедура вывода числа на экран.
        push ax
        push cx
        push dx		
        cmp bx,0
        jge @innum     ;да - число неотрицательное.
        mov ah,02   ;выводим на экран символ '-'.
        mov dl,'-'
        int 21h
        neg bx      ;меняем знак.
@innum:    mov ax,bx
        mov bx,0
        mov dx,10   ;делитель.
        mov cx,0    ;количество помещений в стек.
@count:    div dl     
        mov bl,ah   ;остаток от деления - в стек.
        push bx
        mov ah,0
        inc cx      ;увеличить счетчик на 1.
        cmp ax,0    
        jne @count     ;получение следующей цифры.
        mov ah,02
@out:    pop dx
        add dl,48
        int 21h
        loop @out
        pop dx
        pop cx
        pop ax
        ret
outnumber   endp

input_and_str2float PROC
	push cx
	push bx
	push si
;-------ввод строки
inpp:
	mov bx,0
	mov cx,len_string1
	lea dx,string1
	mov ah,3fh
	int 21h
	jc @exit

innn:	
;-------в eax содержится количество реальное введенных символов
	mov ecx,eax
	sub ecx,2	;не учитываем два служебных символа которые эквивалентны ENTER
	push cx
	jecxz exit_ei	;если  строка пустая
	lea si,string1
	dec ecx		
	xor ax,ax
im3:	jecxz im2 ;если в строке один символ	

im1:
	xor edx,edx
	mov dl,[si]
;---------bl хранит знак числа'


	cmp bh,0 ;минуст может быть только первым символом
	jne next0
	mov bh,1
	cmp dl,'-'
	jne next0
	mov bl,1
	dec ecx
	inc si
	jmp im3
next0:	
	;--------------
	cmp al,0	
	jne next2 ; если в строке уже встречалась точка
	cmp dl,'.'	
	jne next2	;если символ не точка то проверяем его 
	mov al,1	;	если встертили точку, переходим к следующему символу
	jmp next3
next2:

	cmp dl,'0'
	jb exit_ei
	cmp dl,'9'
	ja exit_ei
	;----------------------
next3:
	inc si
	loop im1
im2: ;случай если строка содержит один символ (не учитывая минус)
	mov dl,[si]
	;--------------
	cmp dl,'n' ; WWWWHHHHAAAATTTTTTTTTTTTTT 110
	je before_run
	cmp dl,'0'
	jb exit_ei
	cmp dl,'9'
	ja exit_ei

	;----------------------

	pop cx
	call convert ;если строка нормальная - преобразовываем ее в число
	jmp end_pi
	
exit_ei:
	
	clearscreen 1,20,67,22
	printline mess_e,2,21
	
	mov ah,0 
    int 16h
	call null_matrix
	clearscreen 1,20,67,22	
	printline input_elem 2,20
	printline dim_text 63,20
	mov bx,dim
	call outnumber
	jmp here_we_in
	
end_pi:	
	pop si
	pop bx
	pop cx
	
	ret
endp

convert PROC
	    push    ax
        push    dx
        push    bp
        mov     bp, sp
        push    000Ah        ; Инициализируем кадр стэка
        push    0000h
        fld1            ; Знак числа
		lea si,string1
		
i10:    mov al, [si]
        cmp     al, 2Dh        ; '-'
        jne     short i2
        fchs            ; Если введён минус, меняем +1 на -1
		inc si
		dec cx
        jmp     short i10    ; и считываем следующий символ
i2:     fldz            ; Будущее число
i7:     cmp     cx, 0        ; конец cтроки
        je      i3
        cmp     al, 2Eh        ; '.' - переход к дробной части
        je      short i4
		sub al,30h
		fimul   word ptr [bp - 2]
        mov     [bp - 4], al    ; Иначе ST(0) = 10 * ST(0) + введённая цифра
        fiadd   word ptr [bp - 4]
		inc si
		dec cx
        mov     al, [si]
        jmp     short i7 
;--------------------------------------------------------------------
i4:     fld1            ; дробной части. 1 суть 10 в степени 0
		inc si ;	пропускаем точку
		dec cx 
i9:     mov al, [si]
        cmp     cx,0        ; конец cтроки
        je      short i8
		sub al,30h
        fidiv   word ptr [bp - 2]
        fld     st(0)        ; Формируем 10 в следующей степени и дублируем её
        mov     [bp - 4], al    ; Умножаем на введённую цифру, тем самым получая её на нужном месте
        fimul   word ptr [bp - 4]
        faddp   st(2), st    ; И добавляем к числу
		inc si
		dec cx
        jmp     short i9
i8:     fstp    st(0)        ; Убираем 10 в степени
i3:     fmulp   st(1), st    ; Вспоминаем про знак
i1:     leave				;mov esp,ebp  и pop ebp
        pop     dx
        pop     ax
		
        ret
endp  

; Процедура вывода числа на вершине стэка FPU. Число после вывода выталкивается
output_float PROC far
		push    ax
        push    cx
        push    dx
        push    bp
        mov     bp, sp
        push    000Ah        ; Основание нашей системы счисления
        push    0000h        ; Ячейка для передачи цифр из FPU в CPU
        setc    cl        ; CL = 1 для вывода ' +' или ' -' перед числом, CL = 0 для вывода ' = ' или ' = -'
        ftst
        fstsw   ax
        sahf
        setc    ch        ; CH = 1 if ST(0) < 0  
        test    cl, cl
        jnz     short o13
		mov ah,2
        mov     dl, 20h
        int     21h
o13:    test    ch, ch
        jz      short o14
        mov     dl, 2Dh        ; '-'
        int     21h
        jmp     short o15
o14:    test    cl, cl
        jz      short o15
        mov     dl, 2Bh        ; '+'
        int     21h
o15:    fabs            ; Со знаком разобрались, выводим модуль числа
        fld1            ; Сначала отделим целую и дробную части
        fld     st(1)
        fprem
        fsub    st(2), st
        fxch    st(2)        ; ST(0) = целая часть, ST(1) = 1, ST(2) = дробная часть
        fild    word ptr [bp - 2]
        fld st(1)
        xor     cx, cx        ; ST(0) = 10, ST(1) = целая часть, ST(2) = 1, ST(3) = дробная часть

o16:    fprem            ; Получаем последнюю цифру ST(0)
        fist    word ptr [bp - 4]    ; Сохраняем её в стэке, так как цифры получаются справа налево,
        push    word ptr [bp - 4]    ; а выводить их надо слева направо
        inc     cx        ; Увеличиваем счётчик цифр целой части
        fsubp   st(2), st    ; Сдвигаем ST(0) на одну цифру вправо
        fdiv    st(1), st
        fld     st(1)
        ftst            ; Если ST(0) = 0, то целую часть разобрали
        fstsw   ax
        sahf
        jnz     short o16    ; ST(0) = 0, ST(1) = 10, ST(2) = 0, ST(3) = 1, ST(4) = дробная часть
        fstp    st(0)
        fstp    st(1)        ; ST(0) = 10, ST(1) = 1, ST(2) = дробная часть
        mov     ah, 02h
o17:    pop     dx        ; Выводим цифры целой части на экран
        add     dl, 30h
        int     21h
        loop    o17
        fxch    st(2)        ; ST(0) = дробная часть, ST(1) = 1, ST(2) = 10
        ftst
        fstsw   ax
        sahf
        jz      short o18    ; Если дробная часть ноль, выводить её не будем
        mov     ah, 02h        ; Иначе начинаем с точки
        mov     dl, 2Eh
        int     21h
        mov     cx, 0004h    ; Выведем не более шести цифр
o19:    fmul    st, st(2)    ; Сдвигаем дробную часть на одну цифру влево, получаем a.bcd... Выделим a
        fxch    st(1)        ; ST(0) = 1, ST(1) = a.bcd..., ST(2) = 10
        fld     st(1)        ; ST(0) = a.bcd, ST(1) = 1, ST(2) = a.bcd..., ST(3) = 10
        fprem            ; ST(0) = 0.bcd, ST(1) = 1, ST(2) = a.bcd..., ST(3) = 10
        fsubr   st, st(2)    ; ST(0) = a, ST(1) = 1, ST(2) = a.bcd..., ST(3) = 10
        fsub    st(2), st    ; ST(0) = a, ST(1) = 1, ST(2) = 0.bcd..., ST(3) = 10
        fistp   word ptr [bp - 4]
        mov     dl, [bp - 4]    ; Выводим очередную цифру дробной части
        add     dl, 30h
        mov     ah, 02h
        int     21h
        fxch    st(1)
        ftst
        fstsw   ax
        sahf
        loopnz  o19        ; Если дробная часть ноль, или уже выведено шесть цифр, закругляемся
o18:    fstp    st(0)        ; Очистка стэка сопроцессора
        fstp    st(0)
        fstp    st(0)
        leave
        pop     dx
        pop     cx
        pop     ax
        ret
    endp

;--------------------Вывод матрицы на экран---------------------

showmatrix proc far
pusha
mov si,0
mov cx,dim
mov al,2
mov bl,4
show:
printline blank al,bl
push cx
push ax
push bx
mov cx,dim
	@@lol:	
 mov ah,02h  
 fld mas_copy[si]
 call output_float
 mov dl,blank ; пропуск между элементами в ширину
 int 21h
 add si,10
	loop @@lol 	
 pop bx
 pop ax
 pop cx
 inc bl
loop show 
mov si,0
mov cx,dim
mov bl,4
mov al,45
show2:
printline blank al,bl
 push bx
 fld fcol[si]
 call output_float
 xor bx,bx
 add si,10
 pop bx
 inc bl
loop show2
popa
ret
showmatrix endp



;------------------------------------------------------
inputnumberd proc  far   ;процедура ввода числа.
        push ax
        push cx
        push dx
        mov bx,0 ;введенное число.
        mov cx,0 ;количество помещений в стек.
        mov dx,1    ;множитель.
@inpprocd:    mov ah,01
        int 21h
		cmp al,110
		je before_run
		cmp al,27
		jz @exit
        cmp al,0dh  ;это клавиша enter?
        je @processd      ;переход на обработку числа.
        cmp al,'-'  ;это знак '-'?
        je @intostackd     ;ничего вычитать не надо. 
		cmp al,48
		je @starrt
		cmp al,48
		jb @starrt
		cmp al,57
		ja @starrt
        sub al,48
@intostackd:    mov ah,0
        push ax     ;поместить цифру в стек.
        inc cx      ;увеличить счетчик на 1.
        jmp @inpprocd     ;переход на ввод новой цифры.
@processd: 
		cmp cx,0
		je @starrt
		pop ax      ;достать цифру из стека.
        cmp al,'-'  ;это '-'?
        jne @multd     ;нет - перейти на обработку.
        neg bx      ;да - сменить знак числа.
        jmp @quitd     ;выход из процедуры.
@multd:    

		mul dl      ;умножить ее на множитель.
        add bx,ax   ;прибавить произведение к результату.
        mov ax,dx
        mov dx,10
        mul dl
        mov dx,ax   ;поместить множитель в dx.
        loop @processd    ;извлечь очередную цифру.         
@quitd:
        pop dx
        pop cx
        pop ax
        ret
inputnumberd    endp

inputnumber proc  far   ;процедура ввода числа.
        push ax
        push cx
        push dx
        mov bx,0 ;введенное число.
        mov cx,0 ;количество помещений в стек.
        mov dx,1    ;множитель.
@inpproc:    mov ah,01
        int 21h
		cmp al,110
		je before_run
		cmp al,27
		jz @exit
        cmp al,0dh  ;это клавиша enter?
        je @process      ;переход на обработку числа.
        cmp al,'-'  ;это знак '-'?
        je @intostack      ;ничего вычитать не надо. 
		cmp al,48
		jb @starrt
		cmp al,57
		ja @starrt
        sub al,48
@intostack:    mov ah,0
        push ax     ;поместить цифру в стек.
        inc cx      ;увеличить счетчик на 1.
        jmp @inpproc     ;переход на ввод новой цифры.
@process:    pop ax      ;достать цифру из стека.
        cmp al,'-'  ;это '-'?
        jne @mult     ;нет - перейти на обработку.
        neg bx      ;да - сменить знак числа.
        jmp @quit     ;выход из процедуры.
@mult:    

		mul dl      ;умножить ее на множитель.
        add bx,ax   ;прибавить произведение к результату.
        mov ax,dx
        mov dx,10
        mul dl
        mov dx,ax   ;поместить множитель в dx.
        loop @process    ;извлечь очередную цифру.         
@quit:
        pop dx
        pop cx
        pop ax
        ret
inputnumber    endp

; ---------------- DETERMINANT PROCEDURE ------------

m_proc proc
pusha

mov ax,dim ; получаем дим-1, чтобы обходить нужное количество раз
add ax,-1
mov dim2,ax
xor ax,ax


mov i,0 
fld1
fstp det
fori:

	mov ax,i ;j = i+1
	inc ax
	mov j,ax	

	forj:

	; тут будет проверка на 0
	GetElement i,i
	fldz
	fcompp 
	fstsw ax
	sahf 
	je est_ist_nicht_gut
	
	GetElement j,i 
	fstp massji
	GetElement i,i
	fstp massii
	
	fld massji
	fld massii
	fdiv
	fstp bb ; получаем то самое "дабл бэ" из алгоритма C
	ffree st(0)
		
		mov ax,i
		mov k,ax
		fork:
		
		GetElement j,k
		fstp massjk
		GetElement i,k
		fstp massik
		
		fld massik
		fld bb
		fmul
		fstp massikb
		ffree st(0)
		
		fld massjk
		fld massikb
		fsub
		fstp massjk
		ffree st(0)
		SetElement j,k,massjk
				
		fork_e:
		mov ax,1
		add k,ax
		mov bx,dim2
		cmp k,bx
		ja forj_e
		jmp fork
						
	forj_e:
	
	mov ax,1
	add j,ax
	mov bx,dim2
	cmp j,bx
	ja fori_e
	jmp forj
	
fori_e:	
	
	GetElement i,i ; тут эфэлдэ итытый элемент
	fld det
	fmul
	fstp det

mov ax,1
add i,ax
mov bx,dim2
cmp i,bx
ja det_end
jmp fori

det_end:
popa 
ret

m_proc endp

;------------------------------
start_matrix proc
pusha
mov ax,dim ; получаем полный размер матрицы
mul dim
mov cx,ax
mov si,0

a2:
fld mas[si] ; считываем из копии (которая представляет начальную матрицу)
fstp mas_copy[si]; ввозвращаем начальную матрицу
add si,10
dec cx
cmp cx,0
je after_transform
jmp a2
after_transform:
popa 
ret
start_matrix endp

null_matrix proc
pusha
mov ax,dim ; получаем полный размер матрицы
mul dim
mov cx,ax
mov si,0

a22:
fld mas_nil[si] ; считываем из копии (которая представляет начальную матрицу)
fstp mas_copy[si]; ввозвращаем начальную матрицу
add si,10
dec cx
cmp cx,0
je after_transform2
jmp a22
after_transform2:
popa 
ret
null_matrix endp
;-----------------------------

; ---------------- MAIN ----------------
	
main:
mov ax,@data			
mov ds,ax 	
rama	
printline variant,10,3
printline student 26,5
printline anykey 25,18	
mov ah,0 
int 16h
@starrt:	
rama1
printline input 2,20
call inputnumberd
mov ax,13
cmp bx,ax
ja toomuch
mov dim,bx
clearscreen 1,1,50,18
printline matrix_a 3,2
printline column_b 38,2
printline dim_text 63,20
mov bx,dim
call outnumber


here_we_in:
; -------------- HERE STARTS INPUT MATRIX ------------------
clearscreen 1,20,62,22
clearscreen 1,1,50,18
printline matrix_a 3,2
printline column_b 38,2
printline input_elem 2,20
printline blank 2,21

call showmatrix

mov ax,dim ; получаем полный размер матрицы
mov bx,dim
imul bx
mov cx,ax

mov si,0
mov dl,1 ; i
mov dh,1 ; j

xxx:
mov cx,dim
;push cx

clearscreen 15,21,62,21
clearscreen 2,21,6,21
clearscreen 8,21,12,21
i_anim dh ; прокручиваем i

a:
push cx
push dx
 
 j_anim dl; прокручиваем j
 printline go_to_zeros 2,23
 printline tp 15,21
 call input_and_str2float
 fstp mas[si] ; вводим элемент в матрицу
 fld mas[si]
 fstp mas_copy[si]; вводим в копи-матрицу
 call showmatrix
 add si,10
pop dx
 cmp dx,dim
 je null1
 inc dl
pop cx
 dec cx
 cmp cx,0
 je null1
 clearscreen 15,21,62,21
jmp a

null1:
mov dl,1
pop cx
dec cx
inc dh
mov al,dh
cmp ax,dim
ja in_fcol
jmp xxx

in_fcol:
clearscreen 1,20,62,22
printline input_fcol 2,20
printline blank 2,21

mov si,0
mov cx,dim
mov dl,1

b:
 push cx
 push dx
 
 fcol_anim dl
 printline tp 7,21
 call input_and_str2float
 fstp fcol[si] ; вводим элемент в матрицу
 call showmatrix
 add si,10
pop dx
pop cx

 cmp dx,dim
 je before_run

 inc dl
 dec cx
 cmp cx,0
 je before_run
 clearscreen 7,21,62,21
jmp b

; ---------- HERE ENDS INPUT MATRIX ----------------
; ---------- ПЕРЕД СТАРТОМ ВСЕХ РАСЧЕТОВ ----------------

before_run:	
clearscreen 1,1,50,18
printline matrix_a 3,2
printline column_b 38,2
call showmatrix
clearscreen 1,20,62,23
printline press_c 2,20
printline press_f 2,21
printline press_a 2,23

asking:
mov ah,01h 
int 21h
cmp al,99
je chg
cmp al,102
je chg2
jmp run

toomuch:
clearscreen 1,1,50,18
printline matrix_a 3,2
printline column_b 38,2
printline much 2,20
mov ah,0 
int 16h
jmp @starrt

; ---------- CHANGING MATRIX ----------------

chg:
clearscreen 1,20,62,23
printline input_change 2,20
printline it 2,21
call inputnumber
mov i,bx
dec i
xor bx,bx
printline jt 2,22
call inputnumber
mov j,bx
dec j
xor bx,bx
clearscreen 1,20,62,23
printline et 2,20

call input_and_str2float
fstp el

pusha
mov bx,offset mas_copy
mov ax,10
mul dim
mul i
mov si,ax

mov ax,10
mul j
mov di,ax
xor ax,ax

add si,di
fld el
fstp tbyte ptr [bx][si]
mov bx,offset mas
fld el
fstp tbyte ptr [bx][si]
popa


jmp before_run

;------------- CHANGING FREE COLUMN -----------------
chg2:

clearscreen 1,20,62,23
printline input_change 2,20
printline it 2,21
call inputnumber
mov i,bx
dec i
xor bx,bx
clearscreen 1,20,62,23
printline et 2,20
call input_and_str2float
fstp el

pusha
mov bx,offset fcol
mov ax,10
mul i
mov si,ax
fld el
fstp tbyte ptr [bx][si]
popa
jmp before_run

;------------ START PROGRAM ---------------

run:
clearscreen 1,1,50,18
printline matrix_a 3,2
printline column_b 38,2
clearscreen 1,20,62,23
call m_proc
fld det
fstp det_start ; получаем самый первый детерминант уже
before_end:
printline lower_matrix 2,20
call showmatrix ; посмотрим на треугольную матрицу
printline det_a 63,21
fld det_start
call output_float
mov ah,0 
int 16h
call start_matrix ; перед всякими (из)превращениями мы получаем видок уже исправленной-начальной матрицы
clearscreen 1,1,50,18
printline matrix_a 3,2
printline column_b 38,2
clearscreen 1,20,62,23
printline press_a 2,20
call showmatrix ; и посмотрим восстановленную матрицу
mov ah,0 
int 16h

; ---------- УЖЕ СЧИТАЕМ ИКСЫ ---------------

printline result 54,2
mov i,0
mov bx,2
do_this:
mov si,0
mov ax,i
push ax
push bx

	mov index,0
	mov j,0 ; в этом куске кода мы меняем столбик на столбик свободных членов
	do_this2:
	
	
	pusha
	fld fcol[si]
	fldz
	fcompp 
	fstsw ax
	sahf 
	popa
	je inc_index ; какого-то один раз в цикле оно все-таки кидает на инк
	jmp norm_index
	
	inc_index:
	inc index
	
	norm_index:
	ffree st(0)	
	fld fcol[si] 
	fstp elem	
	SetElement j,i,elem
	add si,10
	inc j
	mov ax,dim
	cmp j,ax
	
	jna do_this2	

	
clearscreen 1,20,62,23
clearscreen 1,3,50,18
printline changing_column 2,20	
call showmatrix ; выводим матрицу
mov ah,0 
int 16h ; ждем энтер

dec index
mov ax,index
mov bx,dim
cmp bx,ax
jz elementary

  
 call m_proc ; считаем детерминант - В ЭТОЙ ШТУКЕНЦИИ СОЛЬ
 fld det
 fld det_start
 fdiv ;считаем один икс
 pop bx

 x_out:
 clearscreen 1,20,62,23
 printline becoming_answer 2,20	
 printline blank 58,bl
 inc bx
 call output_float ; выводим икс
 
mov ah,0 
int 16h


call start_matrix ; вовзращаем матрицу в начальное состояние

pop ax
mov i,ax
inc i
inc dl
mov ax,dim2
cmp i,ax
ja endlich_sind_wir_frei
jmp do_this

est_ist_nicht_gut:
clearscreen 1,20,62,23
clearscreen 1,3,50,18
call start_matrix
call showmatrix
printline virozh,19,21
mov ah,0 
int 16h
call null_matrix
jmp @exit

elementary:

mov cx,dim
wtfloop:
 fldz
 clearscreen 1,20,62,23
call start_matrix
call showmatrix
 printline becoming_answer 2,20	
 printline blank 58,bl
 inc bx
 call output_float ; выводим икс
loop wtfloop 


mov ah,0 
int 16h
jmp exit

; ------ КОНЕЦ ПРОГРАММЫ ---------------------------
endlich_sind_wir_frei:
clearscreen 1,20,62,23
call start_matrix
call showmatrix
printline endofp,19,21
mov ah,0 
int 16h
jmp @exit

exit:
@exit:
mov ah, 4Ch
int 21h

end main