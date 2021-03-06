    ; указываем ассемблеру, что целевая платформа - spectrum128(pentagon)
    device zxspectrum128
    
    ; адрес на который компилировать
    org #6100
    
begin_file:
    ; устанавливаем дно стека
    ld sp,#6100

    ; разрешаем прерывания
    ei

    ; очищаем экран
    ld a,#47
    call clear_screen

    ;  100 - 10 -> a
    ld a,100
    ld b,10
    sub b
    ; x
    ld d,0
    ; y
    ld e,3
    call print_byte_xy

loop:
    ld a,(.numder)
    ld d,0
    ld e,0
    call print_byte_xy

    ld a,(.numder)
    inc a
    ld (.numder),a

    .10 halt

    jr loop
.numder db 0

; Процедура очистки экрана 
; a - цвет атрибутов экрана
; испорченные регистры: af,hl,de,bc
clear_screen:
    ; заполняем атрибуты
    ld hl,#5800
    ld de,#5800 + 1
    ld bc,768 - 1
    ld (hl),a
    ldir
    ; очистка экрана
    xor a
    ld hl,#4000
    ld de,#4000 + 1
    ld bc,6144 - 1
    ld (hl),a
    ldir
    ret

; Печать байта по координатам xy
; d - координата по оси x (0..31)
; e - координата по оси y (0..23)
; a - байт
; испорченные регистры: af,hl,de,bc
print_byte_xy:
    ; вычисляем адрес символа на экране
    push af
    call calc_addr_xy
    pop af
    ; [n..]
    ld b,100
    call .print_next
    ; [.n.]
    inc hl 
    ld b,10
    call .print_next
    ; [..n]
    inc hl
    ld b,1
    call .print_next
    ret
.print_next:
    push hl
    ; извлекаем цифру в c
    ld c,-1
.mod_loop:
    inc c
    sub b ;вычитаем текущую степень 10-ки
    jr nc,.mod_loop ;повтоpять пока A > степень 10-ки
    add b
    ; получаем код символа и печатаем
    push af
    ld a,c
    add '0'
    call print_char
    pop af
    pop hl
    ret

; Печать строки по координатам xy
; d - координата по оси x (0..31)
; e - координата по оси y (0..23)
; строка идет после call print_string_int_xy
; испорченные регистры: af,hl,de
print_string_int_xy:
    ld (.stack),sp
    ld bc,(.stack)
    ld a,(bc): ld l,a: inc bc
    ld a,(bc): ld h,a
    call print_string_xy
    inc sp: inc sp
    ex de,hl
    inc hl
    jp (hl)
.stack dw 0

; Печать строки по координатам xy
; d - координата по оси x (0..31)
; e - координата по оси y (0..23)
; hl - строка
; испорченные регистры: af,hl,de
print_string_xy:
    ; вычисляем адрес символа на экране
    push hl
    call calc_addr_xy
    pop de
.loop:
    ld a,(de)
    or a
    ret z
    push hl
    push de
    call print_char
    pop de
    pop hl
    inc hl
    inc de
    jr .loop

; Печать символа по координатам xy
; d - координата по оси x (0..31)
; e - координата по оси y (0..23)
; a - символ
; испорченные регистры: af,hl,de
print_char_xy:
    ; вычисляем адрес символа на экране
    push af
    call calc_addr_xy
    pop af
    ; печать символа на экране
    call print_char
    ret

; Расчет адреса в экранной области с точностью до знакоместа
; d - координата по оси x (0..31)
; e - координата по оси y (0..23)
; hl - расчитанный адрес
; испорченные регистры: af,hl
calc_addr_xy:
    ; get [y2, y1, y0,  0,  0,  0,  0,  0] -> a
    ld a,e
    and 7
    rrca;[>>] 
    rrca;[>>]  
    rrca;[>>]
    ; get [y2, y1, y0, x4, x3, x2, x1, x0] -> a  
    add a,d
    ld l,a; l <- a
    ; get [0,  0,  0, y4, y3,  0,  0,  0] -> a   
    ld a,e
    and #18
    ; or screen high addr
    or high #4000
    ld h,a; h <- a 
    ret

; Печать символа на экране, по адресу в hl
; hl - куда печатать
; a - код символа
; испорченные регистры: af,hl,de
print_char:
    ; получаем указатель на байты символа в ПЗУ в de
    push hl
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl    
    ld de,.font
    add hl,de
    ex de,hl
    pop hl
    ; печатаем
    dup 8
    ld a,(de)
    inc de
    ld (hl),a
    inc h 
    edup
    ret    
.font equ 15616 - 32 * 8 
    
end_file:
    ; выводим размер банарника
    display "code size: ", /d, end_file - begin_file
    
    ; сохраняем sna(снапшот состояния) файл
    savesna "numbers.sna", begin_file
    
    ; сохраняем метки
    labelslist "user.l"
